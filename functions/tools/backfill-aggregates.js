"use strict";

/**
 * P22A2B aggregate backfill — uses the SAME reconcileTradeAggregates engine.
 *
 * Modes:
 *   --mode dry-run   No writes. Summary of expected contributions / anomalies.
 *   --mode write     Requires successful pre-flight (§1 + §2). Idempotent.
 *   --mode authoritative-rebuild
 *                    ONLY when pre-flight reports NONZERO completedTrades.
 *                    Resets completedTrades to 0, clears reservation + state
 *                    docs, then reconciles every trade. Explicit product
 *                    decision required — not the default path.
 *
 * Production WRITE safety (non-emulator):
 *   --allow-production
 *   --project swapstash-49199
 *   --confirm-project swapstash-49199
 * Authoritative rebuild additionally requires:
 *   --confirm-authoritative-rebuild
 *
 * DO NOT run against production from the P22A2B implementation task.
 */

const {initializeApp, getApps} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

const {
  reconcileTradeAggregates,
  previewReconcile,
  contributionFromTrade,
  anomalyTypeForError,
  STATE_COLLECTION,
} = require("../lib/tradeAggregates");
const {runPreflight} = require("./preflight-aggregates");

const EXPECTED_PRODUCTION_PROJECT = "swapstash-49199";

function parseArgs(argv) {
  const args = {
    project: process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || "",
    mode: "dry-run",
    allowProduction: false,
    confirmProject: "",
    confirmAuthoritative: false,
    limit: 0,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--project" && argv[i + 1]) {
      args.project = argv[++i];
    } else if (arg === "--mode" && argv[i + 1]) {
      args.mode = argv[++i];
    } else if (arg === "--allow-production") {
      args.allowProduction = true;
    } else if (arg === "--confirm-project" && argv[i + 1]) {
      args.confirmProject = argv[++i];
    } else if (arg === "--confirm-authoritative-rebuild") {
      args.confirmAuthoritative = true;
    } else if (arg === "--limit" && argv[i + 1]) {
      args.limit = Number(argv[++i]) || 0;
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    }
  }
  return args;
}

function isEmulator() {
  return Boolean(process.env.FIRESTORE_EMULATOR_HOST);
}

/**
 * WRITE / authoritative production guard. Dry-run against production still
 * needs --allow-production but not project double-confirm.
 * @param {object} args
 * @param {"dry-run"|"write"|"authoritative-rebuild"} mode
 */
