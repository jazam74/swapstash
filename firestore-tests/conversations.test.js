import { after, before, beforeEach, describe, it } from "node:test";

import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  collection,
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
  COLLECTION_ID,
  conversationFixture,
  conversationId,
  createTestEnvironment,
  db,
  seed,
} from "./helpers.js";

let testEnv;

const AB = conversationId(COLLECTION_ID, ALICE, BOB);
const AB_PATH = `conversations/${AB}`;

before(async () => {
  testEnv = await createTestEnvironment();
});

after(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();

  await seed(testEnv, async (firestore) => {
    await setDoc(doc(firestore, AB_PATH), conversationFixture([ALICE, BOB]));

    await setDoc(doc(firestore, `${AB_PATH}/messages/m1`), {
      senderId: ALICE,
      text: "Zamenjava za 42?",
      createdAt: new Date("2026-02-01T09:00:00Z"),
      readBy: [ALICE],
    });
  });
});

describe("/conversations read access", () => {
  describe("allowed", () => {
    it("1. participant A can read the A-B conversation", async () => {
      await assertSucceeds(getDoc(doc(db(testEnv, ALICE), AB_PATH)));
    });

    it("2. participant B can read the A-B conversation", async () => {
      await assertSucceeds(getDoc(doc(db(testEnv, BOB), AB_PATH)));
    });

    it("3. a participant can list the messages of their conversation", async () => {
      await assertSucceeds(
        getDocs(collection(db(testEnv, ALICE), `${AB_PATH}/messages`)),
      );
    });

    it("3b. a participant can list their own conversations", async () => {
      await assertSucceeds(
        getDocs(
          query(
            collection(db(testEnv, ALICE), "conversations"),
            where("participantIds", "array-contains", ALICE),
          ),
        ),
      );
    });

    it("4. creating a new legitimate conversation works", async () => {
      const id = conversationId(COLLECTION_ID, ALICE, CAROL);

      await assertSucceeds(
        setDoc(
          doc(db(testEnv, ALICE), `conversations/${id}`),
          {
            participantIds: [ALICE, CAROL].sort(),
            participantNames: { [ALICE]: "Alice", [CAROL]: "Carol" },
            participantPhotoUrls: { [ALICE]: "", [CAROL]: "" },
            collectionId: COLLECTION_ID,
            collectionName: "Panini World Cup 2026",
          },
          { merge: true },
        ),
      );
    });
  });

  describe("denied", () => {
    it("5. Carol cannot get() the A-B conversation even knowing its ID", async () => {
      const firestore = db(testEnv, CAROL);

      // The ID is deterministic, so an attacker can reconstruct it from two
      // public profile UIDs. Knowing it must not be enough.
      await assertFails(getDoc(doc(firestore, AB_PATH)));
    });

    it("6. Carol cannot list the messages of the A-B conversation", async () => {
      const firestore = db(testEnv, CAROL);

      await assertFails(
        getDocs(collection(firestore, `${AB_PATH}/messages`)),
      );
      await assertFails(getDoc(doc(firestore, `${AB_PATH}/messages/m1`)));
    });

    it("6b. Carol cannot list all conversations", async () => {
      await assertFails(
        getDocs(collection(db(testEnv, CAROL), "conversations")),
      );
    });

    it("6c. Carol cannot query conversations she is not part of", async () => {
      await assertFails(
        getDocs(
          query(
            collection(db(testEnv, CAROL), "conversations"),
            where("participantIds", "array-contains", ALICE),
          ),
        ),
      );
    });

    it("7. an unauthenticated client has no access", async () => {
      const firestore = db(testEnv, null);

      await assertFails(getDoc(doc(firestore, AB_PATH)));
      await assertFails(getDocs(collection(firestore, `${AB_PATH}/messages`)));
    });

    it("Carol cannot inject herself into an existing conversation", async () => {
      await assertFails(
        setDoc(
          doc(db(testEnv, CAROL), AB_PATH),
          { participantIds: [ALICE, CAROL].sort() },
          { merge: true },
        ),
      );
    });

    it("a participant cannot swap the other participant out", async () => {
      await assertFails(
        setDoc(
          doc(db(testEnv, ALICE), AB_PATH),
          { participantIds: [ALICE, CAROL].sort() },
          { merge: true },
        ),
      );
    });
  });
});

