import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";

const here = dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);

const {
  RESERVATION_ITEM_KEY_COLLECTION_GROUP,
  RESERVATION_ITEM_KEY_FIELD,
} = require("../functions/tools/preflight-aggregates.js");

describe("P22C1 firestore.indexes.json ↔ preflight query guard", () => {
  it("declares COLLECTION_GROUP fieldOverride for items.itemKey", () => {
    const raw = readFileSync(
        resolve(here, "..", "firestore.indexes.json"),
        "utf8",
    );
    const config = JSON.parse(raw);
    const overrides = config.fieldOverrides || [];
    const match = overrides.find(
        (entry) =>
          entry.collectionGroup === RESERVATION_ITEM_KEY_COLLECTION_GROUP &&
          entry.fieldPath === RESERVATION_ITEM_KEY_FIELD,
    );

    assert.ok(
        match,
        "fieldOverrides must include items.itemKey for preflight " +
        "collectionGroup query",
    );

    const groupIndexes = (match.indexes || []).filter(
        (idx) => idx.queryScope === "COLLECTION_GROUP",
    );
    const orders = groupIndexes.map((idx) => idx.order);
    assert.ok(
        orders.includes("ASCENDING"),
        "COLLECTION_GROUP ASCENDING required (FAILED_PRECONDITION otherwise)",
    );
  });

  it("preflight constants stay aligned with the reservation query", () => {
    assert.equal(RESERVATION_ITEM_KEY_COLLECTION_GROUP, "items");
    assert.equal(RESERVATION_ITEM_KEY_FIELD, "itemKey");
  });
});
