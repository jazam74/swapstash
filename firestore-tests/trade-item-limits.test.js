import { after, before, beforeEach, describe, it } from "node:test";

import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  doc,
  setDoc,
  updateDoc,
} from "firebase/firestore";

import {
  ALICE,
  BOB,
  COLLECTION_ID,
  createTestEnvironment,
  db,
  seed,
  tradeFixture,
} from "./helpers.js";

let testEnv;

function item(n) {
  return {
    itemId: `item_${n}`,
    itemNumber: String(n),
    collectionId: COLLECTION_ID,
    quantity: 1,
  };
}

function items(count) {
  return Array.from({ length: count }, (_, index) => item(index + 1));
}

before(async () => {
  testEnv = await createTestEnvironment();
});

after(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe("P22A2B trade item V1 limits (Rules)", () => {
  it("50 + 50 create is allowed", async () => {
    await assertSucceeds(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_limit_ok"),
        tradeFixture({
          offeredItems: items(50),
          requestedItems: items(50).map((entry, index) => ({
            ...entry,
            itemId: `req_${index + 1}`,
            itemNumber: String(1000 + index),
          })),
        }),
      ),
    );
  });

  it("51 offered create is denied", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_offered_51"),
        tradeFixture({
          offeredItems: items(51),
          requestedItems: [item(200)],
        }),
      ),
    );
  });

  it("51 requested create is denied", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_requested_51"),
        tradeFixture({
          offeredItems: [item(1)],
          requestedItems: items(51),
        }),
      ),
    );
  });

  it("51 + 50 create is denied (total > 100)", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_total_101"),
        tradeFixture({
          offeredItems: items(51),
          requestedItems: items(50).map((entry, index) => ({
            ...entry,
            itemId: `req_${index + 1}`,
            itemNumber: String(2000 + index),
          })),
        }),
      ),
    );
  });

  it("malicious direct create oversized is denied", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_malicious_create"),
        tradeFixture({
          offeredItems: items(60),
          requestedItems: items(60).map((entry, index) => ({
            ...entry,
            itemId: `req_${index + 1}`,
            itemNumber: String(3000 + index),
          })),
        }),
      ),
    );
  });

  it("malicious direct counter oversized is denied", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
        doc(firestore, "trades/t_counter_base"),
        tradeFixture({
          senderId: ALICE,
          receiverId: BOB,
          status: "pending",
          lastProposedBy: ALICE,
          awaitingUserId: BOB,
        }),
      );
    });

    await assertFails(
      updateDoc(doc(db(testEnv, BOB), "trades/t_counter_base"), {
        offeredItems: items(51),
        requestedItems: [item(9)],
        status: "countered",
        lastProposedBy: BOB,
        awaitingUserId: ALICE,
        updatedAt: new Date("2026-03-02T10:00:00Z"),
      }),
    );
  });

  it("legitimate counter within limits is allowed", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
        doc(firestore, "trades/t_counter_ok"),
        tradeFixture({
          senderId: ALICE,
          receiverId: BOB,
          status: "pending",
          lastProposedBy: ALICE,
          awaitingUserId: BOB,
        }),
      );
    });

    await assertSucceeds(
      updateDoc(doc(db(testEnv, BOB), "trades/t_counter_ok"), {
        offeredItems: items(2).map((entry) => ({
          ...entry,
          itemId: `bob_${entry.itemId}`,
        })),
        requestedItems: [item(99)],
        status: "countered",
        lastProposedBy: BOB,
        awaitingUserId: ALICE,
        updatedAt: new Date("2026-03-02T10:00:00Z"),
      }),
    );
  });
});
