"use strict";

/**
 * P22A2B pre-flight check for aggregate backfill safety.
 *
 * Reports completedTrades distribution and whether any
 * reservationCollections items already exist.
 *
 * Usage (emulator):
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 \
 *     node tools/preflight-aggregates.js --project swapstash-rules-test
 *
 * DO NOT run against production from this task without an explicit decision.
 * Pass --allow-production only after reviewing credentials and intent.
 */

const {initializeApp, getApps} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

function parseArgs(argv) {
  const args = {
    project: process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || "",
    allowProduction: false,
    json: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--project" && argv[i + 1]) {
      args.project = argv[++i];
    } else if (arg === "--allow-production") {
      args.allowProduction = true;
    } else if (arg === "--json") {
      args.json = true;
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
 * @param {FirebaseFirestore.Firestore} db
 * @return {Promise<object>}
 */
async function runCompletedTradesPreflight(db) {
  const usersSnap = await db.collection("users").get();
  let zero = 0;
  let positive = 0;
  let missing = 0;
  let min = null;
  let max = null;
  let sum = 0;
  const nonZeroSamples = [];

  for (const doc of usersSnap.docs) {
    const data = doc.data() || {};
    if (!Object.prototype.hasOwnProperty.call(data, "completedTrades")) {
      missing += 1;
      // Business default is 0 — counts toward safe-fast-path.
      continue;
    }

    const value = Number(data.completedTrades);
    const normalized = Number.isFinite(value) ? value : 0;
    sum += normalized;

    if (min === null || normalized < min) {
      min = normalized;
    }
    if (max === null || normalized > max) {
      max = normalized;
    }

    if (normalized === 0) {
      zero += 1;
    } else if (normalized > 0) {
      positive += 1;
      if (nonZeroSamples.length < 20) {
        nonZeroSamples.push({uid: doc.id, completedTrades: normalized});
      }
    } else {
      // Negative is anomalous — treat as unsafe.
      positive += 1;
      if (nonZeroSamples.length < 20) {
        nonZeroSamples.push({uid: doc.id, completedTrades: normalized});
      }
    }
  }

  const total = usersSnap.size;
  const safeFastPath = positive === 0;

  return {
    users: total,
    completedTradesZero: zero,
    completedTradesPositive: positive,
    completedTradesMissing: missing,
    completedTradesMin: min,
    completedTradesMax: max,
    completedTradesSum: sum,
    safeFastPath,
    nonZeroSamples,
  };
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @return {Promise<object>}
 */
async function runReservationBaselinePreflight(db) {
  // Collection group on leaf `items` under reservationCollections.
  // Inventory items live under collections/*/items and do not carry itemKey.
  const snap = await db.collectionGroup("items")
      .where("itemKey", "!=", null)
      .limit(50)
      .get();

  const reservationDocs = [];
  for (const doc of snap.docs) {
    const path = doc.ref.path;
    if (!path.includes("/reservationCollections/")) {
      continue;
    }
    reservationDocs.push({path, data: doc.data()});
  }

  return {
    existingReservationDocs: reservationDocs.length,
    reservationSamples: reservationDocs.slice(0, 10),
    reservationBaselineClean: reservationDocs.length === 0,
  };
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @return {Promise<object>}
 */
async function runPreflight(db) {
  const completed = await runCompletedTradesPreflight(db);
  const reservations = await runReservationBaselinePreflight(db);

  const safeForIncrementalBackfill =
    completed.safeFastPath && reservations.reservationBaselineClean;

  let decision = "SAFE_FAST_PATH";
  let message =
    "All completedTrades are 0 or missing (default 0) and no " +
    "reservationCollections items exist. Incremental reconcile from empty " +
    "_tradeAggregateState is allowed.";

  if (!reservations.reservationBaselineClean) {
    decision = "ABORT_EXISTING_RESERVATIONS";
    message =
      "STOP: reservationCollections items already exist. Do not mix unknown " +
      "legacy reservation state with the new reconciliation model.";
  } else if (!completed.safeFastPath) {
    decision = "ABORT_NONZERO_COMPLETED_TRADES";
    message =
      "STOP: one or more users have completedTrades != 0. Do NOT run " +
      "incremental backfill. Choose an explicit AUTHORITATIVE REBUILD " +
      "(see tools/backfill-aggregates.js --mode authoritative-rebuild) after " +
      "product review. Non-zero values are neither assumed correct nor wrong.";
  }

  return {
    ...completed,
    ...reservations,
    safeForIncrementalBackfill,
    decision,
    message,
  };
}

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (args.help) {
    console.log(`Usage: node tools/preflight-aggregates.js [options]

Options:
  --project <id>         Firebase project id
  --allow-production     Required if FIRESTORE_EMULATOR_HOST is unset
  --json                 Print JSON only
`);
    process.exit(0);
  }

  if (!isEmulator() && !args.allowProduction) {
    console.error(
        "Refusing to run without FIRESTORE_EMULATOR_HOST. " +
        "Pass --allow-production only for an intentional live check.",
    );
    process.exit(2);
  }

  if (!getApps().length) {
    initializeApp(args.project ? {projectId: args.project} : undefined);
  }

  const db = getFirestore();
  const report = await runPreflight(db);
  report.emulator = isEmulator();
  report.project = args.project || null;

  if (args.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log("=== P22A2B PRE-FLIGHT ===");
    console.log(JSON.stringify(report, null, 2));
  }

  if (!report.safeForIncrementalBackfill) {
    process.exit(1);
  }
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = {
  runPreflight,
  runCompletedTradesPreflight,
  runReservationBaselinePreflight,
};