function assertProductionGuards(args, mode) {
  if (isEmulator()) {
    return;
  }

  if (!args.allowProduction) {
    throw new Error(
        "ABORT: FIRESTORE_EMULATOR_HOST unset. Pass --allow-production " +
        "only for an intentional live run.",
    );
  }

  if (mode === "dry-run") {
    return;
  }

  if (!args.project) {
    throw new Error("ABORT: --project is required for production writes.");
  }

  if (!args.confirmProject) {
    throw new Error(
        "ABORT: --confirm-project is required for production writes.",
    );
  }

  if (args.project !== args.confirmProject) {
    throw new Error(
        `ABORT: --project (${args.project}) does not match ` +
        `--confirm-project (${args.confirmProject}).`,
    );
  }

  if (args.project !== EXPECTED_PRODUCTION_PROJECT ||
      args.confirmProject !== EXPECTED_PRODUCTION_PROJECT) {
    throw new Error(
        `ABORT: production writes only allowed for ` +
        `${EXPECTED_PRODUCTION_PROJECT} (got project=${args.project}, ` +
        `confirm=${args.confirmProject}).`,
    );
  }

  if (mode === "authoritative-rebuild" && !args.confirmAuthoritative) {
    throw new Error(
        "ABORT: production authoritative rebuild requires " +
        "--confirm-authoritative-rebuild in addition to production flags.",
    );
  }
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {number} limit
 * @return {Promise<FirebaseFirestore.QueryDocumentSnapshot[]>}
 */
async function listTrades(db, limit) {
  let query = db.collection("trades");
  if (limit > 0) {
    query = query.limit(limit);
  }
  const snap = await query.get();
  return snap.docs;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {FirebaseFirestore.QueryDocumentSnapshot[]} tradeDocs
 * @return {Promise<object>}
 */
async function dryRunSummary(db, tradeDocs) {
  const expectedCompletedByUser = {};
  const expectedReservationDocs = new Map();
  const orphans = [];
  const anomalies = [];
  const perTrade = [];

  for (const doc of tradeDocs) {
    const trade = doc.data() || {};
    const senderId = String(trade.senderId || "").trim();
    const receiverId = String(trade.receiverId || "").trim();

    const [senderSnap, receiverSnap] = await Promise.all([
      senderId ? db.collection("users").doc(senderId).get() : null,
      receiverId ? db.collection("users").doc(receiverId).get() : null,
    ]);

    const senderExists = senderSnap ? senderSnap.exists : false;
    const receiverExists = receiverSnap ? receiverSnap.exists : false;

    if (!senderExists || !receiverExists) {
      orphans.push({
        tradeId: doc.id,
        senderId,
        receiverId,
        senderExists,
        receiverExists,
        status: trade.status,
      });
    }

    const preview = await previewReconcile(db, doc.id);
    if (preview.anomaly) {
      anomalies.push({
        type: preview.anomaly,
        tradeId: doc.id,
        code: preview.anomalyCode,
        message: preview.anomalyMessage,
        status: trade.status,
      });
      perTrade.push({
        tradeId: doc.id,
        status: trade.status,
        anomaly: preview.anomaly,
        anomalyCode: preview.anomalyCode,
      });
      continue;
    }

    const desired = contributionFromTrade(trade, {
      senderExists,
      receiverExists,
    });

    if (desired.completedContribution === 1) {
      if (senderId) {
        expectedCompletedByUser[senderId] =
          (expectedCompletedByUser[senderId] || 0) + 1;
      }
      if (receiverId) {
        expectedCompletedByUser[receiverId] =
          (expectedCompletedByUser[receiverId] || 0) + 1;
      }
    }

    const addExpected = (uid, map) => {
      if (!uid) {
        return;
      }
      for (const entry of Object.values(map || {})) {
        const path =
          `users/${uid}/reservationCollections/${entry.collectionId}` +
          `/items/${entry.itemKey}`;
        const current = expectedReservationDocs.get(path) || {
          path,
          outgoing: 0,
          incoming: 0,
          collectionId: entry.collectionId,
          itemNumber: entry.itemNumber,
          itemKey: entry.itemKey,
        };
        current.outgoing += entry.outgoing || 0;
        current.incoming += entry.incoming || 0;
        expectedReservationDocs.set(path, current);
      }
    };

    addExpected(desired.senderId, desired.senderReservations);
    addExpected(desired.receiverId, desired.receiverReservations);

    if (String(trade.status) === "accepted" &&
        (!senderExists || !receiverExists)) {
      anomalies.push({
        type: "accepted_orphan_no_reservations",
        tradeId: doc.id,
      });
    }

    perTrade.push({
      tradeId: doc.id,
      status: trade.status,
      noop: preview.noop,
      completedContribution: desired.completedContribution,
      senderReservationKeys: Object.keys(desired.senderReservations).length,
      receiverReservationKeys: Object.keys(desired.receiverReservations).length,
    });
  }

  return {
    tradeCount: tradeDocs.length,
    orphanTrades: orphans,
    anomalyCount: anomalies.length,
    anomalies,
    expectedCompletedCounts: expectedCompletedByUser,
    expectedReservationDocumentCount: expectedReservationDocs.size,
    expectedReservationDocuments: [...expectedReservationDocs.values()],
    perTrade,
  };
}

/**
 * @param {FirebaseFirestore.Firestore} db
 */
async function clearAggregateArtifacts(db) {
  const stateSnap = await db.collection(STATE_COLLECTION).get();
  for (const doc of stateSnap.docs) {
    await doc.ref.delete();
  }

  const reservationSnap = await db.collectionGroup("items")
      .where("itemKey", "!=", null)
      .get();

  for (const doc of reservationSnap.docs) {
    if (!doc.ref.path.includes("/reservationCollections/")) {
      continue;
    }
    await doc.ref.delete();
  }

  const usersSnap = await db.collection("users").get();
  for (const doc of usersSnap.docs) {
    await doc.ref.set({completedTrades: 0}, {merge: true});
  }
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {FirebaseFirestore.QueryDocumentSnapshot[]} tradeDocs
 * @return {Promise<object>}
 */
async function writeReconcileAll(db, tradeDocs) {
  const results = [];
  const anomalies = [];

  for (const doc of tradeDocs) {
    try {
      const result = await reconcileTradeAggregates(db, doc.id);
      results.push({
        tradeId: doc.id,
        noop: result.noop,
        appliedCompletedDelta: result.appliedCompletedDelta || 0,
        status: result.effectiveTradeStatus,
      });
    } catch (error) {
      const anomaly = anomalyTypeForError(error);
      if (anomaly) {
        anomalies.push({
          type: anomaly,
          tradeId: doc.id,
          code: error.code,
          message: error.message,
        });
        continue;
      }
      throw error;
    }
  }

  return {
    reconciled: results.length,
    anomalyCount: anomalies.length,
    anomalies,
    results,
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (args.help) {
    console.log(`Usage: node tools/backfill-aggregates.js --mode <dry-run|write|authoritative-rebuild>

Options:
  --project <id>
  --mode dry-run|write|authoritative-rebuild
  --allow-production
  --confirm-project swapstash-49199   (required for production WRITE)
  --confirm-authoritative-rebuild     (required for authoritative rebuild)
  --limit <n>
`);
    process.exit(0);
  }

  try {
    assertProductionGuards(args, args.mode);
  } catch (error) {
    console.error(error.message);
    process.exit(2);
  }

  if (!getApps().length) {
    initializeApp(args.project ? {projectId: args.project} : undefined);
  }

  const db = getFirestore();
  const preflight = await runPreflight(db);
  const tradeDocs = await listTrades(db, args.limit);

  if (args.mode === "dry-run") {
    const summary = await dryRunSummary(db, tradeDocs);
    console.log(JSON.stringify({
      mode: "dry-run",
      preflight,
      summary,
      note: "No writes performed.",
      lifetimeInvariant:
        "completedTrades is lifetime. Physically deleting completed " +
        "/trades docs prevents authoritative rebuild from reconstructing " +
        "the true lifetime count unless a separate archive exists.",
    }, null, 2));
    process.exit(preflight.safeForIncrementalBackfill ? 0 : 1);
  }

  if (args.mode === "write") {
    if (!preflight.safeForIncrementalBackfill) {
      console.error("ABORT: pre-flight failed. " + preflight.message);
      console.error(JSON.stringify(preflight, null, 2));
      process.exit(1);
    }

    const summary = await dryRunSummary(db, tradeDocs);
    console.log(JSON.stringify({
      mode: "write-precheck",
      preflight,
      anomalyCount: summary.anomalyCount,
      anomalies: summary.anomalies,
    }, null, 2));

    const writeResult = await writeReconcileAll(db, tradeDocs);
    console.log(JSON.stringify({
      mode: "write",
      preflight,
      writeResult,
    }, null, 2));
    process.exit(writeResult.anomalyCount > 0 ? 1 : 0);
  }

  if (args.mode === "authoritative-rebuild") {
    if (preflight.decision === "ABORT_EXISTING_RESERVATIONS") {
      console.error(
          "ABORT: existing reservation docs present. Clear or inspect them " +
          "before authoritative rebuild.",
      );
      process.exit(1);
    }

    if (preflight.safeForIncrementalBackfill) {
      console.error(
          "Authoritative rebuild is unnecessary when SAFE_FAST_PATH applies. " +
          "Use --mode write instead.",
      );
      process.exit(1);
    }

    if (preflight.decision !== "ABORT_NONZERO_COMPLETED_TRADES") {
      console.error(
          "ABORT: authoritative rebuild is only for NONZERO completedTrades " +
          `baseline (decision=${preflight.decision}).`,
      );
      process.exit(1);
    }

    if (!args.confirmAuthoritative) {
      console.error(
          "ABORT: pass --confirm-authoritative-rebuild after product review.",
      );
      process.exit(1);
    }

    const summary = await dryRunSummary(db, tradeDocs);
    console.log(JSON.stringify({
      mode: "authoritative-rebuild-precheck",
      preflight,
      anomalyCount: summary.anomalyCount,
      anomalies: summary.anomalies,
      warning:
        "Rebuild from currently retained /trades only. Physically deleted " +
        "completed trades are permanently missing from lifetime counts.",
    }, null, 2));

    if (summary.anomalyCount > 0) {
      console.error(
          "ABORT: anomalies present (oversized/invalid trades). Resolve or " +
          "exclude them before authoritative rebuild. No override in V1.",
      );
      process.exit(1);
    }

    await clearAggregateArtifacts(db);
    const writeResult = await writeReconcileAll(db, tradeDocs);
    console.log(JSON.stringify({
      mode: "authoritative-rebuild",
      preflight,
      writeResult,
      warning:
        "completedTrades were reset to 0 then rebuilt from current trades. " +
        "This assumes retained completed trade documents are the authority.",
    }, null, 2));
    process.exit(writeResult.anomalyCount > 0 ? 1 : 0);
  }

  console.error(`Unknown mode: ${args.mode}`);
  process.exit(2);
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = {
  EXPECTED_PRODUCTION_PROJECT,
  assertProductionGuards,
  dryRunSummary,
  writeReconcileAll,
  clearAggregateArtifacts,
};
