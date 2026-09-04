"use strict";

const crypto = require("crypto");

const {setGlobalOptions, logger} = require("firebase-functions");
const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentWritten,
} = require("firebase-functions/v2/firestore");

const {initializeApp} = require("firebase-admin/app");
const {
  FieldValue,
  Timestamp,
  getFirestore,
} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {
  reconcileTradeAggregates,
  logReservationOvercommit,
} = require("./lib/tradeAggregates");

initializeApp();

setGlobalOptions({
  region: "europe-west1",
  maxInstances: 10,
});

const db = getFirestore();

const MESSAGE_CHANNEL_ID = "swapstash_messages";
const TRADE_CHANNEL_ID = "swapstash_trades";

const SUPPORTED_LANGUAGES = new Set(["sl", "en", "de", "hr"]);

const TEXTS = {
  sl: {
    genericUser: "Uporabnik",
    newTradeTitle: "Nova ponudba za menjavo",
    newTradeBody: "{name} ti je poslal ponudbo.",
    counterTradeTitle: "Nova protiponudba",
    counterTradeBody: "{name} ti je poslal protiponudbo.",
    acceptedTradeTitle: "Ponudba je sprejeta",
    acceptedTradeBody: "{name} je sprejel tvojo ponudbo.",
    rejectedTradeTitle: "Ponudba je zavrnjena",
    rejectedTradeBody: "{name} je zavrnil tvojo ponudbo.",
    shippedTradeTitle: "Kartice so bile poslane",
    shippedTradeBody: "{name} je potrdil pošiljanje.",
    receivedTradeTitle: "Prejem je potrjen",
    receivedTradeBody: "{name} je potrdil prejem kartic.",
    completedTradeTitle: "Menjava je zaključena",
    completedTradeBody: "Menjava z uporabnikom {name} je uspešno zaključena.",
    deliveryAddedTitle: "Podatki za predajo so dodani",
    deliveryAddedBody: "{name} je dodal podatke za predajo ali pošiljanje.",
    deliveryUpdatedTitle: "Podatki za predajo so posodobljeni",
    deliveryUpdatedBody: "{name} je posodobil podatke za predajo ali pošiljanje.",
    trackingAddedTitle: "Dodana je sledilna številka",
    trackingAddedBody: "{name} je dodal ali spremenil sledilno številko.",
  },
  en: {
    genericUser: "User",
    newTradeTitle: "New trade offer",
    newTradeBody: "{name} sent you a trade offer.",
    counterTradeTitle: "New counteroffer",
    counterTradeBody: "{name} sent you a counteroffer.",
    acceptedTradeTitle: "Offer accepted",
    acceptedTradeBody: "{name} accepted your offer.",
    rejectedTradeTitle: "Offer rejected",
    rejectedTradeBody: "{name} rejected your offer.",
    shippedTradeTitle: "Cards shipped",
    shippedTradeBody: "{name} confirmed shipping.",
    receivedTradeTitle: "Delivery confirmed",
    receivedTradeBody: "{name} confirmed receiving the cards.",
    completedTradeTitle: "Trade completed",
    completedTradeBody: "Your trade with {name} was completed successfully.",
    deliveryAddedTitle: "Handover details added",
    deliveryAddedBody: "{name} added handover or shipping details.",
    deliveryUpdatedTitle: "Handover details updated",
    deliveryUpdatedBody: "{name} updated handover or shipping details.",
    trackingAddedTitle: "Tracking number added",
    trackingAddedBody: "{name} added or changed the tracking number.",
  },
  de: {
    genericUser: "Benutzer",
    newTradeTitle: "Neues Tauschangebot",
    newTradeBody: "{name} hat dir ein Tauschangebot gesendet.",
    counterTradeTitle: "Neues Gegenangebot",
    counterTradeBody: "{name} hat dir ein Gegenangebot gesendet.",
    acceptedTradeTitle: "Angebot angenommen",
    acceptedTradeBody: "{name} hat dein Angebot angenommen.",
    rejectedTradeTitle: "Angebot abgelehnt",
    rejectedTradeBody: "{name} hat dein Angebot abgelehnt.",
    shippedTradeTitle: "Karten wurden versendet",
    shippedTradeBody: "{name} hat den Versand bestätigt.",
    receivedTradeTitle: "Erhalt bestätigt",
    receivedTradeBody: "{name} hat den Erhalt der Karten bestätigt.",
    completedTradeTitle: "Tausch abgeschlossen",
    completedTradeBody: "Dein Tausch mit {name} wurde erfolgreich abgeschlossen.",
    deliveryAddedTitle: "Übergabedaten hinzugefügt",
    deliveryAddedBody: "{name} hat Übergabe- oder Versanddaten hinzugefügt.",
    deliveryUpdatedTitle: "Übergabedaten aktualisiert",
    deliveryUpdatedBody: "{name} hat Übergabe- oder Versanddaten aktualisiert.",
    trackingAddedTitle: "Sendungsnummer hinzugefügt",
    trackingAddedBody: "{name} hat die Sendungsnummer hinzugefügt oder geändert.",
  },
  hr: {
    genericUser: "Korisnik",
    newTradeTitle: "Nova ponuda za zamjenu",
    newTradeBody: "{name} ti je poslao ponudu za zamjenu.",
    counterTradeTitle: "Nova protuponuda",
    counterTradeBody: "{name} ti je poslao protuponudu.",
    acceptedTradeTitle: "Ponuda je prihvaćena",
    acceptedTradeBody: "{name} je prihvatio tvoju ponudu.",
    rejectedTradeTitle: "Ponuda je odbijena",
    rejectedTradeBody: "{name} je odbio tvoju ponudu.",
    shippedTradeTitle: "Kartice su poslane",
    shippedTradeBody: "{name} je potvrdio slanje.",
    receivedTradeTitle: "Primitak je potvrđen",
    receivedTradeBody: "{name} je potvrdio primitak kartica.",
    completedTradeTitle: "Zamjena je završena",
    completedTradeBody: "Zamjena s korisnikom {name} uspješno je završena.",
    deliveryAddedTitle: "Dodani su podaci za primopredaju",
    deliveryAddedBody: "{name} je dodao podatke za primopredaju ili slanje.",
    deliveryUpdatedTitle: "Podaci za primopredaju su ažurirani",
    deliveryUpdatedBody: "{name} je ažurirao podatke za primopredaju ili slanje.",
    trackingAddedTitle: "Dodan je broj za praćenje",
    trackingAddedBody: "{name} je dodao ili promijenio broj za praćenje.",
  },
};

