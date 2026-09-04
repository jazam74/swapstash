import { after, before, beforeEach, describe, it } from "node:test";
import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

import { doc, setDoc } from "firebase/firestore";

import {
  ALICE,
  BOB,
  CAROL,
  COLLECTION_ID,
  createTestEnvironment,
  seed,
  tradeFixture,
} from "./helpers.js";

const functionsDir = resolve(dirname(fileURLToPath(import.meta.url)), "../functions");
const require = createRequire(import.meta.url);
const adminAppPath = require.resolve("firebase-admin/app", {
  paths: [functionsDir],
});
const adminFsPath = require.resolve("firebase-admin/firestore", {
  paths: [functionsDir],
});
const {
  initializeApp,
  getApps,
} = require(adminAppPath);
const {
  getFirestore,
} = require(adminFsPath);

const {
  encodeItemKey,
  contributionFromTrade,
  reconcileTradeAggregates,
  STATE_COLLECTION,
  reservationDocRef,
  anomalyTypeForError,
} = require("../functions/lib/tradeAggregates.js");

const {runPreflight} = require("../functions/tools/preflight-aggregates.js");
const {
  dryRunSummary,
  writeReconcileAll,
  assertProductionGuards,
  EXPECTED_PRODUCTION_PROJECT,
} = require("../functions/tools/backfill-aggregates.js");

const PROJECT_ID = "swapstash-rules-test";

let testEnv;
let adminApp;
let adminDb;

function acceptedTrade(overrides = {}) {
  return tradeFixture({
    status: "accepted",
    awaitingUserId: "",
    senderShipped: false,
    senderReceived: false,
    receiverShipped: false,
    receiverReceived: false,
    ...overrides,
  });
}

function completedTrade(overrides = {}) {
  return tradeFixture({
    status: "completed",
    awaitingUserId: "",
    senderShipped: true,
    senderReceived: true,
    receiverShipped: true,
    receiverReceived: true,
    ...overrides,
  });
}

async function seedUsers(firestore, uids = [ALICE, BOB, CAROL]) {
  for (const uid of uids) {
    await setDoc(doc(firestore, `users/${uid}`), {
      uid,
      completedTrades: 0,
      displayName: uid.slice(0, 5),
    });
  }
}

async function readUserCompleted(uid) {
  const snap = await adminDb.collection("users").doc(uid).get();
  return snap.exists ? Number(snap.data().completedTrades) || 0 : null;
}

async function readReservation(uid, collectionId, itemNumber) {
  const itemKey = encodeItemKey(itemNumber);
  const snap = await reservationDocRef(
      adminDb,
      uid,
      collectionId,
      itemKey,
  ).get();
  return snap.exists ? snap.data() : null;
}

/** Treat missing reservation docs as inactive (zero docs are deleted). */
function assertNoActiveReservation(data) {
  assert.equal(data, null);
}

async function readState(tradeId) {
  const snap = await adminDb.collection(STATE_COLLECTION).doc(tradeId).get();
  return snap.exists ? snap.data() : null;
}

/**
 * Assert aggregate state matches contributionFromTrade(currentTrade).
 */