describe("ChatService.getOrCreateConversation write shape", () => {
  /** Exactly the payload the reworked getOrCreateConversation sends. */
  function metadataPayload(currentUserId, otherUserId) {
    return {
      participantIds: [currentUserId, otherUserId].sort(),
      participantNames: {
        [currentUserId]: "Refreshed name",
        [otherUserId]: "Other refreshed name",
      },
      participantPhotoUrls: {
        [currentUserId]: "https://example.test/a.png",
        [otherUserId]: "https://example.test/b.png",
      },
      collectionId: COLLECTION_ID,
      collectionName: "Panini World Cup 2026",
    };
  }

  it("re-opening an existing conversation preserves its state", async () => {
    await assertSucceeds(
      setDoc(doc(db(testEnv, BOB), AB_PATH), metadataPayload(BOB, ALICE), {
        merge: true,
      }),
    );

    const after = await getDoc(doc(db(testEnv, BOB), AB_PATH));
    const data = after.data();

    const expectations = {
      lastMessage: "Pozdravljen",
      lastSenderId: [ALICE, BOB].sort()[0],
    };

    for (const [key, expected] of Object.entries(expectations)) {
      if (data[key] !== expected) {
        throw new Error(
          `${key} was overwritten: expected ${expected}, got ${data[key]}`,
        );
      }
    }

    if (data.lastMessageAt === null || data.lastMessageAt === undefined) {
      throw new Error("lastMessageAt was cleared by the merge write");
    }

    if (data.createdAt === null || data.createdAt === undefined) {
      throw new Error("createdAt was cleared by the merge write");
    }

    if (data.unreadCounts?.[BOB] !== 0 || data.unreadCounts?.[ALICE] !== 0) {
      throw new Error(
        `unreadCounts were reset: ${JSON.stringify(data.unreadCounts)}`,
      );
    }

    if (data.participantNames[BOB] !== "Refreshed name") {
      throw new Error("display metadata was not refreshed");
    }
  });

  it("re-opening does not reset an unread counter", async () => {
    await seed(testEnv, async (firestore) => {
      await setDoc(
        doc(firestore, AB_PATH),
        conversationFixture([ALICE, BOB], {
          unreadCounts: { [ALICE]: 0, [BOB]: 7 },
        }),
      );
    });

    await assertSucceeds(
      setDoc(doc(db(testEnv, BOB), AB_PATH), metadataPayload(BOB, ALICE), {
        merge: true,
      }),
    );

    const after = await getDoc(doc(db(testEnv, BOB), AB_PATH));

    if (after.data().unreadCounts[BOB] !== 7) {
      throw new Error(
        `unread counter drifted: ${JSON.stringify(after.data().unreadCounts)}`,
      );
    }
  });

  it("either participant may re-open, regardless of who created the document", async () => {
    // Alice created it, so a naive implementation would store [ALICE, BOB] in
    // creation order and Bob's write would fail the immutability check.
    await assertSucceeds(
      setDoc(doc(db(testEnv, ALICE), AB_PATH), metadataPayload(ALICE, BOB), {
        merge: true,
      }),
    );
    await assertSucceeds(
      setDoc(doc(db(testEnv, BOB), AB_PATH), metadataPayload(BOB, ALICE), {
        merge: true,
      }),
    );
  });

  it("a participant cannot repoint the conversation at another collection", async () => {
    await assertFails(
      setDoc(
        doc(db(testEnv, ALICE), AB_PATH),
        { ...metadataPayload(ALICE, BOB), collectionId: "other_collection" },
        { merge: true },
      ),
    );
  });
});
