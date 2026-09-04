"use strict";

/**
 * P22A2B — Trade aggregate reconciliation.
 *
 * Source of truth: the *current* canonical /trades/{tradeId} document.
 * Trigger callbacks are only signals; event deltas are never applied directly.
 *
 * Transaction-size analysis (Firestore limit: 500 docs / txn):
 *   Reads:  1 trade + 1 _tradeAggregateState + up to 2 users
 *           + up to (offered+requested) reservation docs touched by diffs
 *   Writes: 1 state + up to 2 users + up to those reservation docs
 *           (set or delete)
 *
 * The Flutter client previously had NO upper bound on offeredItems /
 * requestedItems (only non-empty both sides). Without a bound, a legitimate
 * trade could exceed 500 documents in one reconciliation.
 *
 * V1 bound (enforced in Rules + TradeService + here):
 *   MAX_ITEMS_PER_SIDE = 50
 *   MAX_ITEMS_TOTAL    = 100
 * Worst case ≈ 1+1+2+100 reads and ≤103 writes (< 500).
 *
 * Zero reservation semantics: DELETE when outgoing==0 && incoming==0.
 * Underflow (current+delta < 0) aborts the transaction with
 * reservation_aggregate_underflow — never clamp.
 *
 * completedTrades = lifetime count. Physically deleting completed /trades
 * docs destroys rebuild authority — do not delete them without a separate
 * archival/audit source (GDPR/cleanup note).
 *
 * completedTrades semantics: LIFETIME count of completed trades.
 * Client delete of /trades is denied (allow delete: if false), so a normal
 * delete callback cannot silently decrement the lifetime counter. If Admin
 * SDK ever deletes a completed trade, do NOT auto-decrement — that requires
 * an explicit product decision.
 *
 * Known V1 limitation: accept TOCTOU (reservation_overcommit) — see
 * logReservationOvercommit. Strong consistency = candidate P22A2C.
 */

const {FieldValue, Timestamp} = require("firebase-admin/firestore");

/** @type {number} */
const MAX_ITEMS_PER_SIDE = 50;
/** @type {number} */
const MAX_ITEMS_TOTAL = 100;

const STATE_COLLECTION = "_tradeAggregateState";

/**
 * Deterministic collision-safe item key.
 * trim → lowerCase → UTF-8 → base64url without padding.
 * "4" and "004" remain distinct.
 *
 * @param {unknown} itemNumber
 * @return {string}
 */
function encodeItemKey(itemNumber) {
  const normalized = String(itemNumber ?? "").trim().toLowerCase();
  return Buffer.from(normalized, "utf8")
      .toString("base64")
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/g, "");
}

/**
 * @param {string} collectionId
 * @param {string} itemKey
 * @return {string}
 */
function reservationMapKey(collectionId, itemKey) {
  return `${String(collectionId).trim()}::${itemKey}`;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} userId
 * @param {string} collectionId
 * @param {string} itemKey
 * @return {FirebaseFirestore.DocumentReference}
 */
function reservationDocRef(db, userId, collectionId, itemKey) {
  return db
      .collection("users")
      .doc(userId)
      .collection("reservationCollections")
      .doc(collectionId)
      .collection("items")
      .doc(itemKey);
}

/**
 * Empty previous aggregate state (before any reconcile of this trade).
 * @return {object}
 */
function emptyPreviousState() {
  return {
    completedContribution: 0,
    senderId: "",
    receiverId: "",
    senderReservations: {},
    receiverReservations: {},
  };
}

/**
 * Normalize a stored state document.
 * @param {object|undefined|null} data
 * @return {object}
 */
function normalizePreviousState(data) {
  if (!data || typeof data !== "object") {
    return emptyPreviousState();
  }

  return {
    completedContribution: Number(data.completedContribution) || 0,
    senderId: String(data.senderId || ""),
    receiverId: String(data.receiverId || ""),
    senderReservations: normalizeReservationMap(data.senderReservations),
    receiverReservations: normalizeReservationMap(data.receiverReservations),
  };
}