function normalizedLanguage(userData) {
  const rawLanguage = String(
      userData.notificationLanguage || userData.language || "en",
  )
      .trim()
      .toLowerCase()
      .split("-")[0];

  return SUPPORTED_LANGUAGES.has(rawLanguage) ? rawLanguage : "en";
}

function applyVariables(template, variables) {
  let result = template;

  for (const [key, value] of Object.entries(variables)) {
    result = result.replaceAll(`{${key}}`, String(value));
  }

  return result;
}

function localizedTradeText(language, titleKey, bodyKey, variables) {
  const texts = TEXTS[language] || TEXTS.en;

  return {
    title: applyVariables(texts[titleKey], variables),
    body: applyVariables(texts[bodyKey], variables),
  };
}

function cleanMessagePreview(value) {
  const compact = String(value || "")
      .replace(/\s+/g, " ")
      .trim();

  if (compact.length <= 140) {
    return compact;
  }

  return `${compact.substring(0, 137)}…`;
}

function notificationEventId(eventId) {
  return crypto
      .createHash("sha256")
      .update(String(eventId || "unknown-event"))
      .digest("hex");
}

async function runEventOnce(event, handler) {
  const reference = db
      .collection("_notificationEvents")
      .doc(notificationEventId(event.id));

  const now = Timestamp.now();
  const staleBefore = now.toMillis() - 10 * 60 * 1000;

  const claimed = await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    const data = snapshot.data();

    if (data?.status === "sent" || data?.status === "skipped") {
      return false;
    }

    if (
      data?.status === "processing" &&
      data.startedAt instanceof Timestamp &&
      data.startedAt.toMillis() > staleBefore
    ) {
      return false;
    }

    transaction.set(
        reference,
        {
          status: "processing",
          eventId: String(event.id || ""),
          startedAt: now,
          updatedAt: now,
          expireAt: Timestamp.fromMillis(
              now.toMillis() + 30 * 24 * 60 * 60 * 1000,
          ),
        },
        {merge: true},
    );

    return true;
  });

  if (!claimed) {
    logger.info("Duplicate notification event skipped.", {
      eventId: event.id,
    });
    return;
  }

  try {
    const report = await handler();
    const reportData =
      report && typeof report === "object" && !Array.isArray(report) ?
        report :
        {};

    const skipped = String(reportData.deliveryStatus || "")
        .startsWith("skipped_");

    await reference.set(
        {
          ...reportData,
          status: skipped ? "skipped" : "sent",
          sentAt: skipped ? null : FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
    );
  } catch (error) {
    const report =
      error?.deliveryReport &&
      typeof error.deliveryReport === "object" ?
        error.deliveryReport :
        {};

    await reference.set(
        {
          ...report,
          status: "failed",
          error: String(error),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
    );

    throw error;
  }
}

async function interactionBlocked(firstUserId, secondUserId) {
  const firstId = String(firstUserId || "").trim();
  const secondId = String(secondUserId || "").trim();

  if (!firstId || !secondId || firstId === secondId) {
    return false;
  }

  const [firstBlocksSecond, secondBlocksFirst] = await Promise.all([
    db
        .collection("users")
        .doc(firstId)
        .collection("blockedUsers")
        .doc(secondId)
        .get(),
    db
        .collection("users")
        .doc(secondId)
        .collection("blockedUsers")
        .doc(firstId)
        .get(),
  ]);

  return firstBlocksSecond.exists || secondBlocksFirst.exists;
}

async function profileName(userId, language = "en") {
  const snapshot = await db.collection("users").doc(userId).get();
  const data = snapshot.data() || {};

  const displayName = String(data.displayName || "").trim();

  if (displayName) {
    return displayName;
  }

  const email = String(data.email || "").trim();

  if (email.includes("@")) {
    return email.split("@")[0];
  }

  return (TEXTS[language] || TEXTS.en).genericUser;
}

function tabIndexForUser(trade, userId, archived = false) {
  if (archived) {
    return "3";
  }

  if (trade.receiverId === userId) {
    return "1";
  }

  if (trade.senderId === userId) {
    return "2";
  }

  return "0";
}

async function sendNotificationToUser({
  userId,
  sourceUserId = "",
  buildText,
  data,
  channelId,
}) {
  if (!userId) {
    return {
      deliveryStatus: "skipped_missing_recipient",
      recipientId: "",
      tokenCount: 0,
      successCount: 0,
      failureCount: 0,
    };
  }

  if (
    sourceUserId &&
    await interactionBlocked(sourceUserId, userId)
  ) {
    logger.info("Notification skipped because interaction is blocked.", {
      sourceUserId,
      recipientId: userId,
    });

    return {
      deliveryStatus: "skipped_blocked_interaction",
      recipientId: userId,
      sourceUserId,
      tokenCount: 0,
      successCount: 0,
      failureCount: 0,
    };
  }

  const userReference = db.collection("users").doc(userId);
  const userSnapshot = await userReference.get();

  if (!userSnapshot.exists) {
    logger.info("Notification recipient profile does not exist.", {userId});

    return {
      deliveryStatus: "skipped_missing_profile",
      recipientId: userId,
      tokenCount: 0,
      successCount: 0,
      failureCount: 0,
    };
  }

  const userData = userSnapshot.data() || {};
  const tokens = Array.from(
      new Set(
          (Array.isArray(userData.notificationTokens) ?
            userData.notificationTokens :
            [])
              .map((token) => String(token).trim())
              .filter(Boolean),
      ),
  );

  if (tokens.length === 0) {
    logger.info("Notification recipient has no device tokens.", {userId});

    return {
      deliveryStatus: "skipped_no_tokens",
      recipientId: userId,
      tokenCount: 0,
      successCount: 0,
      failureCount: 0,
    };
  }

  const language = normalizedLanguage(userData);
  const text = await buildText(language);

  const stringData = Object.fromEntries(
      Object.entries(data).map(([key, value]) => [key, String(value)]),
  );

  const invalidTokens = [];
  const failureDetails = [];
  const messageIds = [];

  let successCount = 0;
  let failureCount = 0;

  for (let index = 0; index < tokens.length; index += 500) {
    const tokenBatch = tokens.slice(index, index + 500);

    const response = await getMessaging().sendEachForMulticast({
      tokens: tokenBatch,
      notification: {
        title: text.title,
        body: text.body,
      },
      data: stringData,
      android: {
        priority: "high",
        notification: {
          channelId,
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
    });

    successCount += response.successCount;
    failureCount += response.failureCount;

    response.responses.forEach((result, responseIndex) => {
      const absoluteIndex = index + responseIndex;

      if (result.success) {
        if (result.messageId) {
          messageIds.push(result.messageId);
        }
        return;
      }

      const code = result.error?.code || "messaging/unknown-error";
      const message = result.error?.message || "Unknown FCM error.";

      failureDetails.push({
        tokenIndex: absoluteIndex,
        code,
        message,
      });

      if (
        code === "messaging/invalid-registration-token" ||
        code === "messaging/registration-token-not-registered"
      ) {
        invalidTokens.push(tokenBatch[responseIndex]);
      }

      logger.error("FCM send failed.", {
        userId,
        tokenIndex: absoluteIndex,
        code,
        message,
      });
    });
  }

  if (invalidTokens.length > 0) {
    await userReference.update({
      notificationTokens: FieldValue.arrayRemove(...invalidTokens),
      notificationTokensUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  const report = {
    deliveryStatus: successCount > 0 ?
      "accepted_by_fcm" :
      "failed_by_fcm",
    recipientId: userId,
    notificationType: String(data.type || ""),
    notificationChannelId: channelId,
    tokenCount: tokens.length,
    successCount,
    failureCount,
    messageIds: messageIds.slice(0, 20),
    failureDetails: failureDetails.slice(0, 20),
  };

  logger.info("FCM delivery result.", report);

  if (successCount === 0) {
    const errorSummary = failureDetails
        .map((failure) => `${failure.code}: ${failure.message}`)
        .join(" | ");

    const error = new Error(
        `FCM accepted 0 of ${tokens.length} messages for ${userId}. ` +
        (errorSummary || "No detailed error was returned."),
    );

    error.deliveryReport = report;
    throw error;
  }

  return report;
}
async function sendTradeNotification({
  recipientId,
  actorId,
  trade,
  tradeId,
  titleKey,
  bodyKey,
  archived = false,
}) {
  return sendNotificationToUser({
    userId: recipientId,
    sourceUserId: actorId,
    channelId: TRADE_CHANNEL_ID,
    data: {
      type: "trade",
      tradeId,
      tabIndex: tabIndexForUser(trade, recipientId, archived),
    },
    buildText: async (language) => {
      const actorName = await profileName(actorId, language);

      return localizedTradeText(
          language,
          titleKey,
          bodyKey,
          {name: actorName},
      );
    },
  });
}

function otherParticipant(trade, userId) {
  if (trade.senderId === userId) {
    return trade.receiverId;
  }

  if (trade.receiverId === userId) {
    return trade.senderId;
  }

  return "";
}

exports.notifyNewChatMessage = onDocumentCreated(
    "conversations/{conversationId}/messages/{messageId}",
    async (event) => runEventOnce(event, async () => {
      const messageSnapshot = event.data;

      if (!messageSnapshot) {
        return;
      }

      const message = messageSnapshot.data() || {};
      const senderId = String(message.senderId || "").trim();
      const text = cleanMessagePreview(message.text);

      if (!senderId || !text) {
        return;
      }

      const conversationId = event.params.conversationId;
      const conversationSnapshot = await db
          .collection("conversations")
          .doc(conversationId)
          .get();

      if (!conversationSnapshot.exists) {
        return;
      }

      const conversation = conversationSnapshot.data() || {};
      const participantIds = Array.isArray(conversation.participantIds) ?
        conversation.participantIds.map(String) :
        [];

      const recipientId = participantIds.find((id) => id !== senderId) || "";

      if (!recipientId) {
        return;
      }

      const participantNames = conversation.participantNames || {};
      const storedSenderName = String(participantNames[senderId] || "").trim();

      return sendNotificationToUser({
        userId: recipientId,
        sourceUserId: senderId,
        channelId: MESSAGE_CHANNEL_ID,
        data: {
          type: "message",
          conversationId,
          senderId,
        },
        buildText: async (language) => ({
          title: storedSenderName || await profileName(senderId, language),
          body: text,
        }),
      });
    }),
);

exports.notifyNewTrade = onDocumentCreated(
    "trades/{tradeId}",
    async (event) => runEventOnce(event, async () => {
      const snapshot = event.data;

      if (!snapshot) {
        return;
      }

      const trade = snapshot.data() || {};
      const senderId = String(trade.senderId || "").trim();
      const receiverId = String(trade.receiverId || "").trim();

      if (!senderId || !receiverId) {
        return;
      }

      return sendTradeNotification({
        recipientId: receiverId,
        actorId: senderId,
        trade,
        tradeId: event.params.tradeId,
        titleKey: "newTradeTitle",
        bodyKey: "newTradeBody",
      });
    }),
);

exports.notifyTradeUpdate = onDocumentUpdated(
    "trades/{tradeId}",
    async (event) => runEventOnce(event, async () => {
      const beforeSnapshot = event.data?.before;
      const afterSnapshot = event.data?.after;

      if (!beforeSnapshot || !afterSnapshot) {
        return;
      }

      const before = beforeSnapshot.data() || {};
      const after = afterSnapshot.data() || {};
      const tradeId = event.params.tradeId;

      const senderId = String(after.senderId || "").trim();
      const receiverId = String(after.receiverId || "").trim();

      if (!senderId || !receiverId) {
        return;
      }

      if (
        before.status !== "completed" &&
        after.status === "completed"
      ) {
        const reports = await Promise.all([
          sendNotificationToUser({
            userId: senderId,
            sourceUserId: receiverId,
            channelId: TRADE_CHANNEL_ID,
            data: {
              type: "trade",
              tradeId,
              tabIndex: "3",
            },
            buildText: async (language) => {
              const partnerName = await profileName(receiverId, language);

              return localizedTradeText(
                  language,
                  "completedTradeTitle",
                  "completedTradeBody",
                  {name: partnerName},
              );
            },
          }),
          sendNotificationToUser({
            userId: receiverId,
            sourceUserId: senderId,
            channelId: TRADE_CHANNEL_ID,
            data: {
              type: "trade",
              tradeId,
              tabIndex: "3",
            },
            buildText: async (language) => {
              const partnerName = await profileName(senderId, language);

              return localizedTradeText(
                  language,
                  "completedTradeTitle",
                  "completedTradeBody",
                  {name: partnerName},
              );
            },
          }),
        ]);

        return {
          deliveryStatus: reports.some(
              (report) => report.deliveryStatus === "accepted_by_fcm",
          ) ? "accepted_by_fcm" : "skipped_no_successful_delivery",
          recipientId: [senderId, receiverId].join(","),
          tokenCount: reports.reduce(
              (sum, report) => sum + (report.tokenCount || 0),
              0,
          ),
          successCount: reports.reduce(
              (sum, report) => sum + (report.successCount || 0),
              0,
          ),
          failureCount: reports.reduce(
              (sum, report) => sum + (report.failureCount || 0),
              0,
          ),
          deliveryReports: reports,
        };
      }

      if (before.status !== after.status) {
        if (after.status === "countered") {
          const actorId = String(after.lastProposedBy || "").trim();
          const recipientId = String(after.awaitingUserId || "").trim();

          if (actorId && recipientId) {
            return sendTradeNotification({
              recipientId,
              actorId,
              trade: after,
              tradeId,
              titleKey: "counterTradeTitle",
              bodyKey: "counterTradeBody",
            });
          }

          return;
        }

        if (after.status === "accepted" || after.status === "rejected") {
          const recipientId = String(
              before.lastProposedBy || after.lastProposedBy || "",
          ).trim();

          const actorId = String(
              before.awaitingUserId ||
              otherParticipant(after, recipientId),
          ).trim();

          if (actorId && recipientId) {
            return sendTradeNotification({
              recipientId,
              actorId,
              trade: after,
              tradeId,
              titleKey: after.status === "accepted" ?
                "acceptedTradeTitle" :
                "rejectedTradeTitle",
              bodyKey: after.status === "accepted" ?
                "acceptedTradeBody" :
                "rejectedTradeBody",
              archived: after.status === "rejected",
            });
          }

          return;
        }
      }

      const notifications = [];

      if (!before.senderShipped && after.senderShipped) {
        notifications.push(
            sendTradeNotification({
              recipientId: receiverId,
              actorId: senderId,
              trade: after,
              tradeId,
              titleKey: "shippedTradeTitle",
              bodyKey: "shippedTradeBody",
            }),
        );
      }

      if (!before.receiverShipped && after.receiverShipped) {
        notifications.push(
            sendTradeNotification({
              recipientId: senderId,
              actorId: receiverId,
              trade: after,
              tradeId,
              titleKey: "shippedTradeTitle",
              bodyKey: "shippedTradeBody",
            }),
        );
      }

      if (!before.senderReceived && after.senderReceived) {
        notifications.push(
            sendTradeNotification({
              recipientId: receiverId,
              actorId: senderId,
              trade: after,
              tradeId,
              titleKey: "receivedTradeTitle",
              bodyKey: "receivedTradeBody",
            }),
        );
      }

      if (!before.receiverReceived && after.receiverReceived) {
        notifications.push(
            sendTradeNotification({
              recipientId: senderId,
              actorId: receiverId,
              trade: after,
              tradeId,
              titleKey: "receivedTradeTitle",
              bodyKey: "receivedTradeBody",
            }),
        );
      }

      if (notifications.length === 0) {
        return {
          deliveryStatus: "skipped_no_notification_change",
          recipientId: "",
          tokenCount: 0,
          successCount: 0,
          failureCount: 0,
        };
      }

      const reports = await Promise.all(notifications);

      return {
        deliveryStatus: reports.some(
            (report) => report.deliveryStatus === "accepted_by_fcm",
        ) ? "accepted_by_fcm" : "skipped_no_successful_delivery",
        recipientId: reports
            .map((report) => report.recipientId)
            .filter(Boolean)
            .join(","),
        tokenCount: reports.reduce(
            (sum, report) => sum + (report.tokenCount || 0),
            0,
        ),
        successCount: reports.reduce(
            (sum, report) => sum + (report.successCount || 0),
            0,
        ),
        failureCount: reports.reduce(
            (sum, report) => sum + (report.failureCount || 0),
            0,
        ),
        deliveryReports: reports,
      };
    }),
);

async function sendDeliveryDetailsNotification({
  event,
  titleKey,
  bodyKey,
}) {
  const tradeId = String(event.params.tradeId || "").trim();
  const actorId = String(event.params.userId || "").trim();

  if (!tradeId || !actorId) {
    return {
      deliveryStatus: "skipped_missing_delivery_context",
      recipientId: "",
      tokenCount: 0,
      successCount: 0,
      failureCount: 0,
    };
  }

  const tradeSnapshot = await db.collection("trades").doc(tradeId).get();

  if (!tradeSnapshot.exists) {
    return {
      deliveryStatus: "skipped_missing_trade",
      recipientId: "",
      tokenCount: 0,
      successCount: 0,
      failureCount: 0,
    };
  }

  const trade = tradeSnapshot.data() || {};
  const recipientId = otherParticipant(trade, actorId);

  if (!recipientId) {
    return {
      deliveryStatus: "skipped_invalid_delivery_participant",
      recipientId: "",
      tokenCount: 0,
      successCount: 0,
      failureCount: 0,
    };
  }

  return sendTradeNotification({
    recipientId,
    actorId,
    trade,
    tradeId,
    titleKey,
    bodyKey,
    archived: trade.status === "completed",
  });
}

exports.notifyTradeDeliveryCreated = onDocumentCreated(
    "trades/{tradeId}/deliveryDetails/{userId}",
    async (event) => runEventOnce(event, async () => {
      if (!event.data) {
        return {
          deliveryStatus: "skipped_missing_delivery_document",
          recipientId: "",
          tokenCount: 0,
          successCount: 0,
          failureCount: 0,
        };
      }

      return sendDeliveryDetailsNotification({
        event,
        titleKey: "deliveryAddedTitle",
        bodyKey: "deliveryAddedBody",
      });
    }),
);

exports.notifyTradeDeliveryUpdated = onDocumentUpdated(
    "trades/{tradeId}/deliveryDetails/{userId}",
    async (event) => runEventOnce(event, async () => {
      const beforeSnapshot = event.data?.before;
      const afterSnapshot = event.data?.after;

      if (!beforeSnapshot || !afterSnapshot) {
        return {
          deliveryStatus: "skipped_missing_delivery_update",
          recipientId: "",
          tokenCount: 0,
          successCount: 0,
          failureCount: 0,
        };
      }

      const before = beforeSnapshot.data() || {};
      const after = afterSnapshot.data() || {};
      const beforeTracking = String(before.trackingNumber || "").trim();
      const afterTracking = String(after.trackingNumber || "").trim();

      const trackingChanged =
        afterTracking.length > 0 && beforeTracking !== afterTracking;

      return sendDeliveryDetailsNotification({
        event,
        titleKey: trackingChanged ?
          "trackingAddedTitle" :
          "deliveryUpdatedTitle",
        bodyKey: trackingChanged ?
          "trackingAddedBody" :
          "deliveryUpdatedBody",
      });
    }),
);

/**
 * P22A2B — trade aggregate reconciliation.
 *
 * The write event is only a signal. reconcileTradeAggregates always reads the
 * current canonical /trades/{tradeId} document and applies desired − previous
 * against _tradeAggregateState/{tradeId}.
 *
 * DO NOT DEPLOY until client cutover + backfill plan are reviewed.
 */
exports.reconcileTradeAggregatesOnWrite = onDocumentWritten(
    "trades/{tradeId}",
    async (event) => {
      const tradeId = String(event.params.tradeId || "").trim();

      if (!tradeId) {
        return {status: "skipped_missing_trade_id"};
      }

      try {
        const result = await reconcileTradeAggregates(db, tradeId, {logger});
        return {
          status: result.noop ? "noop" : "reconciled",
          tradeId,
          appliedCompletedDelta: result.appliedCompletedDelta || 0,
          effectiveTradeStatus: result.effectiveTradeStatus || null,
        };
      } catch (error) {
        if (error && error.code === "trade_item_limit_exceeded") {
          logger.error({
            event: "trade_item_limit_exceeded",
            tradeId,
            message: error.message,
            anomaly: "ANOMALY / MANUAL REVIEW",
          });
          return {status: "failed_item_limit", tradeId, anomaly: "ANOMALY / MANUAL REVIEW"};
        }

        if (error && error.code === "trade_invalid_for_reconcile") {
          logger.error({
            event: "trade_invalid_for_reconcile",
            tradeId,
            message: error.message,
            anomaly: "ANOMALY / MANUAL REVIEW",
          });
          return {
            status: "failed_invalid_trade",
            tradeId,
            anomaly: "ANOMALY / MANUAL REVIEW",
          };
        }

        if (error && error.code === "reservation_aggregate_underflow") {
          logger.error({
            event: "reservation_aggregate_underflow",
            tradeId,
            message: error.message,
            details: error.details || null,
            anomaly: "ANOMALY / MANUAL REVIEW",
          });
          return {
            status: "failed_reservation_underflow",
            tradeId,
            anomaly: "ANOMALY / MANUAL REVIEW",
          };
        }

        logger.error({
          event: "reconcile_trade_aggregates_failed",
          tradeId,
          message: error instanceof Error ? error.message : String(error),
        });
        throw error;
      }
    },
);

// Exported for unit tests / backfill scripts that import via index.
exports._tradeAggregates = {
  reconcileTradeAggregates,
  logReservationOvercommit,
};

