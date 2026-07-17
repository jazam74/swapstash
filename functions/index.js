const {setGlobalOptions} = require("firebase-functions");
const {
  onDocumentCreated,
} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

setGlobalOptions({
  maxInstances: 10,
});

/**
 * Pošlje push obvestilo prejemniku novega sporočila.
 */
exports.sendChatMessageNotification = onDocumentCreated(
    "conversations/{conversationId}/messages/{messageId}",
    async (event) => {
      const messageSnapshot = event.data;

      if (!messageSnapshot) {
        logger.warn("Dogodek ne vsebuje dokumenta sporočila.");
        return;
      }

      const messageData = messageSnapshot.data();
      const conversationId = event.params.conversationId;
      const messageId = event.params.messageId;

      const senderId =
        typeof messageData.senderId === "string" ?
          messageData.senderId.trim() :
          "";

      const messageText =
        typeof messageData.text === "string" ?
          messageData.text.trim() :
          "";

      if (!senderId) {
        logger.warn("Sporočilo nima veljavnega senderId.", {
          conversationId,
          messageId,
        });
        return;
      }

      const firestore = getFirestore();

      const conversationReference = firestore
          .collection("conversations")
          .doc(conversationId);

      const conversationSnapshot = await conversationReference.get();

      if (!conversationSnapshot.exists) {
        logger.warn("Pogovor ne obstaja.", {
          conversationId,
          messageId,
        });
        return;
      }

      const conversationData = conversationSnapshot.data() || {};

      const participantIds = Array.isArray(
          conversationData.participantIds,
      ) ?
        conversationData.participantIds.filter(
            (value) => typeof value === "string" && value.trim(),
        ) :
        [];

      const recipientIds = participantIds.filter(
          (participantId) => participantId !== senderId,
      );

      if (recipientIds.length === 0) {
        logger.info("Za sporočilo ni bilo mogoče določiti prejemnika.", {
          conversationId,
          messageId,
          senderId,
        });
        return;
      }

      const participantNames =
        conversationData.participantNames &&
        typeof conversationData.participantNames === "object" ?
          conversationData.participantNames :
          {};

      const rawSenderName = participantNames[senderId];

      const senderName =
        typeof rawSenderName === "string" && rawSenderName.trim() ?
          rawSenderName.trim() :
          "SwapStash uporabnik";

      const collectionName =
        typeof conversationData.collectionName === "string" ?
          conversationData.collectionName.trim() :
          "";

      const notificationBody = messageText ||
        "Poslal ti je novo sporočilo.";

      const bodyPreview = notificationBody.length > 200 ?
        `${notificationBody.substring(0, 197)}...` :
        notificationBody;

      for (const recipientId of recipientIds) {
        await sendNotificationToRecipient({
          firestore,
          recipientId,
          senderId,
          senderName,
          bodyPreview,
          conversationId,
          messageId,
          collectionName,
        });
      }
    },
);

/**
 * Pošlje obvestilo na vse naprave posameznega uporabnika.
 *
 * @param {object} options Podatki za pošiljanje obvestila.
 * @param {FirebaseFirestore.Firestore} options.firestore Firestore.
 * @param {string} options.recipientId ID prejemnika.
 * @param {string} options.senderId ID pošiljatelja.
 * @param {string} options.senderName Ime pošiljatelja.
 * @param {string} options.bodyPreview Besedilo obvestila.
 * @param {string} options.conversationId ID pogovora.
 * @param {string} options.messageId ID sporočila.
 * @param {string} options.collectionName Ime zbirke.
 */
async function sendNotificationToRecipient({
  firestore,
  recipientId,
  senderId,
  senderName,
  bodyPreview,
  conversationId,
  messageId,
  collectionName,
}) {
  const userReference = firestore.collection("users").doc(recipientId);
  const userSnapshot = await userReference.get();

  if (!userSnapshot.exists) {
    logger.info("Dokument prejemnika ne obstaja.", {
      recipientId,
      conversationId,
    });
    return;
  }

  const userData = userSnapshot.data() || {};

  const notificationTokens = Array.isArray(userData.notificationTokens) ?
    [...new Set(
        userData.notificationTokens.filter(
            (token) => typeof token === "string" && token.trim(),
        ),
    )] :
    [];

  if (notificationTokens.length === 0) {
    logger.info("Prejemnik nima registriranih FCM tokenov.", {
      recipientId,
      conversationId,
    });
    return;
  }

  const multicastMessage = {
    tokens: notificationTokens,
    notification: {
      title: senderName,
      body: bodyPreview,
    },
    data: {
      type: "chat_message",
      conversationId,
      messageId,
      senderId,
      senderName,
      collectionName,
    },
    android: {
      priority: "high",
      notification: {
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },
  };

  const response = await getMessaging().sendEachForMulticast(
      multicastMessage,
  );

  logger.info("Push obvestila so bila obdelana.", {
    recipientId,
    conversationId,
    messageId,
    successCount: response.successCount,
    failureCount: response.failureCount,
  });

  const invalidTokens = [];

  response.responses.forEach((result, index) => {
    if (result.success) {
      return;
    }

    const token = notificationTokens[index];
    let errorCode = "unknown";

    if (result.error && result.error.code) {
      errorCode = result.error.code;
    }

    logger.warn("Pošiljanje na FCM token ni uspelo.", {
      recipientId,
      conversationId,
      tokenSuffix: token.slice(-8),
      errorCode,
    });

    if (
      errorCode === "messaging/invalid-registration-token" ||
      errorCode === "messaging/registration-token-not-registered"
    ) {
      invalidTokens.push(token);
    }
  });

  if (invalidTokens.length > 0) {
    await userReference.update({
      notificationTokens: FieldValue.arrayRemove(...invalidTokens),
    });

    logger.info("Neveljavni FCM tokeni so bili odstranjeni.", {
      recipientId,
      removedTokenCount: invalidTokens.length,
    });
  }
}