/**
 * @param {unknown} map
 * @return {Object<string, {outgoing: number, incoming: number,
 *   collectionId: string, itemNumber: string, itemId: string, itemKey: string}>}
 */
function normalizeReservationMap(map) {
  const result = {};
  if (!map || typeof map !== "object") {
    return result;
  }

  for (const [key, value] of Object.entries(map)) {
    if (!value || typeof value !== "object") {
      continue;
    }
    result[key] = {
      outgoing: Number(value.outgoing) || 0,
      incoming: Number(value.incoming) || 0,
      collectionId: String(value.collectionId || ""),
      itemNumber: String(value.itemNumber || ""),
      itemId: String(value.itemId || ""),
      itemKey: String(value.itemKey || ""),
    };
  }
  return result;
}

/**
 * Count trade line items (for V1 bound checks).
 * @param {object} trade
 * @return {{offered: number, requested: number, total: number}}
 */
function countTradeItems(trade) {
  const offered = Array.isArray(trade.offeredItems) ?
    trade.offeredItems.length :
    0;
  const requested = Array.isArray(trade.requestedItems) ?
    trade.requestedItems.length :
    0;
  return {offered, requested, total: offered + requested};
}

/**
 * Assert V1 item bounds. Throws if exceeded.
 * @param {object} trade
 */
function assertTradeItemBounds(trade) {
  if (!Array.isArray(trade.offeredItems) || !Array.isArray(trade.requestedItems)) {
    const error = new Error(
        "trade_invalid_for_reconcile: offeredItems/requestedItems must be lists",
    );
    error.code = "trade_invalid_for_reconcile";
    throw error;
  }

  const counts = countTradeItems(trade);
  if (counts.offered > MAX_ITEMS_PER_SIDE ||
      counts.requested > MAX_ITEMS_PER_SIDE ||
      counts.total > MAX_ITEMS_TOTAL) {
    const error = new Error(
        `trade_item_limit_exceeded: offered=${counts.offered}, ` +
        `requested=${counts.requested}, total=${counts.total}, ` +
        `maxPerSide=${MAX_ITEMS_PER_SIDE}, maxTotal=${MAX_ITEMS_TOTAL}`,
    );
    error.code = "trade_item_limit_exceeded";
    throw error;
  }
}

/**
 * Minimal structural checks for aggregate-safe trade payloads.
 * Throws before any aggregate writes (transaction stays atomic / no partial).
 * @param {object} trade
 */
function assertTradeItemsStructure(trade) {
  const sides = [
    ["offeredItems", trade.offeredItems],
    ["requestedItems", trade.requestedItems],
  ];

  for (const [label, items] of sides) {
    if (!Array.isArray(items)) {
      const error = new Error(
          `trade_invalid_for_reconcile: ${label} is not a list`,
      );
      error.code = "trade_invalid_for_reconcile";
      throw error;
    }

    for (let index = 0; index < items.length; index++) {
      const item = items[index];
      if (!item || typeof item !== "object") {
        const error = new Error(
            `trade_invalid_for_reconcile: ${label}[${index}] not an object`,
        );
        error.code = "trade_invalid_for_reconcile";
        throw error;
      }

      const collectionId = String(item.collectionId ?? "").trim();
      const itemNumber = String(item.itemNumber ?? "").trim();
      const quantity = item.quantity;

      if (!collectionId) {
        const error = new Error(
            `trade_invalid_for_reconcile: ${label}[${index}].collectionId empty`,
        );
        error.code = "trade_invalid_for_reconcile";
        throw error;
      }

      if (!itemNumber) {
        const error = new Error(
            `trade_invalid_for_reconcile: ${label}[${index}].itemNumber empty`,
        );
        error.code = "trade_invalid_for_reconcile";
        throw error;
      }

      if (typeof quantity !== "number" ||
          !Number.isInteger(quantity) ||
          quantity <= 0) {
        const error = new Error(
            `trade_invalid_for_reconcile: ${label}[${index}].quantity ` +
            "must be a positive integer",
        );
        error.code = "trade_invalid_for_reconcile";
        throw error;
      }
    }
  }

  const senderId = String(trade.senderId || "").trim();
  const receiverId = String(trade.receiverId || "").trim();
  if (!senderId || !receiverId || senderId === receiverId) {
    const error = new Error(
        "trade_invalid_for_reconcile: invalid participant ids",
    );
    error.code = "trade_invalid_for_reconcile";
    throw error;
  }
}