async function assertAggregateMatchesTrade(tradeId) {
  const tradeSnap = await adminDb.collection("trades").doc(tradeId).get();
  const trade = tradeSnap.exists ? tradeSnap.data() : null;
  const senderId = String(trade?.senderId || "").trim();
  const receiverId = String(trade?.receiverId || "").trim();
  const [senderSnap, receiverSnap] = await Promise.all([
    senderId ? adminDb.collection("users").doc(senderId).get() : null,
    receiverId ? adminDb.collection("users").doc(receiverId).get() : null,
  ]);

  const desired = contributionFromTrade(trade, {
    senderExists: senderSnap ? senderSnap.exists === true : false,
    receiverExists: receiverSnap ? receiverSnap.exists === true : false,
  });
  const state = await readState(tradeId);

  assert.ok(state, `missing state for ${tradeId}`);
  assert.equal(state.completedContribution, desired.completedContribution);
  assert.deepEqual(
      Object.keys(state.senderReservations || {}).sort(),
      Object.keys(desired.senderReservations || {}).sort(),
  );
  assert.deepEqual(
      Object.keys(state.receiverReservations || {}).sort(),
      Object.keys(desired.receiverReservations || {}).sort(),
  );

  for (const key of Object.keys(desired.senderReservations)) {
    assert.equal(
        state.senderReservations[key].outgoing,
        desired.senderReservations[key].outgoing,
    );
    assert.equal(
        state.senderReservations[key].incoming,
        desired.senderReservations[key].incoming,
    );
  }
  for (const key of Object.keys(desired.receiverReservations)) {
    assert.equal(
        state.receiverReservations[key].outgoing,
        desired.receiverReservations[key].outgoing,
    );
    assert.equal(
        state.receiverReservations[key].incoming,
        desired.receiverReservations[key].incoming,
    );
  }
}

before(async () => {
  testEnv = await createTestEnvironment();

  if (!getApps().length) {
    adminApp = initializeApp({projectId: PROJECT_ID});
  } else {
    adminApp = getApps()[0];
  }
  adminDb = getFirestore(adminApp);
});

after(async () => {
  await testEnv?.cleanup();
  // Keep admin app for process lifetime when multiple files share it.
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe("encodeItemKey", () => {
  it("uses base64url without padding and keeps 4 vs 004 distinct", () => {
    assert.equal(encodeItemKey("4"), Buffer.from("4", "utf8").toString("base64url"));
    assert.notEqual(encodeItemKey("4"), encodeItemKey("004"));
    assert.equal(encodeItemKey("  AbC  "), encodeItemKey("abc"));
    assert.ok(!encodeItemKey("???").includes("="));
  });
});

describe("reconcileTradeAggregates — out-of-order / concurrency", () => {
  beforeEach(async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore);
    });
  });

  it("accepted callback twice is idempotent", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_accept_twice"),
          acceptedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    await reconcileTradeAggregates(adminDb, "t_accept_twice");
    await reconcileTradeAggregates(adminDb, "t_accept_twice");

    await assertAggregateMatchesTrade("t_accept_twice");
    assert.equal(await readUserCompleted(ALICE), 0);
    assert.equal(await readUserCompleted(BOB), 0);

    const aliceRes = await readReservation(ALICE, COLLECTION_ID, "1");
    assert.equal(aliceRes.outgoing, 1);
    assert.equal(aliceRes.incoming, 0);

    const bobRes = await readReservation(BOB, COLLECTION_ID, "2");
    assert.equal(bobRes.outgoing, 1);
  });

  it("completed callback twice is idempotent", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_complete_twice"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    await reconcileTradeAggregates(adminDb, "t_complete_twice");
    await reconcileTradeAggregates(adminDb, "t_complete_twice");

    await assertAggregateMatchesTrade("t_complete_twice");
    assert.equal(await readUserCompleted(ALICE), 1);
    assert.equal(await readUserCompleted(BOB), 1);
    assertNoActiveReservation(await readReservation(ALICE, COLLECTION_ID, "1"));
  });

  it("completed before delayed accepted ends at completed contribution", async () => {
    const tradeId = "t_completed_before_accepted";

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, `trades/${tradeId}`),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    // "Completed callback" first.
    await reconcileTradeAggregates(adminDb, tradeId);

    // Stale "accepted" signal — trade doc is still completed.
    await reconcileTradeAggregates(adminDb, tradeId);

    await assertAggregateMatchesTrade(tradeId);
    assert.equal(await readUserCompleted(ALICE), 1);
    assert.equal(await readUserCompleted(BOB), 1);
    assertNoActiveReservation(await readReservation(ALICE, COLLECTION_ID, "1"));
  });

  it("shipped before delayed accepted uses current shipped flags", async () => {
    const tradeId = "t_shipped_before_accepted";

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, `trades/${tradeId}`),
          acceptedTrade({
            senderId: ALICE,
            receiverId: BOB,
            senderShipped: true,
          }),
      );
    });

    await reconcileTradeAggregates(adminDb, tradeId);
    // Delayed accepted signal after ship flag already set.
    await reconcileTradeAggregates(adminDb, tradeId);

    await assertAggregateMatchesTrade(tradeId);
    // Sender shipped → no outgoing reservation for offered item.
    assertNoActiveReservation(await readReservation(ALICE, COLLECTION_ID, "1"));
    const aliceIncoming = await readReservation(ALICE, COLLECTION_ID, "2");
    assert.equal(aliceIncoming.incoming, 1);
  });

  it("stale callback after newer state does not regress aggregates", async () => {
    const tradeId = "t_stale_after_newer";

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, `trades/${tradeId}`),
          acceptedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });
    await reconcileTradeAggregates(adminDb, tradeId);

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, `trades/${tradeId}`),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });
    await reconcileTradeAggregates(adminDb, tradeId);

    // Stale accepted-era reconcile signal.
    await reconcileTradeAggregates(adminDb, tradeId);

    await assertAggregateMatchesTrade(tradeId);
    assert.equal(await readUserCompleted(ALICE), 1);
    assertNoActiveReservation(await readReservation(ALICE, COLLECTION_ID, "1"));
  });

  it("two concurrent reconciliations of the same trade converge", async () => {
    const tradeId = "t_same_trade_concurrent";

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, `trades/${tradeId}`),
          acceptedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    await Promise.all([
      reconcileTradeAggregates(adminDb, tradeId),
      reconcileTradeAggregates(adminDb, tradeId),
    ]);

    await assertAggregateMatchesTrade(tradeId);
    const aliceRes = await readReservation(ALICE, COLLECTION_ID, "1");
    assert.equal(aliceRes.outgoing, 1);
    assert.equal(await readUserCompleted(ALICE), 0);
  });

  it("accepted→completed during backfill-style sequential reconcile", async () => {
    const tradeId = "t_accept_then_complete_backfill";

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, `trades/${tradeId}`),
          acceptedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });
    await reconcileTradeAggregates(adminDb, tradeId);

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, `trades/${tradeId}`),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });
    // Second pass as if backfill / delayed callback.
    await reconcileTradeAggregates(adminDb, tradeId);

    await assertAggregateMatchesTrade(tradeId);
    assert.equal(await readUserCompleted(ALICE), 1);
    assert.equal(await readUserCompleted(BOB), 1);
    assertNoActiveReservation(await readReservation(ALICE, COLLECTION_ID, "1"));
  });
});

