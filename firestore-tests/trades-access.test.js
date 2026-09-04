import { after, before, beforeEach, describe, it } from "node:test";

import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  where,
} from "firebase/firestore";

import {
  ALICE,
  BOB,
  CAROL,
  createTestEnvironment,
  db,
  seed,
  tradeFixture,
} from "./helpers.js";

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
    // Alice <-> Bob in both directions, so both the "sent" and the "received"
    // query have something to return.
    await setDoc(
      doc(firestore, "trades/t_alice_to_bob"),
      tradeFixture({ senderId: ALICE, receiverId: BOB }),
    );
    await setDoc(
      doc(firestore, "trades/t_bob_to_alice"),
      tradeFixture({
        senderId: BOB,
        receiverId: ALICE,
        lastProposedBy: BOB,
        awaitingUserId: ALICE,
      }),
    );

    // Trades Alice is not part of. These are what an unfiltered dump would
    // leak, so every "denied" assertion below has something real to trip on.
    await setDoc(
      doc(firestore, "trades/t_bob_to_carol_pending"),
      tradeFixture({ senderId: BOB, receiverId: CAROL, lastProposedBy: BOB, awaitingUserId: CAROL }),
    );
    await setDoc(
      doc(firestore, "trades/t_bob_to_carol_completed"),
      tradeFixture({
        senderId: BOB,
        receiverId: CAROL,
        status: "completed",
        awaitingUserId: "",
        senderShipped: true,
        receiverShipped: true,
        senderReceived: true,
        receiverReceived: true,
      }),
    );
    await setDoc(
      doc(firestore, "trades/t_bob_to_carol_accepted"),
      tradeFixture({
        senderId: BOB,
        receiverId: CAROL,
        status: "accepted",
        awaitingUserId: "",
      }),
    );
  });
});

describe("/trades read access", () => {
  describe("allowed", () => {
    it("1. Alice can query her sent trades (TradeService.watchOutgoingTrades)", async () => {
      const firestore = db(testEnv, ALICE);

      const snapshot = await assertSucceeds(
        getDocs(
          query(collection(firestore, "trades"), where("senderId", "==", ALICE)),
        ),
      );

      const ids = snapshot.docs.map((document) => document.id);
      if (ids.length !== 1 || ids[0] !== "t_alice_to_bob") {
        throw new Error(`Unexpected sent trades: ${JSON.stringify(ids)}`);
      }
    });

    it("2. Alice can query her received trades (TradeService.watchIncomingTrades)", async () => {
      const firestore = db(testEnv, ALICE);

      const snapshot = await assertSucceeds(
        getDocs(
          query(
            collection(firestore, "trades"),
            where("receiverId", "==", ALICE),
          ),
        ),
      );

      const ids = snapshot.docs.map((document) => document.id);
      if (ids.length !== 1 || ids[0] !== "t_bob_to_alice") {
        throw new Error(`Unexpected received trades: ${JSON.stringify(ids)}`);
      }
    });

    it("3. Bob can query his own trades", async () => {
      const firestore = db(testEnv, BOB);

      await assertSucceeds(
        getDocs(
          query(collection(firestore, "trades"), where("senderId", "==", BOB)),
        ),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(firestore, "trades"),
            where("receiverId", "==", BOB),
          ),
        ),
      );
    });

    it("4. a participant can get() a single trade of their own", async () => {
      await assertSucceeds(
        getDoc(doc(db(testEnv, ALICE), "trades/t_alice_to_bob")),
      );
      await assertSucceeds(
        getDoc(doc(db(testEnv, BOB), "trades/t_alice_to_bob")),
      );
    });

    it("keeps the public-profile counter working (watchCompletedTradeCount for another user)", async () => {
      const firestore = db(testEnv, ALICE);

      const snapshot = await assertSucceeds(
        getDocs(
          query(
            collection(firestore, "trades"),
            where("senderId", "==", BOB),
            where("status", "==", "completed"),
          ),
        ),
      );

      const ids = snapshot.docs.map((document) => document.id);
      if (ids.length !== 1 || ids[0] !== "t_bob_to_carol_completed") {
        throw new Error(`Unexpected completed trades: ${JSON.stringify(ids)}`);
      }
    });

    it("keeps the reservation engine working (getActiveReservations for another user)", async () => {
      const firestore = db(testEnv, ALICE);

      await assertSucceeds(
        getDocs(
          query(
            collection(firestore, "trades"),
            where("senderId", "==", BOB),
            where("status", "==", "accepted"),
          ),
        ),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(firestore, "trades"),
            where("receiverId", "==", BOB),
            where("status", "==", "accepted"),
          ),
        ),
      );
    });
  });

  describe("denied", () => {
    it("5. Alice cannot dump the whole trades collection", async () => {
      const firestore = db(testEnv, ALICE);

      await assertFails(getDocs(collection(firestore, "trades")));
    });

    it("5b. Alice cannot dump other people's active negotiations by status", async () => {
      const firestore = db(testEnv, ALICE);

      await assertFails(
        getDocs(
          query(
            collection(firestore, "trades"),
            where("status", "==", "pending"),
          ),
        ),
      );
      await assertFails(
        getDocs(
          query(
            collection(firestore, "trades"),
            where("status", "==", "countered"),
          ),
        ),
      );
    });

    it("6. Alice cannot get() a single trade between Bob and Carol", async () => {
      const firestore = db(testEnv, ALICE);

      await assertFails(
        getDoc(doc(firestore, "trades/t_bob_to_carol_pending")),
      );
      await assertFails(
        getDoc(doc(firestore, "trades/t_bob_to_carol_completed")),
      );
      await assertFails(
        getDoc(doc(firestore, "trades/t_bob_to_carol_accepted")),
      );
    });

    it("7. an unauthenticated client cannot read trades", async () => {
      const firestore = db(testEnv, null);

      await assertFails(getDoc(doc(firestore, "trades/t_alice_to_bob")));
      await assertFails(getDocs(collection(firestore, "trades")));
      await assertFails(
        getDocs(
          query(collection(firestore, "trades"), where("senderId", "==", ALICE)),
        ),
      );
    });

    it("trades cannot be deleted by anyone", async () => {
      await assertFails(
        deleteDoc(doc(db(testEnv, ALICE), "trades/t_alice_to_bob")),
      );
    });
  });
});
