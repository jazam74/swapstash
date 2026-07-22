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
import 'package:swapstash/features/trades/widgets/trade_rating_section.dart';
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
        : initialTabIndex > 3
        ? 3
        : initialTabIndex;

    return DefaultTabController(
      length: 4,
      initialIndex: selectedTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menjave'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.view_list_outlined), text: 'Vse'),
              Tab(icon: Icon(Icons.inbox_outlined), text: 'Prejete'),
              Tab(icon: Icon(Icons.send_outlined), text: 'Poslane'),
              Tab(icon: Icon(Icons.archive_outlined), text: 'Arhiv'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AllTradesView(
              tradeService: tradeService,
              currentUserId: tradeService.currentUserId,
              highlightedTradeId: highlightedTradeId,
            ),
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
            _ArchivedTradesView(
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

class _AllTradesView extends StatelessWidget {
  final TradeService tradeService;
  final String currentUserId;
  final String? highlightedTradeId;

  const _AllTradesView({
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

            final isWaiting =
                (incomingSnapshot.connectionState == ConnectionState.waiting &&
                    !incomingSnapshot.hasData) ||
                (outgoingSnapshot.connectionState == ConnectionState.waiting &&
                    !outgoingSnapshot.hasData);

            if (isWaiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tradesById = <String, Trade>{};

            for (final trade in [
              ...incomingSnapshot.data ?? <Trade>[],
              ...outgoingSnapshot.data ?? <Trade>[],
            ]) {
              tradesById[trade.id] = trade;
            }

            final trades = tradesById.values.toList()
              ..sort((first, second) {
                final firstDate = first.updatedAt ?? first.createdAt;
                final secondDate = second.updatedAt ?? second.createdAt;

                return secondDate.compareTo(firstDate);
              });

            _moveTradeToTop(
              trades: trades,
              highlightedTradeId: highlightedTradeId,
            );

            if (trades.isEmpty) {
              return const _EmptyTrades(
                icon: Icons.view_list_outlined,
                text: 'Še nimaš nobene menjave.',
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

        final trades = (snapshot.data ?? []).where(_isActiveTrade).toList();

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

enum _ArchiveFilter { all, completed, rejected, cancelled }

class _ArchivedTradesView extends StatefulWidget {
  final TradeService tradeService;
  final String currentUserId;
  final String? highlightedTradeId;

  const _ArchivedTradesView({
    required this.tradeService,
    required this.currentUserId,
    this.highlightedTradeId,
  });

  @override
  State<_ArchivedTradesView> createState() => _ArchivedTradesViewState();
}

class _ArchivedTradesViewState extends State<_ArchivedTradesView> {
  _ArchiveFilter _selectedFilter = _ArchiveFilter.all;

  bool _matchesSelectedFilter(Trade trade) {
    switch (_selectedFilter) {
      case _ArchiveFilter.all:
        return true;
      case _ArchiveFilter.completed:
        return trade.status == TradeStatus.completed;
      case _ArchiveFilter.rejected:
        return trade.status == TradeStatus.rejected;
      case _ArchiveFilter.cancelled:
        return trade.status == TradeStatus.cancelled;
    }
  }

  String get _emptyMessage {
    switch (_selectedFilter) {
      case _ArchiveFilter.all:
        return 'Arhiv je prazen.';
      case _ArchiveFilter.completed:
        return 'Ni zaključenih menjav.';
      case _ArchiveFilter.rejected:
        return 'Ni zavrnjenih menjav.';
      case _ArchiveFilter.cancelled:
        return 'Ni preklicanih menjav.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trade>>(
      stream: widget.tradeService.watchIncomingTrades(),
      builder: (context, incomingSnapshot) {
        if (incomingSnapshot.hasError) {
          return _TradeErrorView(error: incomingSnapshot.error);
        }

        return StreamBuilder<List<Trade>>(
          stream: widget.tradeService.watchOutgoingTrades(),
          builder: (context, outgoingSnapshot) {
            if (outgoingSnapshot.hasError) {
              return _TradeErrorView(error: outgoingSnapshot.error);
            }

            final isWaiting =
                (incomingSnapshot.connectionState == ConnectionState.waiting &&
                    !incomingSnapshot.hasData) ||
                (outgoingSnapshot.connectionState == ConnectionState.waiting &&
                    !outgoingSnapshot.hasData);

            if (isWaiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final archivedById = <String, Trade>{};

            for (final trade in [
              ...incomingSnapshot.data ?? <Trade>[],
              ...outgoingSnapshot.data ?? <Trade>[],
            ]) {
              if (_isArchivedTrade(trade)) {
                archivedById[trade.id] = trade;
              }
            }

            final trades =
                archivedById.values.where(_matchesSelectedFilter).toList()
                  ..sort((first, second) {
                    final firstDate = first.updatedAt ?? first.createdAt;
                    final secondDate = second.updatedAt ?? second.createdAt;

                    return secondDate.compareTo(firstDate);
                  });

            _moveTradeToTop(
              trades: trades,
              highlightedTradeId: widget.highlightedTradeId,
            );

            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    4,
                  ),
                  child: Row(
                    children: [
                      _ArchiveFilterChip(
                        label: 'Vse',
                        selected: _selectedFilter == _ArchiveFilter.all,
                        onSelected: () {
                          setState(() {
                            _selectedFilter = _ArchiveFilter.all;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _ArchiveFilterChip(
                        label: 'Zaključene',
                        selected: _selectedFilter == _ArchiveFilter.completed,
                        onSelected: () {
                          setState(() {
                            _selectedFilter = _ArchiveFilter.completed;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _ArchiveFilterChip(
                        label: 'Zavrnjene',
                        selected: _selectedFilter == _ArchiveFilter.rejected,
                        onSelected: () {
                          setState(() {
                            _selectedFilter = _ArchiveFilter.rejected;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _ArchiveFilterChip(
                        label: 'Preklicane',
                        selected: _selectedFilter == _ArchiveFilter.cancelled,
                        onSelected: () {
                          setState(() {
                            _selectedFilter = _ArchiveFilter.cancelled;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: trades.isEmpty
                      ? _EmptyTrades(
                          icon: Icons.archive_outlined,
                          text: _emptyMessage,
                        )
                      : ListView.builder(
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
                              tradeService: widget.tradeService,
                              currentUserId: widget.currentUserId,
                              direction:
                                  trade.receiverId == widget.currentUserId
                                  ? _TradeDirection.incoming
                                  : _TradeDirection.outgoing,
                              isHighlighted:
                                  trade.id == widget.highlightedTradeId,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ArchiveFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _ArchiveFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onSelected(),
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
                if (trade.status == TradeStatus.completed) ...[
                  const SizedBox(height: AppSpacing.md),
                  TradeRatingSection(trade: trade),
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

bool _isActiveTrade(Trade trade) {
  return trade.status == TradeStatus.pending ||
      trade.status == TradeStatus.countered ||
      trade.status == TradeStatus.accepted;
}

bool _isArchivedTrade(Trade trade) {
  return trade.status == TradeStatus.completed ||
      trade.status == TradeStatus.rejected ||
      trade.status == TradeStatus.cancelled;
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