describe("multi-trade shared reservation concurrency", () => {
  it("two trades on same user+collection+itemKey sum and release independently", async () => {
    const item = {
      itemId: "item_shared",
      itemNumber: "42",
      collectionId: COLLECTION_ID,
      quantity: 1,
    };

    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [ALICE, BOB, CAROL]);
      await setDoc(
          doc(firestore, "trades/t_shared_a"),
          acceptedTrade({
            senderId: ALICE,
            receiverId: BOB,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_b1",
                itemNumber: "10",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
      await setDoc(
          doc(firestore, "trades/t_shared_b"),
          acceptedTrade({
            senderId: ALICE,
            receiverId: CAROL,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_c1",
                itemNumber: "11",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
    });

    await Promise.all([
      reconcileTradeAggregates(adminDb, "t_shared_a"),
      reconcileTradeAggregates(adminDb, "t_shared_b"),
    ]);

    let aliceShared = await readReservation(ALICE, COLLECTION_ID, "42");
    assert.equal(aliceShared.outgoing, 2, "both trade contributions must sum");

    // Complete trade A only.
    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_shared_a"),
          completedTrade({
            senderId: ALICE,
            receiverId: BOB,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_b1",
                itemNumber: "10",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
    });
    await reconcileTradeAggregates(adminDb, "t_shared_a");

    aliceShared = await readReservation(ALICE, COLLECTION_ID, "42");
    assert.equal(
        aliceShared.outgoing,
        1,
        "trade B contribution must remain after A completes",
    );

    await assertAggregateMatchesTrade("t_shared_a");
    await assertAggregateMatchesTrade("t_shared_b");
    assert.equal(await readUserCompleted(ALICE), 1);
    assert.equal(await readUserCompleted(BOB), 1);
    assert.equal(await readUserCompleted(CAROL), 0);
  });
});

describe("preflight + backfill fixtures", () => {
  it("SAFE_FAST_PATH when completedTrades are zero and no reservations", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore);
      await setDoc(
          doc(firestore, "trades/t_bf_1"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    const report = await runPreflight(adminDb);
    assert.equal(report.decision, "SAFE_FAST_PATH");
    assert.equal(report.safeForIncrementalBackfill, true);

    const trades = await adminDb.collection("trades").get();
    const dry = await dryRunSummary(adminDb, trades.docs);
    assert.equal(dry.expectedCompletedCounts[ALICE], 1);
    assert.equal(dry.expectedCompletedCounts[BOB], 1);

    const written = await writeReconcileAll(adminDb, trades.docs);
    assert.equal(written.reconciled, 1);
    assert.equal(await readUserCompleted(ALICE), 1);

    // Idempotent re-run.
    await writeReconcileAll(adminDb, trades.docs);
    assert.equal(await readUserCompleted(ALICE), 1);
  });

  it("ABORT when any completedTrades is non-zero", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(doc(firestore, `users/${ALICE}`), {
        uid: ALICE,
        completedTrades: 3,
      });
      await setDoc(doc(firestore, `users/${BOB}`), {
        uid: BOB,
        completedTrades: 0,
      });
    });

    const report = await runPreflight(adminDb);
    assert.equal(report.decision, "ABORT_NONZERO_COMPLETED_TRADES");
    assert.equal(report.safeForIncrementalBackfill, false);
    assert.equal(report.completedTradesPositive, 1);
  });

  it("ABORT when reservationCollections items already exist", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore);
      await setDoc(
          doc(
              firestore,
              `users/${ALICE}/reservationCollections/${COLLECTION_ID}/items/${encodeItemKey("1")}`,
          ),
          {
            collectionId: COLLECTION_ID,
            itemNumber: "1",
            itemKey: encodeItemKey("1"),
            outgoing: 1,
            incoming: 0,
          },
      );
    });

    const report = await runPreflight(adminDb);
    assert.equal(report.decision, "ABORT_EXISTING_RESERVATIONS");
    assert.equal(report.safeForIncrementalBackfill, false);
  });

  it("legacy oversized trade is ANOMALY / MANUAL REVIEW with no partial write", async () => {
    const oversizedOffered = Array.from({length: 51}, (_, index) => ({
      itemId: `item_${index + 1}`,
      itemNumber: String(index + 1),
      collectionId: COLLECTION_ID,
      quantity: 1,
    }));

    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore);
      await setDoc(
          doc(firestore, "trades/t_legacy_oversized"),
          acceptedTrade({
            senderId: ALICE,
            receiverId: BOB,
            offeredItems: oversizedOffered,
            requestedItems: [
              {
                itemId: "item_req",
                itemNumber: "999",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
    });

    let threw = null;
    try {
      await reconcileTradeAggregates(adminDb, "t_legacy_oversized");
    } catch (error) {
      threw = error;
    }

    assert.ok(threw);
    assert.equal(threw.code, "trade_item_limit_exceeded");
    assert.equal(anomalyTypeForError(threw), "ANOMALY / MANUAL REVIEW");
    assert.equal(await readState("t_legacy_oversized"), null);
    assert.equal(await readUserCompleted(ALICE), 0);
    assert.equal(await readReservation(ALICE, COLLECTION_ID, "1"), null);

    const trades = await adminDb.collection("trades").get();
    const dry = await dryRunSummary(adminDb, trades.docs);
    assert.equal(dry.anomalyCount, 1);
    assert.equal(dry.anomalies[0].type, "ANOMALY / MANUAL REVIEW");

    const written = await writeReconcileAll(adminDb, trades.docs);
    assert.equal(written.reconciled, 0);
    assert.equal(written.anomalyCount, 1);
    assert.equal(written.anomalies[0].type, "ANOMALY / MANUAL REVIEW");
    assert.equal(await readState("t_legacy_oversized"), null);
  });
});

