import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/features/trades/models/trade_display_status.dart';

abstract final class TradeStatusDisplayService {
  static TradeDisplayStatus build({
    required Trade trade,
    required String currentUserId,
  }) {
    switch (trade.status) {
      case TradeStatus.pending:
        return _awaitingStatus(
          trade: trade,
          currentUserId: currentUserId,
          isCounterOffer: false,
        );
      case TradeStatus.countered:
        return _awaitingStatus(
          trade: trade,
          currentUserId: currentUserId,
          isCounterOffer: true,
        );
      case TradeStatus.accepted:
        return _acceptedStatus(trade: trade, currentUserId: currentUserId);
      case TradeStatus.completed:
        return const TradeDisplayStatus(
          title: 'Menjava zaključena',
          subtitle: 'Oba uporabnika sta potrdila pošiljanje in prejem.',
          badgeLabel: 'Zaključena',
          icon: Icons.check_circle,
          color: AppColors.success,
          backgroundColor: Color(0xFFEAF7EE),
          completedSteps: 4,
        );
      case TradeStatus.rejected:
        return const TradeDisplayStatus(
          title: 'Ponudba zavrnjena',
          subtitle: 'Ta predlog menjave ni bil sprejet.',
          badgeLabel: 'Zavrnjena',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          backgroundColor: Color(0xFFFDECEC),
          completedSteps: 0,
        );
      case TradeStatus.cancelled:
        return const TradeDisplayStatus(
          title: 'Ponudba preklicana',
          subtitle: 'Pošiljatelj je predlog menjave preklical.',
          badgeLabel: 'Preklicana',
          icon: Icons.block,
          color: AppColors.disabled,
          backgroundColor: Color(0xFFF3F4F6),
          completedSteps: 0,
        );
    }
  }

  static TradeDisplayStatus _awaitingStatus({
    required Trade trade,
    required String currentUserId,
    required bool isCounterOffer,
  }) {
    final awaitingMe = trade.awaitingUserId.isNotEmpty
        ? trade.awaitingUserId == currentUserId
        : trade.receiverId == currentUserId;

    if (awaitingMe) {
      return TradeDisplayStatus(
        title: isCounterOffer
            ? 'Prejel si protiponudbo'
            : 'Ponudba čaka na tvoj odgovor',
        subtitle: 'Preglej kartice in izberi Sprejmi, Zavrni ali Protiponudba.',
        badgeLabel: 'Čaka nate',
        icon: isCounterOffer ? Icons.swap_horiz : Icons.notifications_active,
        color: AppColors.warning,
        backgroundColor: const Color(0xFFFFF7E6),
        completedSteps: 0,
      );
    }

    return TradeDisplayStatus(
      title: isCounterOffer ? 'Protiponudba poslana' : 'Ponudba poslana',
      subtitle: 'Čaka se odgovor drugega uporabnika.',
      badgeLabel: 'Čaka odgovor',
      icon: isCounterOffer ? Icons.swap_horiz : Icons.schedule,
      color: AppColors.info,
      backgroundColor: const Color(0xFFEAF5FB),
      completedSteps: 0,
    );
  }

  static TradeDisplayStatus _acceptedStatus({
    required Trade trade,
    required String currentUserId,
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
        title: 'Paket si prejel',
        subtitle:
            'Prejete kartice so dodane v inventar. Čaka se še potrditev druge strani.',
        badgeLabel: 'Prejel',
        icon: Icons.inventory_2,
        color: AppColors.success,
        backgroundColor: const Color(0xFFEAF7EE),
        completedSteps: completedSteps,
      );
    }

    if (!myReceived && otherShipped) {
      return TradeDisplayStatus(
        title: myShipped ? 'Pošiljki sta na poti' : 'Paket je na poti k tebi',
        subtitle: myShipped
            ? 'Obe pošiljki sta oddani. Ko paket prejmeš, potrdi prejem.'
            : 'Druga stran je paket oddala. Tvoje kartice so še rezervirane.',
        badgeLabel: 'Na poti',
        icon: Icons.local_shipping_outlined,
        color: AppColors.tradeShipping,
        backgroundColor: const Color(0xFFFFF1E8),
        completedSteps: completedSteps,
      );
    }

    if (myShipped && !otherShipped) {
      return TradeDisplayStatus(
        title: 'Paket si poslal',
        subtitle:
            'Oddane kartice so odstranjene iz inventarja. Čaka se druga stran.',
        badgeLabel: 'Poslal',
        icon: Icons.outbox_outlined,
        color: AppColors.primary,
        backgroundColor: const Color(0xFFEAF0FF),
        completedSteps: completedSteps,
      );
    }

    if (otherReceived && !myReceived) {
      return TradeDisplayStatus(
        title: 'Druga stran je paket prejela',
        subtitle: 'Ko prejmeš svojo pošiljko, potrdi prejem.',
        badgeLabel: 'Čaka prejem',
        icon: Icons.markunread_mailbox_outlined,
        color: AppColors.tradeShipping,
        backgroundColor: const Color(0xFFFFF1E8),
        completedSteps: completedSteps,
      );
    }

    return const TradeDisplayStatus(
      title: 'Menjava dogovorjena',
      subtitle:
          'Kartice na obeh straneh so rezervirane. Inventar se spremeni šele ob potrditvi pošiljanja ali prejema.',
      badgeLabel: 'Dogovorjena',
      icon: Icons.handshake_outlined,
      color: AppColors.tradeAccepted,
      backgroundColor: Color(0xFFEAF0FF),
      completedSteps: 0,
    );
  }
}
