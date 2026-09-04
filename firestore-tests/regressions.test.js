/**
 * Regression coverage for the rules that depend on /trades and /conversations.
 * P22A1 tightened both, so these paths have to keep working unchanged.
 */
import { after, before, beforeEach, describe, it } from "node:test";

import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  addDoc,
  collection,
  doc,
  getDoc,
  setDoc,
  updateDoc,
} from "firebase/firestore";

import {
  ALICE,
  BOB,
  CAROL,
  COLLECTION_ID,
  conversationFixture,
  conversationId,
  createTestEnvironment,
  db,
  seed,
  tradeFixture,
} from "./helpers.js";

let testEnv;

const AB = conversationId(COLLECTION_ID, ALICE, BOB);
const AB_PATH = `conversations/${AB}`;

const COMPLETED_TRADE = "t_completed";
const ACCEPTED_TRADE = "t_accepted";
const PENDING_TRADE = "t_pending";

const NOW = new Date("2026-03-01T12:00:00Z");

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
      displayName: "Alice",
      rating: 0,
      ratingCount: 0,
      completedTrades: 0,
    });
    await setDoc(doc(firestore, `users/${BOB}`), {
      displayName: "Bob",
      rating: 0,
      ratingCount: 0,
      completedTrades: 0,
    });

    await setDoc(
      doc(firestore, `trades/${COMPLETED_TRADE}`),
      tradeFixture({
        status: "completed",
        awaitingUserId: "",
        senderShipped: true,
        receiverShipped: true,
        senderReceived: true,
        receiverReceived: true,
      }),
    );
    await setDoc(
      doc(firestore, `trades/${ACCEPTED_TRADE}`),
      tradeFixture({ status: "accepted", awaitingUserId: "" }),
    );
    await setDoc(
      doc(firestore, `trades/${PENDING_TRADE}`),
      tradeFixture({ status: "pending", awaitingUserId: BOB }),
    );

    await setDoc(doc(firestore, AB_PATH), conversationFixture([ALICE, BOB]));
  });
});

describe("rating eligibility still works", () => {
  function rating(tradeId, reviewerId, reviewedUserId) {
    return {
      tradeId,
      reviewerId,
      reviewedUserId,
      stars: 5,
      comment: "Hitra in korektna menjava.",
      createdAt: NOW,
      updatedAt: null,
    };
  }

  it("a participant can rate the counterpart after a completed trade", async () => {
    await assertSucceeds(
      setDoc(
        doc(
          db(testEnv, ALICE),
          `users/${BOB}/ratings/${COMPLETED_TRADE}_${ALICE}`,
        ),
        rating(COMPLETED_TRADE, ALICE, BOB),
      ),
    );
  });

  it("rating an accepted (not yet completed) trade is still rejected", async () => {
    await assertFails(
      setDoc(
        doc(
          db(testEnv, ALICE),
          `users/${BOB}/ratings/${ACCEPTED_TRADE}_${ALICE}`,
        ),
        rating(ACCEPTED_TRADE, ALICE, BOB),
      ),
    );
  });

  it("an outsider cannot rate off someone else's completed trade", async () => {
    await assertFails(
      setDoc(
        doc(
          db(testEnv, CAROL),
          `users/${BOB}/ratings/${COMPLETED_TRADE}_${CAROL}`,
        ),
        rating(COMPLETED_TRADE, CAROL, BOB),
      ),
    );
  });

  it("self-rating is still rejected", async () => {
    await assertFails(
      setDoc(
        doc(
          db(testEnv, ALICE),
          `users/${ALICE}/ratings/${COMPLETED_TRADE}_${ALICE}`,
        ),
        rating(COMPLETED_TRADE, ALICE, ALICE),
      ),
    );
  });
});

describe("chat messages still work", () => {
  function message(senderId) {
    return {
      senderId,
      text: "Se dogovoriva za predajo?",
      createdAt: NOW,
      readBy: [senderId],
    };
  }

  it("a participant can send a message", async () => {
    await assertSucceeds(
      addDoc(
        collection(db(testEnv, ALICE), `${AB_PATH}/messages`),
        message(ALICE),
      ),
    );
  });

  it("a non-participant cannot inject a message", async () => {
    await assertFails(
      addDoc(
        collection(db(testEnv, CAROL), `${AB_PATH}/messages`),
        message(CAROL),
      ),
    );
  });

  it("a participant cannot spoof another sender", async () => {
    await assertFails(
      addDoc(
        collection(db(testEnv, ALICE), `${AB_PATH}/messages`),
        message(BOB),
      ),
    );
  });
});

describe("unread state still works", () => {
  it("sending updates lastMessage and both unread counters", async () => {
    await assertSucceeds(
      updateDoc(doc(db(testEnv, ALICE), AB_PATH), {
        lastMessage: "Se dogovoriva?",
        lastMessageAt: NOW,
        lastSenderId: ALICE,
        [`unreadCounts.${ALICE}`]: 0,
        [`unreadCounts.${BOB}`]: 3,
      }),
    );
  });

  it("markConversationRead can reset the caller's counter", async () => {
    await assertSucceeds(
      updateDoc(doc(db(testEnv, BOB), AB_PATH), {
        [`unreadCounts.${BOB}`]: 0,
      }),
    );
  });

  it("an outsider cannot touch the unread counters", async () => {
    await assertFails(
      updateDoc(doc(db(testEnv, CAROL), AB_PATH), {
        [`unreadCounts.${CAROL}`]: 0,
      }),
    );
  });
});

describe("trade delivery details still work", () => {
  const details = {
    userId: ALICE,
    method: "mail",
    fullName: "Alice A",
    addressLine1: "Cesta 1",
    addressLine2: "",
    postalCode: "1000",
    city: "Ljubljana",
    country: "SI",
    phone: "+38640000000",
    meetingDetails: "",
    carrier: "Poste",
    trackingNumber: "",
    notes: "",
    createdAt: NOW,
    updatedAt: NOW,
  };

  it("a participant can write their own delivery details on an accepted trade", async () => {
    await assertSucceeds(
      setDoc(
        doc(
          db(testEnv, ALICE),
          `trades/${ACCEPTED_TRADE}/deliveryDetails/${ALICE}`,
        ),
        details,
      ),
    );
  });

  it("both participants can read delivery details on an accepted trade", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
        doc(firestore, `trades/${ACCEPTED_TRADE}/deliveryDetails/${ALICE}`),
        details,
      );
    });

    await assertSucceeds(
      getDoc(
        doc(
          db(testEnv, BOB),
          `trades/${ACCEPTED_TRADE}/deliveryDetails/${ALICE}`,
        ),
      ),
    );
  });

  it("an outsider cannot read delivery details", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
        doc(firestore, `trades/${ACCEPTED_TRADE}/deliveryDetails/${ALICE}`),
        details,
      );
    });

    await assertFails(
      getDoc(
        doc(
          db(testEnv, CAROL),
          `trades/${ACCEPTED_TRADE}/deliveryDetails/${ALICE}`,
        ),
      ),
    );
  });
});