/**
 * Full pre-write validation for reconcile / backfill.
 * @param {object} trade
 */
function assertTradeValidForReconcile(trade) {
  assertTradeItemBounds(trade);
  assertTradeItemsStructure(trade);
}

/**
 * Classify a validation error for backfill summaries.
 * @param {Error} error
 * @return {string|null}
 */
function anomalyTypeForError(error) {
  if (!error || !error.code) {
    return null;
  }
  if (error.code === "trade_item_limit_exceeded" ||
      error.code === "trade_invalid_for_reconcile" ||
      error.code === "reservation_aggregate_underflow") {
    return "ANOMALY / MANUAL REVIEW";
  }
  return null;
}

/**
 * Whether a trade line item participates in reservation aggregates.
 * Mirrors TradeService._addItems: skip rows without itemId.
 * @param {object} item
 * @return {boolean}
 */
function itemHasUsableId(item) {
  const itemId = String(item?.itemId ?? "").trim();
  return itemId.length > 0;
}

/**
 * Accumulate reservation contributions for one side.
 * @param {Object<string, object>} target
 * @param {Array<object>} items
 * @param {"outgoing"|"incoming"} direction
 */
function addReservationItems(target, items, direction) {
  if (!Array.isArray(items)) {
    return;
  }

  for (const item of items) {
    if (!itemHasUsableId(item)) {
      continue;
    }

    const collectionId = String(item.collectionId ?? "").trim();
    const itemNumber = String(item.itemNumber ?? "");
    const quantity = Number(item.quantity) || 0;

    if (!collectionId || !itemNumber.trim() || quantity <= 0) {
      continue;
    }

    const itemKey = encodeItemKey(itemNumber);
    const mapKey = reservationMapKey(collectionId, itemKey);
    const existing = target[mapKey] || {
      outgoing: 0,
      incoming: 0,
      collectionId,
      itemNumber: itemNumber.trim(),
      itemId: String(item.itemId ?? "").trim(),
      itemKey,
    };

    existing[direction] = (existing[direction] || 0) + quantity;
    target[mapKey] = existing;
  }
}

/**
 * Compute desired aggregate contribution from the canonical trade snapshot.
 *
 * @param {object|null|undefined} trade — null if trade deleted
 * @param {{senderExists: boolean, receiverExists: boolean}} [userPresence]
 * @return {object}
 */
function contributionFromTrade(trade, userPresence = {
  senderExists: true,
  receiverExists: true,
}) {
  if (!trade || typeof trade !== "object") {
    return {
      completedContribution: 0,
      senderId: "",
      receiverId: "",
      senderReservations: {},
      receiverReservations: {},
    };
  }

  const senderId = String(trade.senderId || "").trim();
  const receiverId = String(trade.receiverId || "").trim();
  const status = String(trade.status || "").trim();

  const completedContribution = status === "completed" ? 1 : 0;

  const senderReservations = {};
  const receiverReservations = {};

  // Orphan accepted trades (deleted counterpart) must not reserve forever —
  // mirrors the former client-side counterpart existence check.
  // V1: if EITHER participant user doc is missing, BOTH sides get zero
  // reservations (no half-held inventory under the surviving user either).
  const counterpartsPresent =
    userPresence.senderExists === true &&
    userPresence.receiverExists === true;

  if (status === "accepted" && counterpartsPresent && senderId && receiverId) {
    if (!trade.senderShipped) {
      addReservationItems(senderReservations, trade.offeredItems, "outgoing");
    }
    if (!trade.senderReceived) {
      addReservationItems(senderReservations, trade.requestedItems, "incoming");
    }
    if (!trade.receiverShipped) {
      addReservationItems(
          receiverReservations,
          trade.requestedItems,
          "outgoing",
      );
    }
    if (!trade.receiverReceived) {
      addReservationItems(
          receiverReservations,
          trade.offeredItems,
          "incoming",
      );
    }
  }

  return {
    completedContribution,
    senderId,
    receiverId,
    senderReservations,
    receiverReservations,
  };
}

