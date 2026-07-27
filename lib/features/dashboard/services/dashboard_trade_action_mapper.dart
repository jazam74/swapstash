import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/features/dashboard/models/dashboard_action.dart';
import 'package:swapstash/features/trades/models/trade_action.dart';
import 'package:swapstash/features/trades/services/trade_action_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

abstract final class DashboardTradeActionMapper {
  static List<DashboardAction> build({
    required List<Trade> incomingTrades,
    required List<Trade> outgoingTrades,
    required String currentUserId,
    required AppLocalizations localizations,
    int limit = 5,
  }) {
    final tradesById = <String, Trade>{};

    for (final trade in [...incomingTrades, ...outgoingTrades]) {
      tradesById[trade.id] = trade;
    }

    final candidates = <_DashboardTradeActionCandidate>[];

    for (final trade in tradesById.values) {
      final tradeAction = TradeActionService.build(
        trade: trade,
        currentUserId: currentUserId,
        localizations: localizations,
      );

      if (!tradeAction.requiresUserAction) {
        continue;
      }

      final otherUserId = trade.senderId == currentUserId
          ? trade.receiverId
          : trade.senderId;

      candidates.add(
        _DashboardTradeActionCandidate(
          action: DashboardAction(
            icon: tradeAction.icon,
            color: tradeAction.color,
            title: _titleFor(
              type: tradeAction.type,
              tradeStatus: trade.status,
              localizations: localizations,
            ),
            subtitle: otherUserId.trim().isEmpty
                ? localizations.dashboardOpenTradeAndContinue
                : localizations.dashboardTradeWithUser(
                    _shortUserId(otherUserId),
                  ),
            tradeId: trade.id,
            tradeTabIndex: _tabIndexFor(
              trade: trade,
              currentUserId: currentUserId,
            ),
            priority: _priorityFor(tradeAction.type),
            sortAt: trade.updatedAt ?? trade.createdAt,
          ),
          priority: _priorityFor(tradeAction.type),
          updatedAt: trade.updatedAt ?? trade.createdAt,
        ),
      );
    }

    candidates.sort((first, second) {
      final priorityComparison = first.priority.compareTo(second.priority);

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      return second.updatedAt.compareTo(first.updatedAt);
    });

    return candidates
        .take(limit)
        .map((candidate) => candidate.action)
        .toList(growable: false);
  }

  static int _tabIndexFor({
    required Trade trade,
    required String currentUserId,
  }) {
    if (trade.status == TradeStatus.completed) {
      return 3;
    }

    return trade.senderId == currentUserId ? 2 : 1;
  }

  static String _titleFor({
    required TradeActionType type,
    required TradeStatus tradeStatus,
    required AppLocalizations localizations,
  }) {
    switch (type) {
      case TradeActionType.respondToOffer:
        return tradeStatus == TradeStatus.countered
            ? localizations.dashboardRespondToCounterOffer
            : localizations.dashboardRespondToOffer;
      case TradeActionType.confirmHandover:
        return localizations.dashboardConfirmHandover;
      case TradeActionType.confirmReceipt:
        return localizations.dashboardConfirmReceipt;
      case TradeActionType.waiting:
      case TradeActionType.completed:
      case TradeActionType.unavailable:
        return localizations.dashboardOpenTrade;
    }
  }

  static int _priorityFor(TradeActionType type) {
    switch (type) {
      case TradeActionType.respondToOffer:
        return 0;
      case TradeActionType.confirmReceipt:
        return 2;
      case TradeActionType.confirmHandover:
        return 3;
      case TradeActionType.waiting:
      case TradeActionType.completed:
      case TradeActionType.unavailable:
        return 99;
    }
  }

  static String _shortUserId(String userId) {
    final value = userId.trim();

    if (value.length <= 8) {
      return value;
    }

    return '${value.substring(0, 8)}…';
  }
}

class _DashboardTradeActionCandidate {
  final DashboardAction action;
  final int priority;
  final DateTime updatedAt;

  const _DashboardTradeActionCandidate({
    required this.action,
    required this.priority,
    required this.updatedAt,
  });
}
