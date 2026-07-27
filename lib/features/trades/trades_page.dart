import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/safety_report.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/core/services/block_service.dart';
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
import 'package:swapstash/features/trades/widgets/trade_delivery_section.dart';
import 'package:swapstash/features/trades/widgets/trade_rating_section.dart';
import 'package:swapstash/features/trades/widgets/trade_summary_card.dart';
import 'package:swapstash/features/safety/report_dialog.dart';
import 'package:swapstash/features/trades/widgets/trade_items_card.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;
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
          title: Text(localizations.trades),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.view_list_outlined),
                text: localizations.tradeTabAll,
              ),
              Tab(
                icon: const Icon(Icons.inbox_outlined),
                text: localizations.tradeTabReceived,
              ),
              Tab(
                icon: const Icon(Icons.send_outlined),
                text: localizations.tradeTabSent,
              ),
              Tab(
                icon: const Icon(Icons.archive_outlined),
                text: localizations.tradeTabArchive,
              ),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            const maxContentWidth = 1100.0;

            final contentWidth = constraints.maxWidth > maxContentWidth
                ? maxContentWidth
                : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: TabBarView(
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
                      emptyMessage: localizations.tradeNoIncomingTrades,
                      highlightedTradeId: highlightedTradeId,
                    ),
                    _TradesStreamView(
                      stream: tradeService.watchOutgoingTrades(),
                      tradeService: tradeService,
                      currentUserId: tradeService.currentUserId,
                      direction: _TradeDirection.outgoing,
                      emptyMessage: localizations.tradeNoOutgoingTrades,
                      highlightedTradeId: highlightedTradeId,
                    ),
                    _ArchivedTradesView(
                      tradeService: tradeService,
                      currentUserId: tradeService.currentUserId,
                      highlightedTradeId: highlightedTradeId,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'trades_fab',
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CreateTradePage()));
          },
          icon: const Icon(Icons.add),
          label: Text(localizations.tradeNewTrade),
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
    final localizations = AppLocalizations.of(context)!;

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
              return _EmptyTrades(
                icon: Icons.view_list_outlined,
                text: localizations.tradeNoTradesYet,
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

  String _emptyMessage(AppLocalizations localizations) {
    switch (_selectedFilter) {
      case _ArchiveFilter.all:
        return localizations.tradeArchiveEmpty;
      case _ArchiveFilter.completed:
        return localizations.tradeNoCompletedTrades;
      case _ArchiveFilter.rejected:
        return localizations.tradeNoRejectedTrades;
      case _ArchiveFilter.cancelled:
        return localizations.tradeNoCancelledTrades;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
                        label: localizations.tradeTabAll,
                        selected: _selectedFilter == _ArchiveFilter.all,
                        onSelected: () {
                          setState(() {
                            _selectedFilter = _ArchiveFilter.all;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _ArchiveFilterChip(
                        label: localizations.tradeFilterCompleted,
                        selected: _selectedFilter == _ArchiveFilter.completed,
                        onSelected: () {
                          setState(() {
                            _selectedFilter = _ArchiveFilter.completed;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _ArchiveFilterChip(
                        label: localizations.tradeFilterRejected,
                        selected: _selectedFilter == _ArchiveFilter.rejected,
                        onSelected: () {
                          setState(() {
                            _selectedFilter = _ArchiveFilter.rejected;
                          });
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _ArchiveFilterChip(
                        label: localizations.tradeFilterCancelled,
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
                          text: _emptyMessage(localizations),
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
  final FirestoreService _firestoreService = FirestoreService();

  bool _isUpdating = false;
  String? _otherUserProfileId;
  Stream<UserProfile?>? _otherUserProfileStream;

  Stream<UserProfile?> _watchOtherUserProfile(String userId) {
    if (_otherUserProfileId != userId || _otherUserProfileStream == null) {
      _otherUserProfileId = userId;
      _otherUserProfileStream = _firestoreService.watchUserProfile(userId);
    }

    return _otherUserProfileStream!;
  }

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
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.tradeActionExecutionError(error.toString()),
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

  Future<void> _openCounterOffer() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CounterOfferPage(trade: widget.trade)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                    localizations.tradeFromTask,
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
              localizations: localizations,
            ),
            directionLabel: trade.status == TradeStatus.countered
                ? localizations.tradeDirectionCounterOffer
                : isIncoming
                ? localizations.tradeDirectionReceivedOffer
                : localizations.tradeDirectionSentOffer,
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
                    localizations: localizations,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                StreamBuilder<UserProfile?>(
                  stream: _watchOtherUserProfile(otherUserId),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data?.displayName.trim() ?? '';

                    return TradeSummaryCard(
                      trade: trade,
                      currentUserId: widget.currentUserId,
                      otherUserLabel: displayName.isEmpty
                          ? localizations.unknownUser
                          : displayName,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TradeItemsCard(
                  title: localizations.tradeYouGive,
                  icon: Icons.upload_rounded,
                  accentColor: Theme.of(context).colorScheme.primary,
                  items: offeredItems,
                ),
                const SizedBox(height: AppSpacing.sm),
                TradeItemsCard(
                  title: localizations.tradeYouReceive,
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
                if (trade.status == TradeStatus.accepted ||
                    trade.status == TradeStatus.completed) ...[
                  const SizedBox(height: AppSpacing.md),
                  TradeDeliverySection(
                    trade: trade,
                    currentUserId: widget.currentUserId,
                  ),
                ],
                StreamBuilder<BlockRelationship>(
                  stream: BlockService().watchRelationship(
                    otherUserId: otherUserId,
                  ),
                  initialData: const BlockRelationship.none(),
                  builder: (context, relationshipSnapshot) {
                    final relationship =
                        relationshipSnapshot.data ??
                        const BlockRelationship.none();
                    final actions = _buildActions(
                      localizations,
                      interactionBlocked: relationship.isBlocked,
                    );

                    if (actions == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: actions,
                    );
                  },
                ),
                if (trade.status == TradeStatus.completed) ...[
                  const SizedBox(height: AppSpacing.md),
                  TradeRatingSection(trade: trade),
                ],
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      showSafetyReportDialog(
                        context: context,
                        reportedUserId: otherUserId,
                        targetType: SafetyReportType.trade,
                        targetId: trade.id,
                      );
                    },
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(localizations.safetyReportTrade),
                  ),
                ),
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
      AppLocalizations.of(context)!.tradeHandoverConfirmedSuccess,
    );
  }

  Future<void> _confirmReceipt() async {
    final confirmed = await TradeConfirmDialog.confirmReceipt(context);

    if (!confirmed || !mounted) {
      return;
    }

    await _runAction(
      () => widget.tradeService.markReceived(tradeId: widget.trade.id),
      AppLocalizations.of(context)!.tradeReceiptConfirmedSuccess,
    );
  }

  Widget? _buildActions(
    AppLocalizations localizations, {
    required bool interactionBlocked,
  }) {
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
                        localizations.tradeOfferRejectedSuccess,
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: Text(localizations.tradeReject),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _runAction(
                        () =>
                            widget.tradeService.acceptTrade(tradeId: trade.id),
                        localizations.tradeOfferAcceptedSuccess,
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: Text(localizations.tradeAccept),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: interactionBlocked ? null : _openCounterOffer,
              icon: const Icon(Icons.swap_horiz),
              label: Text(localizations.tradeSendCounterOffer),
            ),
          ],
        );
      }

      if (trade.lastProposedBy == widget.currentUserId) {
        return OutlinedButton.icon(
          onPressed: () {
            _runAction(
              () => widget.tradeService.cancelTrade(tradeId: trade.id),
              localizations.tradeOfferCancelledSuccess,
            );
          },
          icon: const Icon(Icons.cancel_outlined),
          label: Text(localizations.tradeCancelOffer),
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
              shipped
                  ? localizations.tradeHandoverConfirmed
                  : localizations.tradeConfirmHandoverTitle,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: received ? null : _confirmReceipt,
            icon: Icon(
              received ? Icons.check_circle : Icons.inventory_outlined,
            ),
            label: Text(
              received
                  ? localizations.tradeReceiptConfirmed
                  : localizations.tradeConfirmReceiptTitle,
            ),
          ),
        ],
      );
    }

    return null;
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
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          localizations.tradeLoadErrorDetails(error.toString()),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
