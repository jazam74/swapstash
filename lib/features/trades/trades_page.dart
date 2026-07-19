import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_item.dart';
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

class TradesPage extends StatelessWidget {
  const TradesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tradeService = TradeService();

    return DefaultTabController(
      length: 3,
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
            ),
            _TradesStreamView(
              stream: tradeService.watchOutgoingTrades(),
              tradeService: tradeService,
              currentUserId: tradeService.currentUserId,
              direction: _TradeDirection.outgoing,
              emptyMessage: 'Ni poslanih menjav.',
            ),
            _CompletedTradesView(
              tradeService: tradeService,
              currentUserId: tradeService.currentUserId,
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

  const _TradesStreamView({
    required this.stream,
    required this.tradeService,
    required this.currentUserId,
    required this.direction,
    required this.emptyMessage,
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

        if (trades.isEmpty) {
          return _EmptyTrades(
            icon: direction == _TradeDirection.incoming
                ? Icons.inbox_outlined
                : Icons.send_outlined,
            text: emptyMessage,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            return _TradeCard(
              trade: trades[index],
              tradeService: tradeService,
              currentUserId: currentUserId,
              direction: direction,
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

  const _CompletedTradesView({
    required this.tradeService,
    required this.currentUserId,
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

            if (trades.isEmpty) {
              return const _EmptyTrades(
                icon: Icons.check_circle_outline,
                text: 'Ni zaključenih menjav.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
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

  const _TradeCard({
    required this.trade,
    required this.tradeService,
    required this.currentUserId,
    required this.direction,
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 8),
            TradeSummaryCard(
              trade: trade,
              currentUserId: widget.currentUserId,
              otherUserLabel: _shortUserId(otherUserId),
            ),
            const SizedBox(height: AppSpacing.md),
            TradeActionCard(
              action: TradeActionService.build(
                trade: trade,
                currentUserId: widget.currentUserId,
              ),
            ),
            const Divider(height: AppSpacing.lg),
            _TradeItemsSection(
              title: isIncoming ? 'Prejmeš' : 'Ponudil si',
              icon: Icons.inventory_2_outlined,
              items: trade.offeredItems,
            ),
            const SizedBox(height: 12),
            _TradeItemsSection(
              title: isIncoming ? 'Oddaš' : 'Želiš',
              icon: Icons.search_outlined,
              items: trade.requestedItems,
            ),
            if (trade.status == TradeStatus.accepted) ...[
              const SizedBox(height: 16),
              TradeProgressCard(
                trade: trade,
                currentUserId: widget.currentUserId,
              ),
            ],
            if (_buildActions() case final actions?) ...[
              const SizedBox(height: 14),
              actions,
            ],
          ],
        ),
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

      return const Text(
        'Čaka se odgovor drugega uporabnika.',
        textAlign: TextAlign.center,
      );
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

class _TradeItemsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<TradeItem> items;

  const _TradeItemsSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('Ni predmetov.')
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) {
              final quantityText = item.quantity > 1
                  ? ' ×${item.quantity}'
                  : '';

              return Chip(label: Text('#${item.itemNumber}$quantityText'));
            }).toList(),
          ),
      ],
    );
  }
}

class _EmptyTrades extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyTrades({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 12),
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
        padding: const EdgeInsets.all(24),
        child: Text(
          'Menjav ni bilo mogoče naložiti:\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