describe("reservation non-negativity + zero-doc delete", () => {
  beforeEach(async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore);
    });
  });

  it("A+B concurrent then A completed leaves exactly B; stale A cannot go below B", async () => {
    const item = {
      itemId: "item_shared",
      itemNumber: "77",
      collectionId: COLLECTION_ID,
      quantity: 1,
    };

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_nn_a"),
          acceptedTrade({
            senderId: ALICE,
            receiverId: BOB,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_b1",
                itemNumber: "10",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
      await setDoc(
          doc(firestore, "trades/t_nn_b"),
          acceptedTrade({
            senderId: ALICE,
            receiverId: CAROL,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_c1",
                itemNumber: "11",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
    });

    // Real concurrency — not sequential naming.
    await Promise.all([
      reconcileTradeAggregates(adminDb, "t_nn_a"),
      reconcileTradeAggregates(adminDb, "t_nn_b"),
    ]);

    let res = await readReservation(ALICE, COLLECTION_ID, "77");
    assert.equal(res.outgoing, 2);
    assert.ok(res.outgoing >= 0 && res.incoming >= 0);

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_nn_a"),
          completedTrade({
            senderId: ALICE,
            receiverId: BOB,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_b1",
                itemNumber: "10",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
    });
    await reconcileTradeAggregates(adminDb, "t_nn_a");

    res = await readReservation(ALICE, COLLECTION_ID, "77");
    assert.equal(res.outgoing, 1);

    // B: stale completed/accepted reconcile for A must not drop below B.
    await Promise.all([
      reconcileTradeAggregates(adminDb, "t_nn_a"),
      reconcileTradeAggregates(adminDb, "t_nn_a"),
    ]);
    res = await readReservation(ALICE, COLLECTION_ID, "77");
    assert.equal(res.outgoing, 1);
    assert.ok(res.outgoing >= 0);

    // C: duplicate completion reconcile — still non-negative.
    await reconcileTradeAggregates(adminDb, "t_nn_a");
    res = await readReservation(ALICE, COLLECTION_ID, "77");
    assert.equal(res.outgoing, 1);
    assert.ok((res.outgoing || 0) >= 0);
    assert.ok((res.incoming || 0) >= 0);
  });

  it("completing sole reservation deletes the zero document", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_zero_delete"),
          acceptedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });
    await reconcileTradeAggregates(adminDb, "t_zero_delete");
    assert.ok(await readReservation(ALICE, COLLECTION_ID, "1"));

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_zero_delete"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });
    await reconcileTradeAggregates(adminDb, "t_zero_delete");
    assertNoActiveReservation(await readReservation(ALICE, COLLECTION_ID, "1"));
  });

  it("D: corrupted state underflow fails atomically without erasing other trade", async () => {
    const item = {
      itemId: "item_shared",
      itemNumber: "88",
      collectionId: COLLECTION_ID,
      quantity: 1,
    };
    const errors = [];
    const logger = {
      error: (payload) => errors.push(payload),
      warn: (payload) => errors.push(payload),
    };

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_uf_a"),
          acceptedTrade({
            senderId: ALICE,
            receiverId: BOB,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_b1",
                itemNumber: "10",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
      await setDoc(
          doc(firestore, "trades/t_uf_b"),
          acceptedTrade({
            senderId: ALICE,
            receiverId: CAROL,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_c1",
                itemNumber: "11",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
    });

    await Promise.all([
      reconcileTradeAggregates(adminDb, "t_uf_a"),
      reconcileTradeAggregates(adminDb, "t_uf_b"),
    ]);

    assert.equal((await readReservation(ALICE, COLLECTION_ID, "88")).outgoing, 2);

    // Inflate trade A state contribution beyond the live shared reservation.
    const itemKey = encodeItemKey("88");
    const mapKey = `${COLLECTION_ID}::${itemKey}`;
    const corruptedState = {
      completedContribution: 0,
      senderId: ALICE,
      receiverId: BOB,
      senderReservations: {
        [mapKey]: {
          outgoing: 5,
          incoming: 0,
          collectionId: COLLECTION_ID,
          itemNumber: "88",
          itemId: "item_shared",
          itemKey,
        },
      },
      receiverReservations: {},
      updatedAt: new Date(),
      tradeExists: true,
    };
    await adminDb.collection(STATE_COLLECTION).doc("t_uf_a").set(corruptedState);

    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_uf_a"),
          completedTrade({
            senderId: ALICE,
            receiverId: BOB,
            offeredItems: [item],
            requestedItems: [
              {
                itemId: "item_b1",
                itemNumber: "10",
                collectionId: COLLECTION_ID,
                quantity: 1,
              },
            ],
          }),
      );
    });

    let threw = null;
    try {
      await reconcileTradeAggregates(adminDb, "t_uf_a", {logger});
    } catch (error) {
      threw = error;
    }

    assert.ok(threw);
    assert.equal(threw.code, "reservation_aggregate_underflow");
    assert.equal(anomalyTypeForError(threw), "ANOMALY / MANUAL REVIEW");
    assert.ok(
        errors.some((entry) => entry.event === "reservation_aggregate_underflow"),
    );

    // Atomic abort: reservation and corrupted state unchanged; B survives.
    assert.equal((await readReservation(ALICE, COLLECTION_ID, "88")).outgoing, 2);
    const stateAfter = await readState("t_uf_a");
    assert.equal(stateAfter.senderReservations[mapKey].outgoing, 5);
    assert.equal(await readUserCompleted(ALICE), 0);
    assert.equal(await readUserCompleted(BOB), 0);

    const written = await writeReconcileAll(
        adminDb,
        [await adminDb.collection("trades").doc("t_uf_a").get()],
    );
    assert.equal(written.reconciled, 0);
    assert.equal(written.anomalyCount, 1);
    assert.equal(written.anomalies[0].type, "ANOMALY / MANUAL REVIEW");
    assert.equal((await readReservation(ALICE, COLLECTION_ID, "88")).outgoing, 2);
  });
});

