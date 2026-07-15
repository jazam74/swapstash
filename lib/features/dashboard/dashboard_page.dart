import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection.dart';
import 'package:swapstash/core/services/collection_service.dart';
import 'package:swapstash/features/catalog/catalog_collections_page.dart';
import 'package:swapstash/features/collections/my_collections_v2_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collectionService = CollectionService();

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
            icon: const Icon(Icons.folder_copy),
            tooltip: 'Moje zbirke V2',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MyCollectionsV2Page(),
                ),
              );
            },
          ),
       ],
     ),
      body: StreamBuilder<List<Collection>>(
        stream: collectionService.watchCollections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Dashboarda ni bilo mogoče naložiti:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final collections = snapshot.data ?? [];

          final collectionCount = collections.length;

          final ownedCount = collections.fold<int>(
            0,
            (sum, collection) => sum + collection.ownedCount,
          );

          final duplicateCount = collections.fold<int>(
            0,
            (sum, collection) => sum + collection.duplicateCount,
          );

          final missingCount = collections.fold<int>(
            0,
            (sum, collection) => sum + collection.missingCount,
          );

          final bestCollection = _findBestCollection(
            collections,
          );

          return RefreshIndicator(
            onRefresh: () async {
              await Future<void>.delayed(
                const Duration(milliseconds: 400),
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '👋 Dobrodošel!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pregled tvojih zbirk in napredka.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    _StatisticCard(
                      icon: Icons.collections_bookmark,
                      label: 'Zbirke',
                      value: collectionCount,
                    ),
                    _StatisticCard(
                      icon: Icons.check_circle_outline,
                      label: 'Zbranih',
                      value: ownedCount,
                    ),
                    _StatisticCard(
                      icon: Icons.swap_horiz,
                      label: 'Viški',
                      value: duplicateCount,
                    ),
                    _StatisticCard(
                      icon: Icons.remove_circle_outline,
                      label: 'Manjka',
                      value: missingCount,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Najbolj napredna zbirka',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (bestCollection == null)
                  const _EmptyDashboardCard()
                else
                  _BestCollectionCard(
                    collection: bestCollection,
                  ),
                if (collections.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Tvoje zbirke',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...collections.take(3).map(
                        (collection) => _RecentCollectionCard(
                          collection: collection,
                        ),
                      ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Collection? _findBestCollection(
    List<Collection> collections,
  ) {
    if (collections.isEmpty) {
      return null;
    }

    return collections.reduce((first, second) {
      if (second.completion > first.completion) {
        return second;
      }

      return first;
    });
  }
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatisticCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BestCollectionCard extends StatelessWidget {
  final Collection collection;

  const _BestCollectionCard({
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    collection.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '${collection.completionPercent} %',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(collection.publisher),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: collection.completion,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              '${collection.ownedCount} od '
              '${collection.totalItems} zbranih predmetov',
            ),
            if (collection.duplicateCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${collection.duplicateCount} viškov',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentCollectionCard extends StatelessWidget {
  final Collection collection;

  const _RecentCollectionCard({
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.collections_bookmark_outlined,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    collection.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${collection.completionPercent} %',
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: collection.completion,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 6),
            Text(
              '${collection.ownedCount} / '
              '${collection.totalItems}',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDashboardCard extends StatelessWidget {
  const _EmptyDashboardCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Še nimaš nobene zbirke.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Odpri zavihek Zbirke in dodaj svojo prvo zbirko.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}