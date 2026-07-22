import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/features/trades/counter_offer_page.dart';
import 'package:swapstash/features/trades/create_trade_page.dart';
import 'package:swapstash/features/trades/services/trade_action_service.dart';
import 'package:swapstash/features/trades/services/trade_status_display_service.dart';
import 'package:swapstash/features/trades/widgets/trade_action_card.dart';
import 'package:swapstash/features/trades/widgets/trade_confirm_dialog.dart';
import 'package:swapstash/features/trades/widgets/trade_header.dart';
import 'package:swapstash/features/trades/widgets/trade_progress_card.dart';
import 'package:swapstash/features/trades/widgets/trade_summary_card.dart';
import 'package:swapstash/features/trades/widgets/trade_items_card.dart';

class TradesPage extends StatelessWidget {
  final int initialTabIndex;
  final String? highlightedTradeId;

  const TradesPage({
    super.key,
    this.initialTabIndex = 0,
    this.highlightedTradeId,
  });

  @override
  Widget build(BuildContext context) {
    final tradeService = TradeService();

    final selectedTabIndex = initialTabIndex < 0
        ? 0
        : initialTabIndex > 2
        ? 2
        : initialTabIndex;

    return DefaultTabController(
      length: 3,
      initialIndex: selectedTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menjave'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inbox_outlined), text: 'Prejete'),
              Tab(icon: Icon(Icons.send_outlined), text: 'Poslane'),
              Tab(icon: Icon(Icons.check_circle_outline), text: 'Zaključene'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TradesStreamView(
              stream: tradeService.watchIncomingTrades(),
              tradeService: tradeService,
              currentUserId: tradeService.currentUserId,
              direction: _TradeDirection.incoming,
              emptyMessage: 'Ni prejetih menjav.',
              highlightedTradeId: highlightedTradeId,
            ),
            _TradesStreamView(
              stream: tradeService.watchOutgoingTrades(),
              tradeService: tradeService,
              currentUserId: tradeService.currentUserId,
              direction: _TradeDirection.outgoing,
              emptyMessage: 'Ni poslanih menjav.',
              highlightedTradeId: highlightedTradeId,
            ),
            _CompletedTradesView(
              tradeService: tradeService,
              currentUserId: tradeService.currentUserId,
              highlightedTradeId: highlightedTradeId,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'trades_fab',
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CreateTradePage()));
          },
          icon: const Icon(Icons.add),
          label: const Text('Nova menjava'),
        ),
      ),
    );
  }
}

enum _TradeDirection { incoming, outgoing }

class _TradesStreamView extends StatelessWidget {
  final Stream<List<Trade>> stream;
  final TradeService tradeService;
  final String currentUserId;
  final _TradeDirection direction;
  final String emptyMessage;
  final String? highlightedTradeId;

  const _TradesStreamView({
    required this.stream,
    required this.tradeService,
    required this.currentUserId,
    required this.direction,
    required this.emptyMessage,
    this.highlightedTradeId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trade>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _TradeErrorView(error: snapshot.error);
        }

        final trades = (snapshot.data ?? [])
            .where((trade) => trade.status != TradeStatus.completed)
            .toList();

        _moveTradeToTop(trades: trades, highlightedTradeId: highlightedTradeId);

        if (trades.isEmpty) {
          return _EmptyTrades(
            icon: direction == _TradeDirection.incoming
                ? Icons.inbox_outlined
                : Icons.send_outlined,
            text: emptyMessage,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            96,
          ),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            return _TradeCard(
              trade: trades[index],
              tradeService: tradeService,
              currentUserId: currentUserId,
              direction: direction,
              isHighlighted: trades[index].id == highlightedTradeId,
            );
          },
        );
      },
    );
  }
}

class _CompletedTradesView extends StatelessWidget {
  final TradeService tradeService;
  final String currentUserId;
  final String? highlightedTradeId;

