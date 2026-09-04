import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

import { initializeTestEnvironment } from "@firebase/rules-unit-testing";

const here = dirname(fileURLToPath(import.meta.url));

export const ALICE = "alice_uid_000000000000000001";
export const BOB = "bob_uid_00000000000000000002";
export const CAROL = "carol_uid_0000000000000000003";

export const COLLECTION_ID = "panini_wc_2026";

/**
 * Conversation IDs are deterministic in ChatService.createConversationId:
 * `{collectionId}_{sortedUidA}_{sortedUidB}`. Tests rebuild them the same way
 * so that the "attacker already knows the ID" scenario is realistic.
 */
export function conversationId(collectionId, firstUserId, secondUserId) {
  const userIds = [firstUserId, secondUserId].sort();
  return `${collectionId}_${userIds[0]}_${userIds[1]}`;
}

function hostAndPort(value, fallback) {
  const [host, port] = (value ?? fallback).split(":");
  return { host, port: Number(port) };
}

export async function createTestEnvironment() {
  const firestoreEmulator = hostAndPort(
    process.env.FIRESTORE_EMULATOR_HOST,
    "127.0.0.1:8080",
  );
  const storageEmulator = hostAndPort(
    process.env.FIREBASE_STORAGE_EMULATOR_HOST,
    "127.0.0.1:9199",
  );

  return initializeTestEnvironment({
    projectId: "swapstash-rules-test",
    firestore: {
      rules: readFileSync(resolve(here, "..", "firestore.rules"), "utf8"),
      ...firestoreEmulator,
    },
    storage: {
      rules: readFileSync(resolve(here, "..", "storage.rules"), "utf8"),
      ...storageEmulator,
    },
  });
}

export function db(testEnv, uid) {
  return uid === null
    ? testEnv.unauthenticatedContext().firestore()
    : testEnv.authenticatedContext(uid).firestore();
}

export function storage(testEnv, uid) {
  return uid === null
    ? testEnv.unauthenticatedContext().storage()
    : testEnv.authenticatedContext(uid).storage();
}

/**
 * Mirrors the object path built by ItemImageService.itemImageReference:
 * `users/{uid}/collections/{collectionId}/items/{itemNumber}.jpg`.
 */
export function itemImagePath(userId, collectionId, itemNumber) {
  return `users/${userId}/collections/${collectionId}/items/${itemNumber}.jpg`;
}

/** A small byte payload standing in for a picked JPEG. */
export function imageBytes(sizeInBytes = 1024) {
  return new Uint8Array(sizeInBytes).fill(0xff);
}

/** Mirrors the document TradeService.createTrade writes. */
export function tradeFixture(overrides = {}) {
  return {
    senderId: ALICE,
    receiverId: BOB,
    offeredItems: [
      { itemId: "item_1", itemNumber: "1", collectionId: COLLECTION_ID, quantity: 1 },
    ],
    requestedItems: [
      { itemId: "item_2", itemNumber: "2", collectionId: COLLECTION_ID, quantity: 1 },
    ],
    status: "pending",
    lastProposedBy: ALICE,
    awaitingUserId: BOB,
    senderShipped: false,
    senderReceived: false,
    receiverShipped: false,
    receiverReceived: false,
    createdAt: new Date("2026-01-01T10:00:00Z"),
    updatedAt: new Date("2026-01-01T10:00:00Z"),
    ...overrides,
  };
}

/** Mirrors the document ChatService.getOrCreateConversation writes. */
export function conversationFixture(participants, overrides = {}) {
  const participantIds = [...participants].sort();

  return {
    participantIds,
    participantNames: Object.fromEntries(
      participantIds.map((uid) => [uid, `Name ${uid.slice(0, 5)}`]),
    ),
    participantPhotoUrls: Object.fromEntries(
      participantIds.map((uid) => [uid, ""]),
    ),
    collectionId: COLLECTION_ID,
    collectionName: "Panini World Cup 2026",
    lastMessage: "Pozdravljen",
    lastMessageAt: new Date("2026-02-01T09:00:00Z"),
    lastSenderId: participantIds[0],
    unreadCounts: Object.fromEntries(participantIds.map((uid) => [uid, 0])),
    createdAt: new Date("2026-01-15T08:00:00Z"),
    ...overrides,
  };
}

/** Writes fixtures with rules disabled so tests start from a known state. */
export async function seed(testEnv, writer) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await writer(context.firestore());
  });
}
