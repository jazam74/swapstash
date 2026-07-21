import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/features/catalog/catalog_collections_page.dart';
import 'package:swapstash/features/collections/my_collections_v2_page.dart';
import 'package:swapstash/features/dashboard/models/dashboard_data.dart';
import 'package:swapstash/features/dashboard/services/dashboard_service.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_actions_card.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_best_collection_card.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_recent_collections_card.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_statistics_grid.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_welcome_card.dart';
import 'package:swapstash/features/favorites/favorites_page.dart';
import 'package:swapstash/shared/widgets/app_empty_state.dart';
import 'package:swapstash/shared/widgets/app_loading_card.dart';
import 'package:swapstash/shared/widgets/app_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
          IconButton(
            tooltip: 'Moje zbirke V2',
            icon: const Icon(Icons.folder_copy),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyCollectionsV2Page()),
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

          final data = snapshot.data ?? DashboardData.fromCollections([]);

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
                DashboardActionsCard(actions: data.actions),
                const SizedBox(height: AppSpacing.lg),
                AppSection(
                  icon: Icons.collections_bookmark_outlined,
                  title: 'Moje zbirke',
                  child: DashboardBestCollectionCard(
                    collection: data.bestCollection,
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
                  ),
                ),
                if (data.recentCollections.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppSection(
                    icon: Icons.history,
                    title: 'Tvoje zbirke',
                    child: DashboardRecentCollectionsCard(
                      collections: data.recentCollections,
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
