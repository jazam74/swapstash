import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/features/trades/models/trade_display_status.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

abstract final class TradeStatusDisplayService {
  static TradeDisplayStatus build({
    required Trade trade,
    required String currentUserId,
    required AppLocalizations localizations,
  }) {
    switch (trade.status) {
      case TradeStatus.pending:
        return _awaitingStatus(
          trade: trade,
          currentUserId: currentUserId,
          isCounterOffer: false,
          localizations: localizations,
        );
      case TradeStatus.countered:
        return _awaitingStatus(
          trade: trade,
          currentUserId: currentUserId,
          isCounterOffer: true,
          localizations: localizations,
        );
      case TradeStatus.accepted:
        return _acceptedStatus(
          trade: trade,
          currentUserId: currentUserId,
          localizations: localizations,
        );
      case TradeStatus.completed:
        return TradeDisplayStatus(
          title: localizations.tradeStatusCompletedTitle,
          subtitle: localizations.tradeStatusCompletedSubtitle,
          badgeLabel: localizations.tradeStatusCompletedBadge,
          icon: Icons.check_circle,
          color: AppColors.success,
          backgroundColor: const Color(0xFFEAF7EE),
          completedSteps: 4,
        );
      case TradeStatus.rejected:
        return TradeDisplayStatus(
          title: localizations.tradeStatusRejectedTitle,
          subtitle: localizations.tradeStatusRejectedSubtitle,
          badgeLabel: localizations.tradeStatusRejectedBadge,
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          backgroundColor: const Color(0xFFFDECEC),
          completedSteps: 0,
        );
      case TradeStatus.cancelled:
        return TradeDisplayStatus(
          title: localizations.tradeStatusCancelledTitle,
          subtitle: localizations.tradeStatusCancelledSubtitle,
          badgeLabel: localizations.tradeStatusCancelledBadge,
          icon: Icons.block,
          color: AppColors.disabled,
          backgroundColor: const Color(0xFFF3F4F6),
          completedSteps: 0,
        );
    }
  }

  static TradeDisplayStatus _awaitingStatus({
    required Trade trade,
    required String currentUserId,
    required bool isCounterOffer,
    required AppLocalizations localizations,
  }) {
    final awaitingMe = trade.awaitingUserId.isNotEmpty
        ? trade.awaitingUserId == currentUserId
        : trade.receiverId == currentUserId;

    if (awaitingMe) {
      return TradeDisplayStatus(
        title: isCounterOffer
            ? (localizations.tradeStatusCounterOfferReceivedTitle)
            : (localizations.tradeStatusAwaitingYourResponseTitle),
        subtitle: localizations.tradeStatusReviewOfferSubtitle,
        badgeLabel: localizations.tradeStatusWaitingForYouBadge,
        icon: isCounterOffer ? Icons.swap_horiz : Icons.notifications_active,
        color: AppColors.warning,
        backgroundColor: const Color(0xFFFFF7E6),
        completedSteps: 0,
      );
    }

    return TradeDisplayStatus(
      title: isCounterOffer
          ? (localizations.tradeStatusCounterOfferSentTitle)
          : (localizations.tradeStatusOfferSentTitle),
      subtitle: localizations.tradeStatusWaitingOtherUserSubtitle,
      badgeLabel: localizations.tradeStatusWaitingResponseBadge,
      icon: isCounterOffer ? Icons.swap_horiz : Icons.schedule,
      color: AppColors.info,
      backgroundColor: const Color(0xFFEAF5FB),
      completedSteps: 0,
    );
  }

  static TradeDisplayStatus _acceptedStatus({
    required Trade trade,
    required String currentUserId,
    required AppLocalizations localizations,
  }) {
    final isSender = trade.senderId == currentUserId;
    final myShipped = isSender ? trade.senderShipped : trade.receiverShipped;
    final otherShipped = isSender ? trade.receiverShipped : trade.senderShipped;
    final myReceived = isSender ? trade.senderReceived : trade.receiverReceived;
    final otherReceived = isSender
        ? trade.receiverReceived
        : trade.senderReceived;

    final completedSteps = [
      trade.senderShipped,
      trade.receiverShipped,
      trade.senderReceived,
      trade.receiverReceived,
    ].where((value) => value).length;

    if (myReceived && !otherReceived) {
      return TradeDisplayStatus(
        title: localizations.tradeStatusReceivedTitle,
        subtitle: localizations.tradeStatusReceivedSubtitle,
        badgeLabel: localizations.tradeStatusReceivedBadge,
        icon: Icons.inventory_2,
        color: AppColors.success,
        backgroundColor: const Color(0xFFEAF7EE),
        completedSteps: completedSteps,
      );
    }

    if (!myReceived && otherShipped) {
      return TradeDisplayStatus(
        title: myShipped
            ? (localizations.tradeStatusBothOnWayTitle)
            : (localizations.tradeStatusPackageOnWayTitle),
        subtitle: myShipped
            ? (localizations.tradeStatusBothOnWaySubtitle)
            : (localizations.tradeStatusOtherSentSubtitle),
        badgeLabel: localizations.tradeStatusOnWayBadge,
        icon: Icons.local_shipping_outlined,
        color: AppColors.tradeShipping,
        backgroundColor: const Color(0xFFFFF1E8),
        completedSteps: completedSteps,
      );
    }

    if (myShipped && !otherShipped) {
      return TradeDisplayStatus(
        title: localizations.tradeStatusSentTitle,
        subtitle: localizations.tradeStatusSentSubtitle,
        badgeLabel: localizations.tradeStatusSentBadge,
        icon: Icons.outbox_outlined,
        color: AppColors.primary,
        backgroundColor: const Color(0xFFEAF0FF),
        completedSteps: completedSteps,
      );
    }

    if (otherReceived && !myReceived) {
      return TradeDisplayStatus(
        title: localizations.tradeStatusOtherReceivedTitle,
        subtitle: localizations.tradeStatusConfirmWhenReceivedSubtitle,
        badgeLabel: localizations.tradeStatusWaitingReceiptBadge,
        icon: Icons.markunread_mailbox_outlined,
        color: AppColors.tradeShipping,
        backgroundColor: const Color(0xFFFFF1E8),
        completedSteps: completedSteps,
      );
    }

    return TradeDisplayStatus(
      title: localizations.tradeStatusAgreedTitle,
      subtitle: localizations.tradeStatusAgreedSubtitle,
      badgeLabel: localizations.tradeStatusAgreedBadge,
      icon: Icons.handshake_outlined,
      color: AppColors.tradeAccepted,
      backgroundColor: const Color(0xFFEAF0FF),
      completedSteps: 0,
    );
  }
}
