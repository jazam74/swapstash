#!/usr/bin/env node
"use strict";

/**
 * P22H1 — Firebase Hosting configuration guard for the Flutter SwapStash repo.
 *
 * Runs without Firebase credentials. Exit 0 = safe; exit 1 = fail.
 *
 * Invariants:
 * - Flutter hosting uses only target `app`
 * - `.firebaserc` maps `app` → `swapstash-app-49199`
 * - No `website` hosting target
 * - No untargeted hosting config (would hit the default marketing site)
 * - Default marketing site `swapstash-49199` is never a Flutter hosting site
 */

const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..");
const FIREBASE_JSON = path.join(ROOT, "firebase.json");
const FIREBASERC = path.join(ROOT, ".firebaserc");

const EXPECTED_PROJECT = "swapstash-49199";
const EXPECTED_TARGET = "app";
const EXPECTED_SITE = "swapstash-app-49199";
const FORBIDDEN_TARGET = "website";
const MARKETING_DEFAULT_SITE = "swapstash-49199";

const failures = [];

function fail(message) {
  failures.push(message);
}

function readJson(filePath) {
  const raw = fs.readFileSync(filePath, "utf8");
  try {
    return {raw, data: JSON.parse(raw)};
  } catch (error) {
    fail(`${path.basename(filePath)} is not valid JSON: ${error.message}`);
    return {raw, data: null};
  }
}

function normalizeHosting(hosting) {
  if (hosting == null) {
    return [];
  }
  return Array.isArray(hosting) ? hosting : [hosting];
}

function main() {
  if (!fs.existsSync(FIREBASE_JSON)) {
    fail("firebase.json is missing");
  }
  if (!fs.existsSync(FIREBASERC)) {
    fail(".firebaserc is missing");
  }

  if (failures.length) {
    reportAndExit();
  }

  const firebase = readJson(FIREBASE_JSON);
  const rc = readJson(FIREBASERC);

  if (!firebase.data || !rc.data) {
    reportAndExit();
  }

  // Raw-text footguns JSON.parse would silently collapse.
  if (/"target"\s*:\s*"website"/.test(firebase.raw)) {
    fail('firebase.json must not contain hosting target "website"');
  }

  if (/"target"\s*:\s*"website"[\s\S]*"target"\s*:\s*"app"/.test(firebase.raw) ||
      /"target"\s*:\s*"app"[\s\S]*"target"\s*:\s*"website"/.test(firebase.raw)) {
    fail("firebase.json has conflicting duplicate hosting target keys");
  }

  const hostingEntries = normalizeHosting(firebase.data.hosting);

  if (hostingEntries.length === 0) {
    fail("firebase.json has no hosting configuration");
  }

  if (hostingEntries.length !== 1) {
    fail(
        `firebase.json must contain exactly one Flutter hosting config ` +
        `(found ${hostingEntries.length})`,
    );
  }

  for (const [index, entry] of hostingEntries.entries()) {
    if (!entry || typeof entry !== "object") {
      fail(`hosting[${index}] is not an object`);
      continue;
    }

    if (!Object.prototype.hasOwnProperty.call(entry, "target") ||
        entry.target == null ||
        entry.target === "") {
      fail(
          `hosting[${index}] is missing target — untargeted hosting would ` +
          `deploy to the default marketing site (${MARKETING_DEFAULT_SITE})`,
      );
    }

    if (entry.target === FORBIDDEN_TARGET) {
      fail(`hosting[${index}] uses forbidden target "${FORBIDDEN_TARGET}"`);
    }

    if (entry.target !== EXPECTED_TARGET) {
      fail(
          `hosting[${index}].target must be "${EXPECTED_TARGET}" ` +
          `(found ${JSON.stringify(entry.target)})`,
      );
    }

    if (entry.public !== "build/web") {
      fail(
          `hosting[${index}].public must be "build/web" ` +
          `(found ${JSON.stringify(entry.public)})`,
      );
    }

    if (entry.site === MARKETING_DEFAULT_SITE) {
      fail(
          `hosting[${index}] must not set site to marketing default ` +
          `${MARKETING_DEFAULT_SITE}`,
      );
    }
  }

  const hasAppTarget = hostingEntries.some(
      (entry) => entry && entry.target === EXPECTED_TARGET,
  );
  if (!hasAppTarget) {
    fail(`firebase.json must include hosting target "${EXPECTED_TARGET}"`);
  }

  // Preserve P22 wiring — fail loudly if accidentally dropped.
  if (!firebase.data.firestore ||
      firebase.data.firestore.rules !== "firestore.rules" ||
      firebase.data.firestore.indexes !== "firestore.indexes.json") {
    fail("firebase.json must keep firestore.rules + firestore.indexes.json");
  }
  if (!firebase.data.storage || firebase.data.storage.rules !== "storage.rules") {
    fail("firebase.json must keep storage.rules");
  }
  if (!Array.isArray(firebase.data.functions) ||
      firebase.data.functions.length < 1) {
    fail("firebase.json must keep functions configuration");
  }

  const defaultProject = rc.data.projects && rc.data.projects.default;
  if (defaultProject !== EXPECTED_PROJECT) {
    fail(
        `.firebaserc default project must be ${EXPECTED_PROJECT} ` +
        `(found ${JSON.stringify(defaultProject)})`,
    );
  }

  const hostingTargets =
    (((rc.data.targets || {})[EXPECTED_PROJECT] || {}).hosting) || {};

  if (Object.prototype.hasOwnProperty.call(hostingTargets, FORBIDDEN_TARGET)) {
    fail(`.firebaserc must not map hosting target "${FORBIDDEN_TARGET}"`);
  }

  const appSites = hostingTargets[EXPECTED_TARGET];
  if (!Array.isArray(appSites) || appSites.length !== 1) {
    fail(
        `.firebaserc must map hosting.${EXPECTED_TARGET} to exactly one site`,
    );
  } else if (appSites[0] !== EXPECTED_SITE) {
    fail(
        `.firebaserc hosting.${EXPECTED_TARGET} must be [${EXPECTED_SITE}] ` +
        `(found ${JSON.stringify(appSites)})`,
    );
  }

  for (const [targetName, sites] of Object.entries(hostingTargets)) {
    if (!Array.isArray(sites)) {
      continue;
    }
    if (sites.includes(MARKETING_DEFAULT_SITE)) {
      fail(
          `.firebaserc hosting.${targetName} must not include marketing ` +
          `default site ${MARKETING_DEFAULT_SITE}`,
      );
    }
  }

  reportAndExit();
}

function reportAndExit() {
  if (failures.length) {
    console.error("P22H1 Firebase Hosting config guard FAILED:");
    for (const message of failures) {
      console.error(`  - ${message}`);
    }
    process.exit(1);
  }

  console.log("P22H1 Firebase Hosting config guard PASS");
  console.log(`  project: ${EXPECTED_PROJECT}`);
  console.log(`  target: ${EXPECTED_TARGET} -> ${EXPECTED_SITE}`);
  console.log(
      `  marketing default site ${MARKETING_DEFAULT_SITE} is NOT a Flutter target`,
  );
  process.exit(0);
}

main();
