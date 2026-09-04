import { after, before, beforeEach, describe, it } from "node:test";
import assert from "node:assert/strict";

import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
} from "firebase/firestore";

import {
  ALICE,
  BOB,
  CAROL,
  COLLECTION_ID,
  createTestEnvironment,
  db,
  seed,
} from "./helpers.js";

const OTHER_COLLECTION = "other_album_2026";

function reservationPath(userId, collectionId, itemKey) {
  return `users/${userId}/reservationCollections/${collectionId}/items/${itemKey}`;
}

let testEnv;

before(async () => {
  testEnv = await createTestEnvironment();
});

after(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();

  await seed(testEnv, async (firestore) => {
    await setDoc(doc(firestore, `users/${ALICE}`), {
      uid: ALICE,
      completedTrades: 0,
    });
    await setDoc(doc(firestore, `users/${BOB}`), {
      uid: BOB,
      completedTrades: 0,
    });
    await setDoc(doc(firestore, `users/${CAROL}`), {
      uid: CAROL,
      completedTrades: 0,
    });

    // Alice and Bob share COLLECTION_ID. Carol does not have it.
    await setDoc(
      doc(firestore, `users/${ALICE}/collections/${COLLECTION_ID}`),
      { collectionId: COLLECTION_ID },
    );
    await setDoc(
      doc(firestore, `users/${BOB}/collections/${COLLECTION_ID}`),
      { collectionId: COLLECTION_ID },
    );
    await setDoc(
      doc(firestore, `users/${CAROL}/collections/${OTHER_COLLECTION}`),
      { collectionId: OTHER_COLLECTION },
    );

    // Seed reservation docs via Admin (rules deny client writes).
    await setDoc(
      doc(firestore, reservationPath(BOB, COLLECTION_ID, "MQ")),
      {
        collectionId: COLLECTION_ID,
        itemNumber: "1",
        itemId: "item_1",
        itemKey: "MQ",
        outgoing: 2,
        incoming: 1,
        updatedAt: new Date("2026-03-01T10:00:00Z"),
      },
    );
    await setDoc(
      doc(firestore, reservationPath(BOB, OTHER_COLLECTION, "Mg")),
      {
        collectionId: OTHER_COLLECTION,
        itemNumber: "2",
        itemId: "item_2",
        itemKey: "Mg",
        outgoing: 1,
        incoming: 0,
        updatedAt: new Date("2026-03-01T10:00:00Z"),
      },
    );
  });
});

describe("reservationCollections access", () => {
  it("owner can get and list their reservation items", async () => {
    const firestore = db(testEnv, BOB);

    await assertSucceeds(
      getDoc(doc(firestore, reservationPath(BOB, COLLECTION_ID, "MQ"))),
    );

    const listed = await assertSucceeds(
      getDocs(
        collection(
          firestore,
          `users/${BOB}/reservationCollections/${COLLECTION_ID}/items`,
        ),
      ),
    );

    assert.equal(listed.size, 1);
  });

  it("Alice can read Bob reservations for a shared collectionId", async () => {
    const firestore = db(testEnv, ALICE);

    await assertSucceeds(
      getDoc(doc(firestore, reservationPath(BOB, COLLECTION_ID, "MQ"))),
    );

    const listed = await assertSucceeds(
      getDocs(
        collection(
          firestore,
          `users/${BOB}/reservationCollections/${COLLECTION_ID}/items`,
        ),
      ),
    );

    assert.equal(listed.size, 1);
  });

  it("Alice cannot read Bob reservations for a collection she does not own", async () => {
    const firestore = db(testEnv, ALICE);

    await assertFails(
      getDoc(doc(firestore, reservationPath(BOB, OTHER_COLLECTION, "Mg"))),
    );

    await assertFails(
      getDocs(
        collection(
          firestore,
          `users/${BOB}/reservationCollections/${OTHER_COLLECTION}/items`,
        ),
      ),
    );
  });

  it("Carol cannot list Bob reservations for COLLECTION_ID (no membership)", async () => {
    const firestore = db(testEnv, CAROL);

    await assertFails(
      getDocs(
        collection(
          firestore,
          `users/${BOB}/reservationCollections/${COLLECTION_ID}/items`,
        ),
      ),
    );
  });

  it("client create/update/delete on reservation items is denied", async () => {
    const firestore = db(testEnv, BOB);
    const ref = doc(firestore, reservationPath(BOB, COLLECTION_ID, "newkey"));

    await assertFails(
      setDoc(ref, {
        collectionId: COLLECTION_ID,
        itemNumber: "9",
        itemKey: "newkey",
        outgoing: 1,
        incoming: 0,
      }),
    );

    await assertFails(
      updateDoc(doc(firestore, reservationPath(BOB, COLLECTION_ID, "MQ")), {
        outgoing: 99,
      }),
    );

    await assertFails(
      deleteDoc(doc(firestore, reservationPath(BOB, COLLECTION_ID, "MQ"))),
    );
  });

  it("Alice cannot write Bob reservation docs", async () => {
    const firestore = db(testEnv, ALICE);

    await assertFails(
      setDoc(doc(firestore, reservationPath(BOB, COLLECTION_ID, "hack")), {
        collectionId: COLLECTION_ID,
        itemNumber: "1",
        itemKey: "hack",
        outgoing: 5,
        incoming: 0,
      }),
    );
  });

  it("_tradeAggregateState is denied for all clients", async () => {
    await assertFails(
      getDoc(doc(db(testEnv, ALICE), "_tradeAggregateState/t1")),
    );
    await assertFails(
      setDoc(doc(db(testEnv, ALICE), "_tradeAggregateState/t1"), {
        completedContribution: 1,
      }),
    );
    await assertFails(
      getDoc(doc(db(testEnv, null), "_tradeAggregateState/t1")),
    );
  });

  it("unauthenticated clients cannot read reservations", async () => {
    await assertFails(
      getDoc(doc(db(testEnv, null), reservationPath(BOB, COLLECTION_ID, "MQ"))),
    );
  });
});
