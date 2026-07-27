import 'package:flutter/material.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/features/catalog/catalog_collections_page.dart';
import 'package:swapstash/features/catalog/catalog_items_page.dart';
import 'package:swapstash/features/collections/my_collections_v2_page.dart';
import 'package:swapstash/features/dashboard/models/dashboard_action.dart';
import 'package:swapstash/features/dashboard/models/dashboard_data.dart';
import 'package:swapstash/features/dashboard/services/dashboard_service.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_actions_card.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_best_collection_card.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_recent_collections_card.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_statistics_grid.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_welcome_card.dart';
import 'package:swapstash/features/favorites/favorites_page.dart';
import 'package:swapstash/features/messages/messages_page.dart';
import 'package:swapstash/features/trades/trades_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';
import 'package:swapstash/shared/widgets/app_empty_state.dart';
import 'package:swapstash/shared/widgets/app_loading_card.dart';
import 'package:swapstash/shared/widgets/app_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _openCollections(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MyCollectionsV2Page()));
  }

  Future<void> _openCollection(
    BuildContext context,
    String collectionId,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final normalizedCollectionId = collectionId.trim();

    if (normalizedCollectionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.dashboardCollectionOpenError)),
      );
      return;
    }

    try {
      final collection = await CatalogService().getCollection(
        normalizedCollectionId,
      );

      if (!context.mounted) {
        return;
      }

      if (collection == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.dashboardCollectionNotFound)),
        );
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CatalogItemsPage(collection: collection),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.dashboardCollectionOpenErrorDetails(error.toString()),
          ),
        ),
      );
    }
  }

  void _openConversation(BuildContext context, DashboardAction action) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MessagesPage(initialConversationId: action.conversationId),
      ),
    );
  }

  void _openTrade(BuildContext context, DashboardAction action) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TradesPage(
          initialTabIndex: action.tradeTabIndex ?? 0,
          highlightedTradeId: action.tradeId,
        ),
      ),
    );
  }

  List<DashboardAction> _attachActionNavigation(
    BuildContext context,
    List<DashboardAction> actions,
  ) {
    return actions
        .map((action) {
          if (action.conversationId?.trim().isNotEmpty ?? false) {
            return action.copyWith(
              onTap: () => _openConversation(context, action),
            );
          }

          if (action.tradeId?.trim().isNotEmpty ?? false) {
            return action.copyWith(onTap: () => _openTrade(context, action));
          }

          return action;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final dashboardService = DashboardService();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.home),
        actions: [
          IconButton(
            tooltip: localizations.dashboardCatalogTooltip,
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CatalogCollectionsPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: localizations.dashboardFavoritesTooltip,
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DashboardData>(
        stream: dashboardService.watchDashboard(localizations: localizations),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppLoadingCard(lines: 5),
            );
          }

          if (snapshot.hasError) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: localizations.dashboardLoadError,
              description: '${snapshot.error}',
            );
          }

          final data = snapshot.data ?? DashboardData.empty();
          final actions = _attachActionNavigation(context, data.actions);

          return LayoutBuilder(
            builder: (context, constraints) {
              const maxContentWidth = 1400.0;

              final horizontalPadding = constraints.maxWidth >= 900
                  ? AppSpacing.lg
                  : AppSpacing.md;
              final availableWidth =
                  constraints.maxWidth - (horizontalPadding * 2);
              final contentWidth = availableWidth > maxContentWidth
                  ? maxContentWidth
                  : (availableWidth > 0
                        ? availableWidth
                        : constraints.maxWidth);
              final isDesktop = contentWidth >= 1000;

              final collectionsSection = AppSection(
                icon: Icons.collections_bookmark_outlined,
                title: localizations.dashboardMyCollections,
                trailing: TextButton(
                  onPressed: () => _openCollections(context),
                  child: Text(localizations.dashboardShowAll),
                ),
                child: DashboardBestCollectionCard(
                  collection: data.bestCollection,
                  onTap: () {
                    final collection = data.bestCollection;

                    if (collection == null) {
                      _openCollections(context);
                      return;
                    }

                    _openCollection(
                      context,
                      collection.catalogCollectionId,
                    );
                  },
                ),
              );

              final overviewSection = AppSection(
                icon: Icons.bar_chart_rounded,
                title: localizations.dashboardOverview,
                child: DashboardStatisticsGrid(
                  collectionCount: data.collectionCount,
                  ownedCount: data.ownedCount,
                  duplicateCount: data.duplicateCount,
                  missingCount: data.missingCount,
                  onCollectionsTap: () => _openCollections(context),
                ),
              );

              return RefreshIndicator(
                onRefresh: () async {
                  await Future<void>.delayed(
                    const Duration(milliseconds: 400),
                  );
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xl,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 5,
                                    child: DashboardWelcomeCard(),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    flex: 7,
                                    child: DashboardActionsCard(
                                      actions: actions,
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              const DashboardWelcomeCard(),
                              const SizedBox(height: AppSpacing.md),
                              DashboardActionsCard(actions: actions),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: collectionsSection),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(child: overviewSection),
                                ],
                              )
                            else ...[
                              collectionsSection,
                              const SizedBox(height: AppSpacing.lg),
                              overviewSection,
                            ],
                            if (data.recentCollections.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              AppSection(
                                icon: Icons.history,
                                title:
                                    localizations.dashboardYourCollections,
                                child: DashboardRecentCollectionsCard(
                                  collections: data.recentCollections,
                                  onCollectionTap: (collection) {
                                    _openCollection(
                                      context,
                                      collection.catalogCollectionId,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
