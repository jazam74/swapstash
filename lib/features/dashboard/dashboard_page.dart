import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/features/catalog/catalog_collections_page.dart';
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
    final dashboardService = DashboardService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Domov'),
        actions: [
          IconButton(
            tooltip: 'Katalog zbirk',
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
            tooltip: 'Moji favoriti',
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
        stream: dashboardService.watchDashboard(),
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
              title: 'Dashboarda ni bilo mogoče naložiti',
              description: '${snapshot.error}',
            );
          }

          final data = snapshot.data ?? DashboardData.empty();
          final actions = _attachActionNavigation(context, data.actions);

          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const DashboardWelcomeCard(),
                const SizedBox(height: AppSpacing.md),
                DashboardActionsCard(actions: actions),
                const SizedBox(height: AppSpacing.lg),
                AppSection(
                  icon: Icons.collections_bookmark_outlined,
                  title: 'Moje zbirke',
                  trailing: TextButton(
                    onPressed: () => _openCollections(context),
                    child: const Text('Prikaži vse'),
                  ),
                  child: DashboardBestCollectionCard(
                    collection: data.bestCollection,
                    onTap: () => _openCollections(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSection(
                  icon: Icons.bar_chart_rounded,
                  title: 'Pregled',
                  child: DashboardStatisticsGrid(
                    collectionCount: data.collectionCount,
                    ownedCount: data.ownedCount,
                    duplicateCount: data.duplicateCount,
                    missingCount: data.missingCount,
                    onCollectionsTap: () => _openCollections(context),
                  ),
                ),
                if (data.recentCollections.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppSection(
                    icon: Icons.history,
                    title: 'Tvoje zbirke',
                    child: DashboardRecentCollectionsCard(
                      collections: data.recentCollections,
                      onCollectionTap: (_) => _openCollections(context),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}