  const _CompletedTradesView({
    required this.tradeService,
    required this.currentUserId,
    this.highlightedTradeId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trade>>(
      stream: tradeService.watchIncomingTrades(),
      builder: (context, incomingSnapshot) {
        if (incomingSnapshot.hasError) {
          return _TradeErrorView(error: incomingSnapshot.error);
        }

        return StreamBuilder<List<Trade>>(
          stream: tradeService.watchOutgoingTrades(),
          builder: (context, outgoingSnapshot) {
            if (outgoingSnapshot.hasError) {
              return _TradeErrorView(error: outgoingSnapshot.error);
            }

            final completed = <String, Trade>{};

            for (final trade in [
              ...incomingSnapshot.data ?? <Trade>[],
              ...outgoingSnapshot.data ?? <Trade>[],
            ]) {
              if (trade.status == TradeStatus.completed) {
                completed[trade.id] = trade;
              }
            }

            final trades = completed.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            _moveTradeToTop(
              trades: trades,
              highlightedTradeId: highlightedTradeId,
            );

            if (trades.isEmpty) {
              return const _EmptyTrades(
                icon: Icons.check_circle_outline,
                text: 'Ni zaključenih menjav.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                96,
              ),
              itemCount: trades.length,
              itemBuilder: (context, index) {
                final trade = trades[index];

                return _TradeCard(
                  trade: trade,
                  tradeService: tradeService,
                  currentUserId: currentUserId,
                  direction: trade.receiverId == currentUserId
                      ? _TradeDirection.incoming
                      : _TradeDirection.outgoing,
                  isHighlighted: trade.id == highlightedTradeId,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TradeCard extends StatefulWidget {
  final Trade trade;
  final TradeService tradeService;
  final String currentUserId;
  final _TradeDirection direction;
  final bool isHighlighted;

  const _TradeCard({
    required this.trade,
    required this.tradeService,
    required this.currentUserId,
    required this.direction,
    this.isHighlighted = false,
  });

  @override
  State<_TradeCard> createState() => _TradeCardState();
}

class _TradeCardState extends State<_TradeCard> {
  bool _isUpdating = false;

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await action();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dejanja ni bilo mogoče izvesti: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _openCounterOffer() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CounterOfferPage(trade: widget.trade)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trade = widget.trade;
    final isIncoming = widget.direction == _TradeDirection.incoming;
    final otherUserId = isIncoming ? trade.senderId : trade.receiverId;

    final offeredItems = isIncoming ? trade.requestedItems : trade.offeredItems;
    final receivedItems = isIncoming
        ? trade.offeredItems
        : trade.requestedItems;

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      elevation: widget.isHighlighted ? 3 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: widget.isHighlighted
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isHighlighted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: colorScheme.primary.withValues(alpha: 0.10),
              child: Row(
                children: [
                  Icon(
                    Icons.link_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Menjava iz opravila',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          TradeHeader(
            status: TradeStatusDisplayService.build(
              trade: trade,
              currentUserId: widget.currentUserId,
            ),
            directionLabel: trade.status == TradeStatus.countered
                ? 'PROTIPONUDBA'
                : isIncoming
                ? 'PREJETA PONUDBA'
                : 'POSLANA PONUDBA',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TradeActionCard(
                  action: TradeActionService.build(
                    trade: trade,
                    currentUserId: widget.currentUserId,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TradeSummaryCard(
                  trade: trade,
                  currentUserId: widget.currentUserId,
                  otherUserLabel: _shortUserId(otherUserId),
                ),
                const SizedBox(height: AppSpacing.md),
                TradeItemsCard(
                  title: 'Oddaš',
                  icon: Icons.upload_rounded,
                  accentColor: Theme.of(context).colorScheme.primary,
                  items: offeredItems,
                ),
                const SizedBox(height: AppSpacing.sm),
                TradeItemsCard(
                  title: 'Prejmeš',
                  icon: Icons.download_rounded,
                  accentColor: Theme.of(context).colorScheme.tertiary,
                  items: receivedItems,
                ),
                if (trade.status == TradeStatus.accepted) ...[
                  const SizedBox(height: AppSpacing.md),
                  TradeProgressCard(
                    trade: trade,
                    currentUserId: widget.currentUserId,
                  ),
                ],
                if (_buildActions() case final actions?) ...[
                  const SizedBox(height: AppSpacing.md),
                  actions,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmHandover() async {
    final confirmed = await TradeConfirmDialog.confirmHandover(context);

    if (!confirmed || !mounted) {
      return;
    }

    await _runAction(
      () => widget.tradeService.markShipped(tradeId: widget.trade.id),
      'Predaja kartic je potrjena in inventar je posodobljen.',
    );
  }

  Future<void> _confirmReceipt() async {
    final confirmed = await TradeConfirmDialog.confirmReceipt(context);

    if (!confirmed || !mounted) {
      return;
    }

    await _runAction(
      () => widget.tradeService.markReceived(tradeId: widget.trade.id),
      'Prejem kartic je potrjen in inventar je posodobljen.',
    );
  }

  Widget? _buildActions() {
    final trade = widget.trade;

    if (_isUpdating) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (trade.isAwaitingResponse) {
      final awaitingMe = trade.awaitingUserId.isEmpty
          ? widget.direction == _TradeDirection.incoming
          : trade.awaitingUserId == widget.currentUserId;

      if (awaitingMe) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _runAction(
                        () =>
                            widget.tradeService.rejectTrade(tradeId: trade.id),
                        'Ponudba je bila zavrnjena.',
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Zavrni'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _runAction(
                        () =>
                            widget.tradeService.acceptTrade(tradeId: trade.id),
                        'Menjava je bila sprejeta.',
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Sprejmi'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _openCounterOffer,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Pošlji protiponudbo'),
            ),
          ],
        );
      }

      if (trade.lastProposedBy == widget.currentUserId) {
        return OutlinedButton.icon(
          onPressed: () {
            _runAction(
              () => widget.tradeService.cancelTrade(tradeId: trade.id),
              'Ponudba je bila preklicana.',
            );
          },
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Prekliči ponudbo'),
        );
      }

      // TradeActionCard already explains that the other side must respond.
      return null;
    }

    if (trade.status == TradeStatus.accepted) {
      final isSender = trade.senderId == widget.currentUserId;
      final shipped = isSender ? trade.senderShipped : trade.receiverShipped;
      final received = isSender ? trade.senderReceived : trade.receiverReceived;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: shipped ? null : _confirmHandover,
            icon: Icon(
              shipped ? Icons.check_circle : Icons.how_to_reg_outlined,
            ),
            label: Text(
              shipped ? 'Predaja potrjena ✓' : 'Potrdi predajo kartic',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: received ? null : _confirmReceipt,
            icon: Icon(
              received ? Icons.check_circle : Icons.inventory_outlined,
            ),
            label: Text(received ? 'Prejem potrjen ✓' : 'Potrdi prejem kartic'),
          ),
        ],
      );
    }

    return null;
  }

  String _shortUserId(String userId) {
    if (userId.length <= 10) return userId;
    return '${userId.substring(0, 10)}…';
  }
}

void _moveTradeToTop({
  required List<Trade> trades,
  required String? highlightedTradeId,
}) {
  final id = highlightedTradeId?.trim();

  if (id == null || id.isEmpty) {
    return;
  }

  final index = trades.indexWhere((trade) => trade.id == id);

  if (index <= 0) {
    return;
  }

  final selectedTrade = trades.removeAt(index);
  trades.insert(0, selectedTrade);
}

class _EmptyTrades extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyTrades({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: AppSpacing.sm),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TradeErrorView extends StatelessWidget {
  final Object? error;

  const _TradeErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Menjav ni bilo mogoče naložiti:\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