/**
 * @param {object} a
 * @param {object} b
 * @return {boolean}
 */
function reservationEntryEqual(a, b) {
  return (a?.outgoing || 0) === (b?.outgoing || 0) &&
      (a?.incoming || 0) === (b?.incoming || 0);
}

/**
 * @param {object} desiredMap
 * @param {object} previousMap
 * @return {boolean}
 */
function reservationMapsEqual(desiredMap, previousMap) {
  const keys = new Set([
    ...Object.keys(desiredMap || {}),
    ...Object.keys(previousMap || {}),
  ]);

  for (const key of keys) {
    if (!reservationEntryEqual(
        (desiredMap || {})[key],
        (previousMap || {})[key],
    )) {
      return false;
    }
  }
  return true;
}

/**
 * @param {object} desired
 * @param {object} previous
 * @return {boolean}
 */
function contributionsEqual(desired, previous) {
  if (desired.completedContribution !== previous.completedContribution) {
    return false;
  }
  if (desired.senderId !== previous.senderId ||
      desired.receiverId !== previous.receiverId) {
    // Participant identity change is abnormal; treat as needing reconcile.
    if (previous.senderId || previous.receiverId) {
      return false;
    }
  }

  return reservationMapsEqual(
      desired.senderReservations,
      previous.senderReservations,
  ) && reservationMapsEqual(
      desired.receiverReservations,
      previous.receiverReservations,
  );
}

/**
 * Plan reservation map diffs. Throws reservation_aggregate_underflow BEFORE
 * any transaction writes if current + delta would go negative.
 *
 * Zero-doc semantics (V1): when both outgoing and incoming would be 0,
 * DELETE the reservation document.
 *
 * Non-negativity invariant: never clamp. Underflow means corruption between
 * the shared reservation aggregate and _tradeAggregateState — abort the
 * whole transaction so other trades' contributions cannot be erased.
 *
 * @param {string} userId
 * @param {object} desiredMap
 * @param {object} previousMap
 * @param {Map<string, FirebaseFirestore.DocumentSnapshot>} snapshotCache
 * @param {FirebaseFirestore.Firestore} db
 * @param {{error?: Function, warn?: Function}} logger
 * @param {string} tradeId
 * @return {Array<object>}
 */
