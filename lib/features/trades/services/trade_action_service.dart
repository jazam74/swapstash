import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/features/trades/models/trade_action.dart';

abstract final class TradeActionService {
  static TradeAction build({
    required Trade trade,
    required String currentUserId,
  }) {
    if (trade.status == TradeStatus.completed) {
      return const TradeAction(
        type: TradeActionType.completed,
        title: 'Menjava je zaključena',
        description:
            'Obe strani sta potrdili predajo in prejem kartic. Inventarja sta posodobljena.',
        icon: Icons.check_circle,
        color: AppColors.success,
        backgroundColor: Color(0xFFEAF7EE),
        isVisible: true,
        currentStep: 4,
      );
    }

    if (trade.status == TradeStatus.rejected) {
      return const TradeAction(
        type: TradeActionType.unavailable,
        title: 'Ponudba je bila zavrnjena',
        description: 'Pri tej ponudbi ni več potrebna nobena akcija.',
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        backgroundColor: Color(0xFFFDECEC),
        isVisible: true,
        currentStep: 0,
      );
    }

    if (trade.status == TradeStatus.cancelled) {
      return const TradeAction(
        type: TradeActionType.unavailable,
        title: 'Ponudba je bila preklicana',
        description: 'Pri tej ponudbi ni več potrebna nobena akcija.',
        icon: Icons.block,
        color: AppColors.disabled,
        backgroundColor: Color(0xFFF3F4F6),
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
          title: 'Na potezi si ti',
          description:
              'Preglej kartice in ponudbo sprejmi, zavrni ali pošlji protiponudbo.',
          icon: Icons.touch_app_outlined,
          color: AppColors.warning,
          backgroundColor: const Color(0xFFFFF7E6),
          isVisible: true,
          currentStep: 0,
        );
      }

      return const TradeAction(
        type: TradeActionType.waiting,
        title: 'Na potezi je druga stran',
        description:
            'Trenutno ni potrebna nobena akcija. Čaka se odgovor drugega uporabnika.',
        icon: Icons.hourglass_top,
        color: AppColors.info,
        backgroundColor: Color(0xFFEAF5FB),
        isVisible: true,
        currentStep: 0,
      );
    }

    if (trade.status != TradeStatus.accepted) {
      return const TradeAction(
        type: TradeActionType.unavailable,
        title: 'Trenutno ni potrebna nobena akcija',
        description: 'Stanje menjave ne zahteva tvojega odziva.',
        icon: Icons.info_outline,
        color: AppColors.disabled,
        backgroundColor: Color(0xFFF3F4F6),
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
        title: 'Naslednji korak',
        description:
            'Ko svoje kartice dejansko predaš drugi strani, potrdi predajo. Nato bodo odštete iz tvojega inventarja.',
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
        title: 'Naslednji korak',
        description:
            'Ko dogovorjene kartice dejansko prejmeš, potrdi prejem. Nato bodo dodane v tvoj inventar.',
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
        title: 'Na potezi je druga stran',
        description:
            'Ti si predajo že potrdil. Čaka se, da druga stran preda svoje kartice.',
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
        title: 'Čaka se potrditev druge strani',
        description:
            'Ti si prejem že potrdil. Menjava se zaključi, ko tudi druga stran potrdi prejem.',
        icon: Icons.hourglass_bottom,
        color: AppColors.info,
        backgroundColor: const Color(0xFFEAF5FB),
        isVisible: true,
        currentStep: completedSteps,
      );
    }

    return TradeAction(
      type: TradeActionType.waiting,
      title: 'Trenutno ni potrebna nobena akcija',
      description: 'Čaka se naslednja potrditev druge strani.',
      icon: Icons.schedule,
      color: AppColors.info,
      backgroundColor: const Color(0xFFEAF5FB),
      isVisible: true,
      currentStep: completedSteps,
    );
  }
}
