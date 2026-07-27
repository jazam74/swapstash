import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/features/trades/models/trade_action.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

abstract final class TradeActionService {
  static TradeAction build({
    required Trade trade,
    required String currentUserId,
    required AppLocalizations localizations,
  }) {
    if (trade.status == TradeStatus.completed) {
      return TradeAction(
        type: TradeActionType.completed,
        title: localizations.tradeActionCompletedTitle,
        description: localizations.tradeActionCompletedDescription,
        icon: Icons.check_circle,
        color: AppColors.success,
        backgroundColor: const Color(0xFFEAF7EE),
        isVisible: true,
        currentStep: 4,
      );
    }

    if (trade.status == TradeStatus.rejected) {
      return TradeAction(
        type: TradeActionType.unavailable,
        title: localizations.tradeActionRejectedTitle,
        description: localizations.tradeActionNoActionRequired,
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        backgroundColor: const Color(0xFFFDECEC),
        isVisible: true,
        currentStep: 0,
      );
    }

    if (trade.status == TradeStatus.cancelled) {
      return TradeAction(
        type: TradeActionType.unavailable,
        title: localizations.tradeActionCancelledTitle,
        description: localizations.tradeActionNoActionRequired,
        icon: Icons.block,
        color: AppColors.disabled,
        backgroundColor: const Color(0xFFF3F4F6),
        isVisible: true,
        currentStep: 0,
      );
    }

    if (trade.isAwaitingResponse) {
      final awaitingUserId = trade.awaitingUserId.isNotEmpty
          ? trade.awaitingUserId
          : trade.receiverId;
      final awaitingMe = awaitingUserId == currentUserId;

      if (awaitingMe) {
        return TradeAction(
          type: TradeActionType.respondToOffer,
          title: localizations.tradeActionYourTurnTitle,
          description: localizations.tradeActionReviewOfferDescription,
          icon: Icons.touch_app_outlined,
          color: AppColors.warning,
          backgroundColor: const Color(0xFFFFF7E6),
          isVisible: true,
          currentStep: 0,
        );
      }

      return TradeAction(
        type: TradeActionType.waiting,
        title: localizations.tradeActionOtherTurnTitle,
        description: localizations.tradeActionWaitingResponseDescription,
        icon: Icons.hourglass_top,
        color: AppColors.info,
        backgroundColor: const Color(0xFFEAF5FB),
        isVisible: true,
        currentStep: 0,
      );
    }

    if (trade.status != TradeStatus.accepted) {
      return TradeAction(
        type: TradeActionType.unavailable,
        title: localizations.tradeActionNoActionTitle,
        description: localizations.tradeActionStatusNoResponseDescription,
        icon: Icons.info_outline,
        color: AppColors.disabled,
        backgroundColor: const Color(0xFFF3F4F6),
        isVisible: true,
        currentStep: 0,
      );
    }

    final isSender = trade.senderId == currentUserId;
    final myHandedOver = isSender ? trade.senderShipped : trade.receiverShipped;
    final otherHandedOver = isSender
        ? trade.receiverShipped
        : trade.senderShipped;
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

    if (!myHandedOver) {
      return TradeAction(
        type: TradeActionType.confirmHandover,
        title: localizations.tradeActionNextStepTitle,
        description: localizations.tradeActionConfirmHandoverDescription,
        icon: Icons.how_to_reg_outlined,
        color: AppColors.primary,
        backgroundColor: const Color(0xFFEAF0FF),
        isVisible: true,
        currentStep: completedSteps,
      );
    }

    if (!myReceived && otherHandedOver) {
      return TradeAction(
        type: TradeActionType.confirmReceipt,
        title: localizations.tradeActionNextStepTitle,
        description: localizations.tradeActionConfirmReceiptDescription,
        icon: Icons.inventory_2_outlined,
        color: AppColors.tradeShipping,
        backgroundColor: const Color(0xFFFFF1E8),
        isVisible: true,
        currentStep: completedSteps,
      );
    }

    if (!otherHandedOver) {
      return TradeAction(
        type: TradeActionType.waiting,
        title: localizations.tradeActionOtherTurnTitle,
        description: localizations.tradeActionWaitingOtherHandoverDescription,
        icon: Icons.hourglass_top,
        color: AppColors.info,
        backgroundColor: const Color(0xFFEAF5FB),
        isVisible: true,
        currentStep: completedSteps,
      );
    }

    if (myReceived && !otherReceived) {
      return TradeAction(
        type: TradeActionType.waiting,
        title: localizations.tradeActionWaitingOtherConfirmationTitle,
        description: localizations.tradeActionWaitingOtherReceiptDescription,
        icon: Icons.hourglass_bottom,
        color: AppColors.info,
        backgroundColor: const Color(0xFFEAF5FB),
        isVisible: true,
        currentStep: completedSteps,
      );
    }

    return TradeAction(
      type: TradeActionType.waiting,
      title: localizations.tradeActionNoActionTitle,
      description: localizations.tradeActionWaitingNextConfirmationDescription,
      icon: Icons.schedule,
      color: AppColors.info,
      backgroundColor: const Color(0xFFEAF5FB),
      isVisible: true,
      currentStep: completedSteps,
    );
  }
}