function planReservationDiffs(
    userId,
    desiredMap,
    previousMap,
    snapshotCache,
    db,
    logger,
    tradeId,
) {
  const ops = [];
  if (!userId) {
    return ops;
  }

  const keys = new Set([
    ...Object.keys(desiredMap || {}),
    ...Object.keys(previousMap || {}),
  ]);

  for (const mapKey of keys) {
    const desired = desiredMap[mapKey] || {
      outgoing: 0,
      incoming: 0,
      collectionId: (previousMap[mapKey] || {}).collectionId || "",
      itemNumber: (previousMap[mapKey] || {}).itemNumber || "",
      itemId: (previousMap[mapKey] || {}).itemId || "",
      itemKey: (previousMap[mapKey] || {}).itemKey || "",
    };
    const previous = previousMap[mapKey] || {
      outgoing: 0,
      incoming: 0,
    };

    const outgoingDelta = (desired.outgoing || 0) - (previous.outgoing || 0);
    const incomingDelta = (desired.incoming || 0) - (previous.incoming || 0);

    if (outgoingDelta === 0 && incomingDelta === 0) {
      continue;
    }

    const collectionId = String(
        desired.collectionId || previous.collectionId || "",
    ).trim();
    const itemKey = String(desired.itemKey || previous.itemKey || "").trim();
    const itemNumber = String(
        desired.itemNumber || previous.itemNumber || "",
    );
    const itemId = String(desired.itemId || previous.itemId || "");

    if (!collectionId || !itemKey) {
      continue;
    }

    const ref = reservationDocRef(db, userId, collectionId, itemKey);
    const snap = snapshotCache.get(ref.path);
    const current = snap && snap.exists ? (snap.data() || {}) : {};
    const currentOutgoing = Number(current.outgoing) || 0;
    const currentIncoming = Number(current.incoming) || 0;

    const nextOutgoing = currentOutgoing + outgoingDelta;
    const nextIncoming = currentIncoming + incomingDelta;

    if (nextOutgoing < 0 || nextIncoming < 0) {
      const payload = {
        event: "reservation_aggregate_underflow",
        tradeId,
        uid: userId,
        collectionId,
        itemKey,
        path: ref.path,
        currentOutgoing,
        currentIncoming,
        outgoingDelta,
        incomingDelta,
        nextOutgoing,
        nextIncoming,
        anomaly: "ANOMALY / MANUAL REVIEW",
      };
      if (typeof logger.error === "function") {
        logger.error(payload);
      } else if (typeof logger.warn === "function") {
        logger.warn(payload);
      } else {
        console.error(JSON.stringify(payload));
      }

      const error = new Error(
          "reservation_aggregate_underflow: " +
          `uid=${userId} collectionId=${collectionId} itemKey=${itemKey} ` +
          `current=(${currentOutgoing},${currentIncoming}) ` +
          `delta=(${outgoingDelta},${incomingDelta}) tradeId=${tradeId}`,
      );
      error.code = "reservation_aggregate_underflow";
      error.details = payload;
      throw error;
    }

    ops.push({
      ref,
      snapExists: Boolean(snap && snap.exists),
      collectionId,
      itemNumber: itemNumber || String(current.itemNumber || ""),
      itemId: itemId || String(current.itemId || ""),
      itemKey,
      nextOutgoing,
      nextIncoming,
    });
  }

  return ops;
}

/**
 * Apply previously planned reservation ops inside an open transaction.
 * @param {FirebaseFirestore.Transaction} tx
 * @param {Array<object>} ops
 */
function applyReservationOps(tx, ops) {
  const now = Timestamp.now();
  for (const op of ops) {
    if (op.nextOutgoing === 0 && op.nextIncoming === 0) {
      if (op.snapExists) {
        tx.delete(op.ref);
      }
      continue;
    }

    tx.set(op.ref, {
      collectionId: op.collectionId,
      itemNumber: op.itemNumber,
      itemId: op.itemId,
      itemKey: op.itemKey,
      outgoing: op.nextOutgoing,
      incoming: op.nextIncoming,
      updatedAt: now,
    }, {merge: true});
  }
}

/**
 * Structured log point for accept-race overcommit (Minimal V1).
 * No Crashlytics dependency in this batch.
 *
 * TODO(P22A2C): call this when reconcile (or a future acceptTrade callable)
 * can observe inventory surplus < reserved outgoing for an item. Detection
 * needs an inventory read that is out of scope for P22A2B.
 *
 * @param {object} payload
 * @param {{warn?: Function}} [logger]
 */
function logReservationOvercommit(payload, logger = console) {
  const line = {
    event: "reservation_overcommit",
    ...payload,
  };
  if (typeof logger.warn === "function") {
    logger.warn(line);
  } else {
    console.warn(JSON.stringify(line));
  }
}

/**
 * Reconcile aggregates for one trade inside a single Firestore transaction.
 *
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} tradeId
 * @param {{logger?: object, dryRun?: boolean}} [options]
 * @return {Promise<object>}
 */
