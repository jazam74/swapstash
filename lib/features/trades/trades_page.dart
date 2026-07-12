import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_item.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/features/trades/create_trade_page.dart';

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
              Tab(
                icon: Icon(Icons.inbox_outlined),
                text: 'Prejete',
              ),
              Tab(
                icon: Icon(Icons.send_outlined),
                text: 'Poslane',
              ),
              Tab(
                icon: Icon(Icons.check_circle_outline),
                text: 'Zaključene',
              ),
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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CreateTradePage(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Nova menjava'),
        ),
      ),
    );
  }
}

enum _TradeDirection {
  incoming,
  outgoing,
}

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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _TradeErrorView(
            error: snapshot.error,
          );
        }

        final trades = snapshot.data ?? [];

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
            12,
            12,
            12,
            96,
          ),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];

            return _TradeCard(
              trade: trade,
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
          return _TradeErrorView(
            error: incomingSnapshot.error,
          );
        }

        return StreamBuilder<List<Trade>>(
          stream: tradeService.watchOutgoingTrades(),
          builder: (context, outgoingSnapshot) {
            if (outgoingSnapshot.hasError) {
              return _TradeErrorView(
                error: outgoingSnapshot.error,
              );
            }

            final isWaiting =
                incomingSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    outgoingSnapshot.connectionState ==
                        ConnectionState.waiting;

            if (isWaiting &&
                !incomingSnapshot.hasData &&
                !outgoingSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final completedTrades = [
              ...incomingSnapshot.data ?? <Trade>[],
              ...outgoingSnapshot.data ?? <Trade>[],
            ].where((trade) {
              return trade.status == TradeStatus.completed;
            }).toList()
              ..sort(
                (first, second) =>
                    second.createdAt.compareTo(first.createdAt),
              );

            if (completedTrades.isEmpty) {
              return const _EmptyTrades(
                icon: Icons.check_circle_outline,
                text: 'Ni zaključenih menjav.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                96,
              ),
              itemCount: completedTrades.length,
              itemBuilder: (context, index) {
                final trade = completedTrades[index];

                final direction = trade.receiverId == currentUserId
                    ? _TradeDirection.incoming
                    : _TradeDirection.outgoing;

                return _TradeCard(
                  trade: trade,
                  tradeService: tradeService,
                  currentUserId: currentUserId,
                  direction: direction,
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
    if (_isUpdating) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await action();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dejanja ni bilo mogoče izvesti: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trade = widget.trade;
    final isIncoming =
        widget.direction == _TradeDirection.incoming;

    final otherUserId = isIncoming
        ? trade.senderId
        : trade.receiverId;

    final dateText = DateFormat(
      'dd. MM. yyyy, HH:mm',
    ).format(trade.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isIncoming
                      ? Icons.call_received
                      : Icons.call_made,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isIncoming
                        ? 'Prejeta ponudba'
                        : 'Poslana ponudba',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _TradeStatusChip(
                  status: trade.status,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isIncoming
                  ? 'Pošiljatelj: ${_shortUserId(otherUserId)}'
                  : 'Prejemnik: ${_shortUserId(otherUserId)}',
            ),
            const SizedBox(height: 4),
            Text(
              dateText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            _TradeItemsSection(
              title: isIncoming
                  ? 'Prejmeš'
                  : 'Ponudil si',
              icon: Icons.inventory_2_outlined,
              items: trade.offeredItems,
            ),
            const SizedBox(height: 12),
            _TradeItemsSection(
              title: isIncoming
                  ? 'Oddaš'
                  : 'Želiš',
              icon: Icons.search_outlined,
              items: trade.requestedItems,
            ),
            if (_buildActions() case final actions?) ...[
              const SizedBox(height: 14),
              actions,
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildActions() {
    final trade = widget.trade;
    final isIncoming =
        widget.direction == _TradeDirection.incoming;

    if (_isUpdating) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (trade.status == TradeStatus.pending &&
        isIncoming) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _runAction(
                  () => widget.tradeService.rejectTrade(
                    tradeId: trade.id,
                  ),
                  'Menjava je bila zavrnjena.',
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
                  () => widget.tradeService.acceptTrade(
                    tradeId: trade.id,
                  ),
                  'Menjava je bila sprejeta.',
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Sprejmi'),
            ),
          ),
        ],
      );
    }

    if (trade.status == TradeStatus.pending &&
        !isIncoming) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            _runAction(
              () => widget.tradeService.cancelTrade(
                tradeId: trade.id,
              ),
              'Menjava je bila preklicana.',
            );
          },
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Prekliči ponudbo'),
        ),
      );
    }

    if (trade.status == TradeStatus.accepted) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            _runAction(
              () => widget.tradeService.completeTrade(
                tradeId: trade.id,
              ),
              'Menjava je označena kot zaključena.',
            );
          },
          icon: const Icon(Icons.done_all),
          label: const Text('Označi kot zaključeno'),
        ),
      );
    }

    return null;
  }

  String _shortUserId(String userId) {
    if (userId.length <= 10) {
      return userId;
    }

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
            Icon(
              icon,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
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

              return Chip(
                label: Text(
                  '#${item.itemNumber}$quantityText',
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _TradeStatusChip extends StatelessWidget {
  final TradeStatus status;

  const _TradeStatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;

    switch (status) {
      case TradeStatus.pending:
        label = 'Čaka';
        icon = Icons.schedule;

      case TradeStatus.accepted:
        label = 'Sprejeta';
        icon = Icons.check_circle_outline;

      case TradeStatus.rejected:
        label = 'Zavrnjena';
        icon = Icons.cancel_outlined;

      case TradeStatus.completed:
        label = 'Zaključena';
        icon = Icons.done_all;

      case TradeStatus.cancelled:
        label = 'Preklicana';
        icon = Icons.block;
    }

    return Chip(
      avatar: Icon(
        icon,
        size: 18,
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyTrades extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyTrades({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
            ),
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

  const _TradeErrorView({
    required this.error,
  });

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