/**
 * Firebase Storage rules tests (P22A2A).
 *
 * The app only ever touches one Storage path, written by ItemImageService:
 *   users/{uid}/collections/{collectionId}/items/{itemNumber}.jpg
 *
 * Nothing in the app reads another user's item image and the download URL is
 * never persisted to Firestore, so read access is owner-only. If that product
 * decision changes, the "another collector cannot read" test below is the one
 * that has to be updated deliberately.
 */
import { after, before, beforeEach, describe, it } from "node:test";

import { assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import {
  deleteObject,
  getDownloadURL,
  ref,
  uploadBytes,
} from "firebase/storage";

import {
  ALICE,
  BOB,
  COLLECTION_ID,
  createTestEnvironment,
  imageBytes,
  itemImagePath,
  storage,
} from "./helpers.js";

let testEnv;

const ALICE_IMAGE = itemImagePath(ALICE, COLLECTION_ID, 42);

const JPEG = { contentType: "image/jpeg" };

before(async () => {
  testEnv = await createTestEnvironment();
});

after(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearStorage();
});

/** Puts an object in place bypassing the rules, so tests start from a known state. */
async function givenAliceHasAnImage() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(
      ref(context.storage(), ALICE_IMAGE),
      imageBytes(2048),
      JPEG,
    );
  });
}

describe("Storage: item images — allowed", () => {
  it("the owner can upload their own item image", async () => {
    await assertSucceeds(
      uploadBytes(
        ref(storage(testEnv, ALICE), ALICE_IMAGE),
        imageBytes(),
        JPEG,
      ),
    );
  });

  it("the owner can read their own item image", async () => {
    await givenAliceHasAnImage();

    await assertSucceeds(
      getDownloadURL(ref(storage(testEnv, ALICE), ALICE_IMAGE)),
    );
  });

  it("the owner can overwrite their own item image", async () => {
    await givenAliceHasAnImage();

    await assertSucceeds(
      uploadBytes(
        ref(storage(testEnv, ALICE), ALICE_IMAGE),
        imageBytes(4096),
        { contentType: "image/png" },
      ),
    );
  });

  it("the owner can delete their own item image", async () => {
    await givenAliceHasAnImage();

    await assertSucceeds(
      deleteObject(ref(storage(testEnv, ALICE), ALICE_IMAGE)),
    );
  });

  it("a 4 MB upload is still under the limit", async () => {
    await assertSucceeds(
      uploadBytes(
        ref(storage(testEnv, ALICE), ALICE_IMAGE),
        imageBytes(4 * 1024 * 1024),
        JPEG,
      ),
    );
  });
});

describe("Storage: item images — denied", () => {
  it("an unauthenticated client cannot upload", async () => {
    await assertFails(
      uploadBytes(ref(storage(testEnv, null), ALICE_IMAGE), imageBytes(), JPEG),
    );
  });

  it("an unauthenticated client cannot read", async () => {
    await givenAliceHasAnImage();

    await assertFails(
      getDownloadURL(ref(storage(testEnv, null), ALICE_IMAGE)),
    );
  });

  it("Bob cannot overwrite Alice's image", async () => {
    await givenAliceHasAnImage();

    await assertFails(
      uploadBytes(
        ref(storage(testEnv, BOB), ALICE_IMAGE),
        imageBytes(),
        JPEG,
      ),
    );
  });

  it("Bob cannot delete Alice's image", async () => {
    await givenAliceHasAnImage();

    await assertFails(deleteObject(ref(storage(testEnv, BOB), ALICE_IMAGE)));
  });

  it("Bob cannot read Alice's image (images are owner-only today)", async () => {
    await givenAliceHasAnImage();

    await assertFails(
      getDownloadURL(ref(storage(testEnv, BOB), ALICE_IMAGE)),
    );
  });

  it("a non-image MIME type is rejected", async () => {
    await assertFails(
      uploadBytes(ref(storage(testEnv, ALICE), ALICE_IMAGE), imageBytes(), {
        contentType: "application/pdf",
      }),
    );
  });

  it("an upload larger than 5 MB is rejected", async () => {
    await assertFails(
      uploadBytes(
        ref(storage(testEnv, ALICE), ALICE_IMAGE),
        imageBytes(6 * 1024 * 1024),
        JPEG,
      ),
    );
  });

  it("a file name outside the '{itemNumber}.jpg' pattern is rejected", async () => {
    const badPaths = [
      `users/${ALICE}/collections/${COLLECTION_ID}/items/notanumber.jpg`,
      `users/${ALICE}/collections/${COLLECTION_ID}/items/42.png`,
      `users/${ALICE}/collections/${COLLECTION_ID}/items/backup.zip.jpg`,
    ];

    for (const path of badPaths) {
      await assertFails(
        uploadBytes(ref(storage(testEnv, ALICE), path), imageBytes(), JPEG),
      );
    }
  });

  it("paths outside the item image tree are rejected", async () => {
    const outsidePaths = [
      `users/${ALICE}/avatar.jpg`,
      `users/${ALICE}/collections/${COLLECTION_ID}/1.jpg`,
      "public/1.jpg",
      "1.jpg",
    ];

    for (const path of outsidePaths) {
      await assertFails(
        uploadBytes(ref(storage(testEnv, ALICE), path), imageBytes(), JPEG),
      );
    }
  });
});