describe("production script guards", () => {
  it("write mode requires project double-confirm for non-emulator", async () => {
    const previous = process.env.FIRESTORE_EMULATOR_HOST;
    delete process.env.FIRESTORE_EMULATOR_HOST;

    try {
      assert.throws(
          () => assertProductionGuards({
            allowProduction: true,
            project: EXPECTED_PRODUCTION_PROJECT,
            confirmProject: "",
          }, "write"),
          /confirm-project/,
      );

      assert.throws(
          () => assertProductionGuards({
            allowProduction: true,
            project: "wrong-project",
            confirmProject: "wrong-project",
          }, "write"),
          /swapstash-49199/,
      );

      assert.throws(
          () => assertProductionGuards({
            allowProduction: true,
            project: EXPECTED_PRODUCTION_PROJECT,
            confirmProject: EXPECTED_PRODUCTION_PROJECT,
            confirmAuthoritative: false,
          }, "authoritative-rebuild"),
          /confirm-authoritative-rebuild/,
      );

      assert.doesNotThrow(() => assertProductionGuards({
        allowProduction: true,
        project: EXPECTED_PRODUCTION_PROJECT,
        confirmProject: EXPECTED_PRODUCTION_PROJECT,
      }, "write"));
    } finally {
      if (previous === undefined) {
        delete process.env.FIRESTORE_EMULATOR_HOST;
      } else {
        process.env.FIRESTORE_EMULATOR_HOST = previous;
      }
    }
  });
});