async function reconcileTradeAggregates(db, tradeId, options = {}) {
  const id = String(tradeId || "").trim();
  if (!id) {
    throw new Error("tradeId is required");
  }

  const logger = options.logger || console;
  const dryRun = options.dryRun === true;

  if (dryRun) {
    return previewReconcile(db, id);
  }

  return db.runTransaction(async (tx) => {
    const tradeRef = db.collection("trades").doc(id);
    const stateRef = db.collection(STATE_COLLECTION).doc(id);

    const tradeSnap = await tx.get(tradeRef);
    const stateSnap = await tx.get(stateRef);

    const trade = tradeSnap.exists ? tradeSnap.data() : null;
    if (trade) {
      // Throws BEFORE any writes → no partial aggregate mutation.
      assertTradeValidForReconcile(trade);
    }

    const previous = normalizePreviousState(
        stateSnap.exists ? stateSnap.data() : null,
    );

    const tradeSenderId = String(trade?.senderId || "").trim();
    const tradeReceiverId = String(trade?.receiverId || "").trim();

    // Read EVERY candidate uid that could be written (trade + previous state).
    // Strict presence checks prevent resurrecting deleted users via
    // set(..., {merge: true}) on users/{uid} or reservation subpaths.
    const candidateUids = [];
    const seenUids = new Set();
    const pushUid = (uid) => {
      const idValue = String(uid || "").trim();
      if (!idValue || seenUids.has(idValue)) {
        return;
      }
      seenUids.add(idValue);
      candidateUids.push(idValue);
    };
    pushUid(tradeSenderId);
    pushUid(tradeReceiverId);
    pushUid(previous.senderId);
    pushUid(previous.receiverId);

    const userRefs = candidateUids.map(
        (uid) => db.collection("users").doc(uid),
    );
    const userSnaps = userRefs.length ? await tx.getAll(...userRefs) : [];
    const userExists = {};
    candidateUids.forEach((uid, index) => {
      userExists[uid] = userSnaps[index]?.exists === true;
    });

    // If trade was deleted, desired is zero contribution. Participant ids
    // for reversing reservations come from previous state.
    const desired = contributionFromTrade(
        trade ? trade : null,
        {
          senderExists: tradeSenderId ?
            userExists[tradeSenderId] === true :
            false,
          receiverExists: tradeReceiverId ?
            userExists[tradeReceiverId] === true :
            false,
        },
    );

    // Preserve participant ids on state even when trade is gone so reverse
    // diffs can still target the right reservation docs. State MAY reference
    // missing/deleted uids without creating user documents.
    if (!desired.senderId && previous.senderId) {
      desired.senderId = previous.senderId;
    }
    if (!desired.receiverId && previous.receiverId) {
      desired.receiverId = previous.receiverId;
    }

    const senderUid = desired.senderId || previous.senderId || "";
    const receiverUid = desired.receiverId || previous.receiverId || "";
    const senderPresent = senderUid ? userExists[senderUid] === true : false;
    const receiverPresent = receiverUid ?
      userExists[receiverUid] === true :
      false;

    const orphan = {
      senderMissing: Boolean(senderUid) && !senderPresent,
      receiverMissing: Boolean(receiverUid) && !receiverPresent,
    };
    if (orphan.senderMissing || orphan.receiverMissing) {
      logger.warn({
        event: "aggregate_orphan_missing_user",
        tradeId: id,
        senderMissing: orphan.senderMissing,
        receiverMissing: orphan.receiverMissing,
        effectiveTradeStatus: trade ? String(trade.status || "") : "deleted",
        note:
          "Missing users are never recreated. completedTrades / reservation " +
          "writes are skipped for absent user docs. State may still record " +
          "their uid for idempotent reconciliation.",
      });
    }

    if (contributionsEqual(desired, previous) && stateSnap.exists) {
      return {
        tradeId: id,
        noop: true,
        desired,
        previous,
        orphan,
        skippedCompletedUserWrites: 0,
        skippedReservationUserWrites: 0,
      };
    }

    // Prefetch reservation docs that will be written/deleted (all reads
    // before writes — required by Firestore transactions).
    // Never touch reservation paths under a missing user document.
    const reservationRefs = [];
    const collectRefs = (uid, mapA, mapB) => {
      if (!uid || userExists[uid] !== true) {
        return;
      }
      const keys = new Set([
        ...Object.keys(mapA || {}),
        ...Object.keys(mapB || {}),
      ]);
      for (const mapKey of keys) {
        const desiredEntry = (mapA || {})[mapKey];
        const previousEntry = (mapB || {})[mapKey];
        const entry = desiredEntry || previousEntry;
        if (!entry) {
          continue;
        }
        const outDelta =
          (desiredEntry?.outgoing || 0) - (previousEntry?.outgoing || 0);
        const inDelta =
          (desiredEntry?.incoming || 0) - (previousEntry?.incoming || 0);
        if (outDelta === 0 && inDelta === 0) {
          continue;
        }
        const collectionId = String(entry.collectionId || "").trim();
        const itemKey = String(entry.itemKey || "").trim();
        if (!collectionId || !itemKey) {
          continue;
        }
        reservationRefs.push(reservationDocRef(db, uid, collectionId, itemKey));
      }
    };

    collectRefs(
        senderUid,
        desired.senderReservations,
        previous.senderReservations,
    );
    collectRefs(
        receiverUid,
        desired.receiverReservations,
        previous.receiverReservations,
    );

    const reservationSnaps = reservationRefs.length ?
      await tx.getAll(...reservationRefs) :
      [];
    const snapshotCache = new Map();
    reservationRefs.forEach((ref, index) => {
      snapshotCache.set(ref.path, reservationSnaps[index]);
    });

    // Plan reservation writes FIRST. Underflow throws before any tx writes
    // so completedTrades / state / reservations stay untouched.
    // Missing users → empty ops (no phantom reservation hierarchy).
    const senderReservationOps = senderPresent ?
      planReservationDiffs(
          senderUid,
          desired.senderReservations,
          previous.senderReservations,
          snapshotCache,
          db,
          logger,
          id,
      ) :
      [];
    const receiverReservationOps = receiverPresent ?
      planReservationDiffs(
          receiverUid,
          desired.receiverReservations,
          previous.receiverReservations,
          snapshotCache,
          db,
          logger,
          id,
      ) :
      [];

    let skippedReservationUserWrites = 0;
    if (!senderPresent && senderUid &&
        (Object.keys(desired.senderReservations || {}).length > 0 ||
         Object.keys(previous.senderReservations || {}).length > 0)) {
      skippedReservationUserWrites += 1;
    }
    if (!receiverPresent && receiverUid &&
        (Object.keys(desired.receiverReservations || {}).length > 0 ||
         Object.keys(previous.receiverReservations || {}).length > 0)) {
      skippedReservationUserWrites += 1;
    }

    // completedTrades lifetime contribution (both participants).
    const completedDelta =
      desired.completedContribution - previous.completedContribution;

    // Guard: never silently decrement lifetime completedTrades on trade
    // delete. If trade is missing and previous contribution was 1, keep
    // the lifetime count (treat as tombstone retain).
    let appliedCompletedDelta = completedDelta;
    if (!tradeSnap.exists && completedDelta < 0) {
      appliedCompletedDelta = 0;
      desired.completedContribution = previous.completedContribution;
      logger.warn({
        event: "completed_trades_retain_on_trade_delete",
        tradeId: id,
        previousContribution: previous.completedContribution,
        invariant:
          "completedTrades is a lifetime count. Do not physically delete " +
          "completed /trades documents if they are the rebuild authority, " +
          "unless a separate archival/audit source exists.",
      });
    }

    let skippedCompletedUserWrites = 0;
    if (appliedCompletedDelta !== 0) {
      const touchUser = (uid) => {
        if (!uid) {
          return;
        }
        // CRITICAL: only write when the canonical user document exists.
        // set(..., {merge: true}) would otherwise CREATE a deleted user.
        if (userExists[uid] !== true) {
          skippedCompletedUserWrites += 1;
          return;
        }
        const ref = db.collection("users").doc(uid);
        tx.set(ref, {
          completedTrades: FieldValue.increment(appliedCompletedDelta),
        }, {merge: true});
      };
      touchUser(senderUid);
      touchUser(receiverUid);
    }

    applyReservationOps(tx, senderReservationOps);
    applyReservationOps(tx, receiverReservationOps);

    tx.set(stateRef, {
      completedContribution: desired.completedContribution,
      senderId: senderUid,
      receiverId: receiverUid,
      senderReservations: desired.senderReservations,
      receiverReservations: desired.receiverReservations,
      updatedAt: Timestamp.now(),
      tradeExists: tradeSnap.exists,
    });

    return {
      tradeId: id,
      noop: false,
      desired,
      previous,
      appliedCompletedDelta,
      orphan,
      skippedCompletedUserWrites,
      skippedReservationUserWrites,
      effectiveTradeStatus: trade ? String(trade.status || "") : "deleted",
    };
  });
}

