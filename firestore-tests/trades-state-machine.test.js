import { after, before, beforeEach, describe, it } from "node:test";

import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { doc, setDoc, updateDoc } from "firebase/firestore";

import {
  ALICE,
  BOB,
  CAROL,
  COLLECTION_ID,
  createTestEnvironment,
  db,
  seed,
  tradeFixture,
} from "./helpers.js";

let testEnv;

const TRADE = "trades/t_state";

/** Seeds the trade under test with the given field overrides. */
async function givenTrade(overrides) {
  await seed(testEnv, async (firestore) => {
    await setDoc(doc(firestore, TRADE), tradeFixture(overrides));
  });
}

function tradeRef(uid) {
  return doc(db(testEnv, uid), TRADE);
}

const NOW = new Date("2026-03-01T12:00:00Z");

before(async () => {
  testEnv = await createTestEnvironment();
});

after(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe("/trades create", () => {
  it("valid: sender creates a pending trade", async () => {
    await assertSucceeds(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_new"),
        tradeFixture({ senderId: ALICE, receiverId: BOB }),
      ),
    );
  });

  it("invalid: cannot create a trade on someone else's behalf", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, CAROL), "trades/t_new"),
        tradeFixture({ senderId: ALICE, receiverId: BOB }),
      ),
    );
  });

  it("invalid: cannot create a trade with yourself", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_new"),
        tradeFixture({ senderId: ALICE, receiverId: ALICE, awaitingUserId: ALICE }),
      ),
    );
  });

  it("invalid: cannot create a trade that is already accepted", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_new"),
        tradeFixture({ status: "accepted", awaitingUserId: "" }),
      ),
    );
  });

  it("invalid: cannot create a trade with confirmation flags pre-set", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, ALICE), "trades/t_new"),
        tradeFixture({ senderShipped: true }),
      ),
    );
  });
});