describe("Admin delete completed trade retains lifetime count", () => {
  it("does not decrement completedTrades when completed trade doc is deleted", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore);
      await setDoc(
          doc(firestore, "trades/t_admin_delete"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    await reconcileTradeAggregates(adminDb, "t_admin_delete");
    assert.equal(await readUserCompleted(ALICE), 1);
    assert.equal(await readUserCompleted(BOB), 1);

    await adminDb.collection("trades").doc("t_admin_delete").delete();
    await reconcileTradeAggregates(adminDb, "t_admin_delete");

    assert.equal(await readUserCompleted(ALICE), 1);
    assert.equal(await readUserCompleted(BOB), 1);
    const state = await readState("t_admin_delete");
    assert.equal(state.completedContribution, 1);
  });
});

describe("P22C1 orphan / missing-user matrix", () => {
  async function assertUserAbsent(uid) {
    const snap = await adminDb.collection("users").doc(uid).get();
    assert.equal(snap.exists, false, `user ${uid} must remain absent`);
  }

  async function assertNoReservationSubtree(uid) {
    // Parent listing misses orphan subcollections; probe the fixture path.
    const items = await adminDb
        .collection("users")
        .doc(uid)
        .collection("reservationCollections")
        .doc(COLLECTION_ID)
        .collection("items")
        .get();
    assert.equal(
        items.size,
        0,
        `no reservation items under missing user ${uid}`,
    );
  }

  it("A: completed trade, both users exist", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [ALICE, BOB]);
      await setDoc(
          doc(firestore, "trades/t_orphan_a"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    const result = await reconcileTradeAggregates(adminDb, "t_orphan_a");
    assert.equal(result.noop, false);
    assert.equal(result.skippedCompletedUserWrites, 0);
    assert.equal(await readUserCompleted(ALICE), 1);
    assert.equal(await readUserCompleted(BOB), 1);
    const state = await readState("t_orphan_a");
    assert.equal(state.completedContribution, 1);
  });

  it("B: completed trade, sender missing — no resurrection", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [BOB]);
      await setDoc(
          doc(firestore, "trades/t_orphan_b"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    const result = await reconcileTradeAggregates(adminDb, "t_orphan_b");
    assert.equal(result.orphan.senderMissing, true);
    assert.equal(result.orphan.receiverMissing, false);
    assert.equal(result.skippedCompletedUserWrites, 1);
    assert.equal(await readUserCompleted(BOB), 1);
    await assertUserAbsent(ALICE);
    await assertNoReservationSubtree(ALICE);

    const state = await readState("t_orphan_b");
    assert.equal(state.completedContribution, 1);
    assert.equal(state.senderId, ALICE);
    assert.equal(state.receiverId, BOB);
  });

  it("C: completed trade, receiver missing — no resurrection", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [ALICE]);
      await setDoc(
          doc(firestore, "trades/t_orphan_c"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    const result = await reconcileTradeAggregates(adminDb, "t_orphan_c");
    assert.equal(result.orphan.receiverMissing, true);
    assert.equal(result.skippedCompletedUserWrites, 1);
    assert.equal(await readUserCompleted(ALICE), 1);
    await assertUserAbsent(BOB);
    await assertNoReservationSubtree(BOB);
  });

  it("D: completed trade, both missing — no user docs created", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
          doc(firestore, "trades/t_orphan_d"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    const result = await reconcileTradeAggregates(adminDb, "t_orphan_d");
    assert.equal(result.orphan.senderMissing, true);
    assert.equal(result.orphan.receiverMissing, true);
    assert.equal(result.skippedCompletedUserWrites, 2);
    await assertUserAbsent(ALICE);
    await assertUserAbsent(BOB);

    const state = await readState("t_orphan_d");
    assert.equal(state.completedContribution, 1);
    assert.equal(state.senderId, ALICE);
  });

  it("E: accepted trade, sender missing — no reservations / no resurrection", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [BOB]);
      await setDoc(
          doc(firestore, "trades/t_orphan_e"),
          acceptedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    const result = await reconcileTradeAggregates(adminDb, "t_orphan_e");
    assert.equal(result.orphan.senderMissing, true);
    assert.equal(await readUserCompleted(BOB), 0);
    await assertUserAbsent(ALICE);
    await assertNoReservationSubtree(ALICE);
    await assertNoReservationSubtree(BOB);
    assertNoActiveReservation(await readReservation(BOB, COLLECTION_ID, "1"));
    assertNoActiveReservation(await readReservation(BOB, COLLECTION_ID, "2"));

    const state = await readState("t_orphan_e");
    assert.equal(state.completedContribution, 0);
    assert.deepEqual(state.senderReservations, {});
    assert.deepEqual(state.receiverReservations, {});
  });

  it("F: accepted trade, receiver missing — no reservations / no resurrection", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [ALICE]);
      await setDoc(
          doc(firestore, "trades/t_orphan_f"),
          acceptedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    await reconcileTradeAggregates(adminDb, "t_orphan_f");
    await assertUserAbsent(BOB);
    await assertNoReservationSubtree(BOB);
    await assertNoReservationSubtree(ALICE);
    assertNoActiveReservation(await readReservation(ALICE, COLLECTION_ID, "1"));
  });

  it("G: repeated reconciliation of orphan completed trade is idempotent", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [BOB]);
      await setDoc(
          doc(firestore, "trades/t_orphan_g"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    await reconcileTradeAggregates(adminDb, "t_orphan_g");
    assert.equal(await readUserCompleted(BOB), 1);
    await assertUserAbsent(ALICE);

    const second = await reconcileTradeAggregates(adminDb, "t_orphan_g");
    assert.equal(second.noop, true);
    assert.equal(await readUserCompleted(BOB), 1);
    await assertUserAbsent(ALICE);

    const third = await reconcileTradeAggregates(adminDb, "t_orphan_g");
    assert.equal(third.noop, true);
    assert.equal(await readUserCompleted(BOB), 1);
    await assertUserAbsent(ALICE);
  });

  it("H: completed→cancelled transition clears contribution without resurrecting", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [BOB]);
      await setDoc(
          doc(firestore, "trades/t_orphan_h"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    await reconcileTradeAggregates(adminDb, "t_orphan_h");
    assert.equal(await readUserCompleted(BOB), 1);
    await assertUserAbsent(ALICE);

    await adminDb.collection("trades").doc("t_orphan_h").set({
      status: "cancelled",
      awaitingUserId: "",
    }, {merge: true});

    const result = await reconcileTradeAggregates(adminDb, "t_orphan_h");
    assert.equal(result.noop, false);
    // Lifetime retain: completed→non-completed with trade still present
    // applies delta -1 to surviving user only; missing sender stays absent.
    assert.equal(await readUserCompleted(BOB), 0);
    await assertUserAbsent(ALICE);

    const state = await readState("t_orphan_h");
    assert.equal(state.completedContribution, 0);
  });

  it("dry-run counts skipped missing-user increments (same policy as write)", async () => {
    await seed(testEnv, async (firestore) => {
      await seedUsers(firestore, [BOB]);
      await setDoc(
          doc(firestore, "trades/t_orphan_dry"),
          completedTrade({senderId: ALICE, receiverId: BOB}),
      );
    });

    const trades = await adminDb.collection("trades").get();
    const dry = await dryRunSummary(adminDb, trades.docs);
    assert.equal(dry.orphanTradeCount, 1);
    assert.equal(dry.orphanMissingSenderCount, 1);
    assert.equal(dry.completedIncrementsForExistingUsers, 1);
    assert.equal(dry.completedIncrementsSkippedMissingUsers, 1);
    assert.equal(dry.expectedCompletedCounts[BOB], 1);
    assert.equal(dry.expectedCompletedCounts[ALICE], undefined);

    const report = await runPreflight(adminDb);
    assert.equal(report.orphanTradeCount, 1);
    assert.equal(report.orphanMissingSenderCount, 1);
    assert.equal(report.decision, "SAFE_FAST_PATH");
  });
});