/**
 * Dry-run preview without writes.
 * @param {FirebaseFirestore.Firestore} db
 * @param {string} tradeId
 * @return {Promise<object>}
 */
async function previewReconcile(db, tradeId) {
  const tradeRef = db.collection("trades").doc(tradeId);
  const stateRef = db.collection(STATE_COLLECTION).doc(tradeId);
  const [tradeSnap, stateSnap] = await Promise.all([
    tradeRef.get(),
    stateRef.get(),
  ]);

  const trade = tradeSnap.exists ? tradeSnap.data() : null;
  if (trade) {
    try {
      assertTradeValidForReconcile(trade);
    } catch (error) {
      return {
        tradeId,
        tradeExists: tradeSnap.exists,
        anomaly: anomalyTypeForError(error) || "ANOMALY / MANUAL REVIEW",
        anomalyCode: error.code || "unknown",
        anomalyMessage: error.message,
        noop: true,
        desired: null,
        previous: normalizePreviousState(
            stateSnap.exists ? stateSnap.data() : null,
        ),
      };
    }
  }

  const senderId = String(trade?.senderId || "").trim();
  const receiverId = String(trade?.receiverId || "").trim();
  const [senderSnap, receiverSnap] = await Promise.all([
    senderId ? db.collection("users").doc(senderId).get() : null,
    receiverId ? db.collection("users").doc(receiverId).get() : null,
  ]);

  const previous = normalizePreviousState(
      stateSnap.exists ? stateSnap.data() : null,
  );
  const desired = contributionFromTrade(trade, {
    senderExists: senderSnap ? senderSnap.exists === true : false,
    receiverExists: receiverSnap ? receiverSnap.exists === true : false,
  });

  return {
    tradeId,
    tradeExists: tradeSnap.exists,
    noop: contributionsEqual(desired, previous) && stateSnap.exists,
    desired,
    previous,
    orphan: {
      senderMissing: Boolean(senderId) && !(senderSnap && senderSnap.exists),
      receiverMissing:
        Boolean(receiverId) && !(receiverSnap && receiverSnap.exists),
    },
  };
}

module.exports = {
  MAX_ITEMS_PER_SIDE,
  MAX_ITEMS_TOTAL,
  STATE_COLLECTION,
  encodeItemKey,
  reservationDocRef,
  reservationMapKey,
  emptyPreviousState,
  normalizePreviousState,
  contributionFromTrade,
  contributionsEqual,
  assertTradeItemBounds,
  assertTradeItemsStructure,
  assertTradeValidForReconcile,
  anomalyTypeForError,
  countTradeItems,
  reconcileTradeAggregates,
  previewReconcile,
  logReservationOvercommit,
};