describe("/trades valid transitions", () => {
  it("pending -> accepted by the awaiting user", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertSucceeds(
      updateDoc(tradeRef(BOB), {
        status: "accepted",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("pending -> rejected by the awaiting user", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertSucceeds(
      updateDoc(tradeRef(BOB), {
        status: "rejected",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("pending -> countered by the awaiting user, turn flips back", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertSucceeds(
      updateDoc(tradeRef(BOB), {
        offeredItems: [
          { itemId: "item_9", itemNumber: "9", collectionId: COLLECTION_ID, quantity: 2 },
        ],
        requestedItems: [
          { itemId: "item_8", itemNumber: "8", collectionId: COLLECTION_ID, quantity: 1 },
        ],
        status: "countered",
        lastProposedBy: BOB,
        awaitingUserId: ALICE,
        updatedAt: NOW,
      }),
    );
  });

  it("countered -> accepted by the newly awaiting user", async () => {
    await givenTrade({
      status: "countered",
      lastProposedBy: BOB,
      awaitingUserId: ALICE,
    });

    await assertSucceeds(
      updateDoc(tradeRef(ALICE), {
        status: "accepted",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("pending -> cancelled by the last proposer", async () => {
    await givenTrade({
      status: "pending",
      lastProposedBy: ALICE,
      awaitingUserId: BOB,
    });

    await assertSucceeds(
      updateDoc(tradeRef(ALICE), {
        status: "cancelled",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("accepted: each side may confirm shipping once", async () => {
    await givenTrade({ status: "accepted", awaitingUserId: "" });

    await assertSucceeds(
      updateDoc(tradeRef(ALICE), {
        senderShipped: true,
        senderShippedAt: NOW,
        updatedAt: NOW,
      }),
    );
    await assertSucceeds(
      updateDoc(tradeRef(BOB), {
        receiverShipped: true,
        receiverShippedAt: NOW,
        updatedAt: NOW,
      }),
    );
  });

  it("accepted: receipt confirmation without completing the trade", async () => {
    await givenTrade({
      status: "accepted",
      awaitingUserId: "",
      senderShipped: true,
      receiverShipped: true,
    });

    await assertSucceeds(
      updateDoc(tradeRef(ALICE), {
        senderReceived: true,
        senderReceivedAt: NOW,
        updatedAt: NOW,
      }),
    );
  });

  it("accepted -> completed on the last receipt, once all four flags are set", async () => {
    await givenTrade({
      status: "accepted",
      awaitingUserId: "",
      senderShipped: true,
      receiverShipped: true,
      senderReceived: true,
      receiverReceived: false,
    });

    // This mirrors TradeService.markReceived: the same write flips the last
    // missing flag and sets the status.
    await assertSucceeds(
      updateDoc(tradeRef(BOB), {
        receiverReceived: true,
        receiverReceivedAt: NOW,
        status: "completed",
        updatedAt: NOW,
      }),
    );
  });
});

describe("/trades invalid transitions", () => {
  it("pending -> completed is rejected", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertFails(
      updateDoc(tradeRef(BOB), { status: "completed", updatedAt: NOW }),
    );
    await assertFails(
      updateDoc(tradeRef(ALICE), { status: "completed", updatedAt: NOW }),
    );
  });

  it("rejected -> accepted is rejected", async () => {
    await givenTrade({ status: "rejected", awaitingUserId: "" });

    await assertFails(
      updateDoc(tradeRef(BOB), {
        status: "accepted",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("rejected -> completed is rejected", async () => {
    await givenTrade({
      status: "rejected",
      awaitingUserId: "",
      senderShipped: true,
      receiverShipped: true,
      senderReceived: true,
      receiverReceived: true,
    });

    await assertFails(
      updateDoc(tradeRef(BOB), { status: "completed", updatedAt: NOW }),
    );
  });

  it("cancelled -> accepted is rejected", async () => {
    await givenTrade({ status: "cancelled", awaitingUserId: "" });

    await assertFails(
      updateDoc(tradeRef(BOB), {
        status: "accepted",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("completed -> anything else is rejected", async () => {
    await givenTrade({
      status: "completed",
      awaitingUserId: "",
      senderShipped: true,
      receiverShipped: true,
      senderReceived: true,
      receiverReceived: true,
    });

    for (const status of ["pending", "countered", "accepted", "cancelled", "rejected"]) {
      await assertFails(
        updateDoc(tradeRef(ALICE), { status, updatedAt: NOW }),
      );
    }
  });

  it("a participant cannot change senderId or receiverId", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertFails(
      updateDoc(tradeRef(BOB), { senderId: CAROL, updatedAt: NOW }),
    );
    await assertFails(
      updateDoc(tradeRef(BOB), { receiverId: CAROL, updatedAt: NOW }),
    );
    await assertFails(
      updateDoc(tradeRef(BOB), {
        status: "accepted",
        awaitingUserId: "",
        receiverId: CAROL,
        updatedAt: NOW,
      }),
    );
  });

  it("the wrong participant cannot accept", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    // Alice proposed; it is Bob's turn, so Alice may not accept her own offer.
    await assertFails(
      updateDoc(tradeRef(ALICE), {
        status: "accepted",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("the wrong participant cannot reject", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertFails(
      updateDoc(tradeRef(ALICE), {
        status: "rejected",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("the wrong participant cannot counter", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertFails(
      updateDoc(tradeRef(ALICE), {
        status: "countered",
        lastProposedBy: ALICE,
        awaitingUserId: BOB,
        updatedAt: NOW,
      }),
    );
  });

  it("a counter cannot hand the turn back to the proposer", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertFails(
      updateDoc(tradeRef(BOB), {
        status: "countered",
        lastProposedBy: BOB,
        awaitingUserId: BOB,
        updatedAt: NOW,
      }),
    );
  });

  it("only the last proposer may cancel", async () => {
    await givenTrade({
      status: "pending",
      lastProposedBy: ALICE,
      awaitingUserId: BOB,
    });

    await assertFails(
      updateDoc(tradeRef(BOB), {
        status: "cancelled",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });

  it("a modified client cannot set completion flags and status in one write", async () => {
    await givenTrade({ status: "accepted", awaitingUserId: "" });

    await assertFails(
      updateDoc(tradeRef(ALICE), {
        senderShipped: true,
        receiverShipped: true,
        senderReceived: true,
        receiverReceived: true,
        status: "completed",
        updatedAt: NOW,
      }),
    );
  });

  it("completion is rejected while any confirmation is still missing", async () => {
    await givenTrade({
      status: "accepted",
      awaitingUserId: "",
      senderShipped: true,
      receiverShipped: false,
      senderReceived: true,
      receiverReceived: false,
    });

    await assertFails(
      updateDoc(tradeRef(BOB), {
        receiverReceived: true,
        receiverReceivedAt: NOW,
        status: "completed",
        updatedAt: NOW,
      }),
    );
  });

  it("a participant cannot flip the other side's confirmation flags", async () => {
    await givenTrade({ status: "accepted", awaitingUserId: "" });

    await assertFails(
      updateDoc(tradeRef(ALICE), {
        receiverShipped: true,
        receiverShippedAt: NOW,
        updatedAt: NOW,
      }),
    );
    await assertFails(
      updateDoc(tradeRef(BOB), {
        senderReceived: true,
        senderReceivedAt: NOW,
        updatedAt: NOW,
      }),
    );
  });

  it("confirmation flags cannot be reverted", async () => {
    await givenTrade({
      status: "accepted",
      awaitingUserId: "",
      senderShipped: true,
    });

    await assertFails(
      updateDoc(tradeRef(ALICE), { senderShipped: false, updatedAt: NOW }),
    );
  });

  it("shipping cannot be confirmed on a trade that is not accepted", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertFails(
      updateDoc(tradeRef(ALICE), {
        senderShipped: true,
        senderShippedAt: NOW,
        updatedAt: NOW,
      }),
    );
  });

  it("items cannot be rewritten outside a counter offer", async () => {
    await givenTrade({ status: "accepted", awaitingUserId: "" });

    await assertFails(
      updateDoc(tradeRef(ALICE), {
        offeredItems: [
          { itemId: "item_x", itemNumber: "99", collectionId: COLLECTION_ID, quantity: 50 },
        ],
        updatedAt: NOW,
      }),
    );
  });

  it("a non-participant cannot touch the trade at all", async () => {
    await givenTrade({ status: "pending", awaitingUserId: BOB });

    await assertFails(
      updateDoc(tradeRef(CAROL), {
        status: "accepted",
        awaitingUserId: "",
        updatedAt: NOW,
      }),
    );
  });
});
