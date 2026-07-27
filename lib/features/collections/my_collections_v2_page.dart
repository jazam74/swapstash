import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/collection_statistics.dart';
import 'package:swapstash/core/models/user_collection.dart';
import 'package:swapstash/core/localization/catalog_category_localizer.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/core/services/collection_statistics_service.dart';
import 'package:swapstash/core/services/user_collection_service.dart';
import 'package:swapstash/features/catalog/catalog_collections_page.dart';
import 'package:swapstash/features/catalog/catalog_items_page.dart';
import 'package:swapstash/features/collections/models/collection_card_data.dart';
import 'package:swapstash/features/collections/widgets/collection_card.dart';
import 'package:swapstash/features/collections/widgets/collection_popup_menu.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class MyCollectionsV2Page extends StatefulWidget {
  const MyCollectionsV2Page({super.key});

  @override
  State<MyCollectionsV2Page> createState() => _MyCollectionsV2PageState();
}

class _MyCollectionsV2PageState extends State<MyCollectionsV2Page> {
  final UserCollectionService _userCollectionService = UserCollectionService();
  final CatalogService _catalogService = CatalogService();
  final CollectionStatisticsService _collectionStatisticsService =
      CollectionStatisticsService();

  final Map<String, Future<CatalogCollection?>> _catalogCollectionFutures = {};

  Future<CatalogCollection?> _loadCatalogCollection(
    String catalogCollectionId,
  ) {
    return _catalogCollectionFutures.putIfAbsent(
      catalogCollectionId,
      () => _catalogService.getCollection(catalogCollectionId),
    );
  }

  Future<void> _openCatalog() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CatalogCollectionsPage()));
  }

  Future<void> _removeCollection(CatalogCollection collection) async {
    final localizations = AppLocalizations.of(context)!;

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.myCollectionsRemoveTitle),
          content: Text(
            localizations.myCollectionsRemoveQuestion(collection.name),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(localizations.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(localizations.myCollectionsRemoveButton),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    try {
      await _userCollectionService.removeCollection(collection.id);
      _catalogCollectionFutures.remove(collection.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.myCollectionsRemoved(collection.name)),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.myCollectionsRemoveError(error.toString()),
          ),
        ),
      );
    }
  }

  Widget _buildCollectionEntry({
    required UserCollection userCollection,
    required AppLocalizations localizations,
  }) {
    return FutureBuilder<CatalogCollection?>(
      future: _loadCatalogCollection(userCollection.catalogCollectionId),
      builder: (context, catalogSnapshot) {
        if (catalogSnapshot.connectionState == ConnectionState.waiting &&
            !catalogSnapshot.hasData) {
          return const Card(
            margin: EdgeInsets.zero,
            child: SizedBox(
              height: 110,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (catalogSnapshot.hasError) {
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(localizations.myCollectionsCatalogLoadError),
              subtitle: Text('${catalogSnapshot.error}'),
            ),
          );
        }

        final collection = catalogSnapshot.data;

        if (collection == null) {
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text(localizations.myCollectionsCatalogMissing),
              subtitle: Text(userCollection.catalogCollectionId),
            ),
          );
        }

        return StreamBuilder<CollectionStatistics>(
          stream: _collectionStatisticsService.watchStatistics(
            collection: collection,
          ),
          builder: (context, statisticsSnapshot) {
            if (statisticsSnapshot.connectionState ==
                    ConnectionState.waiting &&
                !statisticsSnapshot.hasData) {
              return const Card(
                margin: EdgeInsets.zero,
                child: SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (statisticsSnapshot.hasError) {
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(
                    localizations.myCollectionsStatisticsLoadError,
                  ),
                  subtitle: Text('${statisticsSnapshot.error}'),
                ),
              );
            }

            final statistics = statisticsSnapshot.data;

            if (statistics == null) {
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.warning_amber_outlined),
                  title: Text(
                    localizations.myCollectionsStatisticsUnavailable,
                  ),
                ),
              );
            }

            return CollectionCard(
              data: CollectionCardData(
                title: statistics.name,
                subtitle:
                    '${statistics.publisher} • '
                    '${localizedCatalogCategory(localizations, statistics.category)} • '
                    '${statistics.year}',
                ownedCount: statistics.ownedCount,
                totalCount: statistics.totalItems,
                duplicateCount: statistics.duplicateCount,
                missingCount: statistics.missingCount,
              ),
              showMenu: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CatalogItemsPage(collection: collection),
                  ),
                );
              },
              onMenuSelected: (action) {
                if (action == CollectionMenuAction.remove) {
                  _removeCollection(collection);
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myCollectionsTitle),
        actions: [
          IconButton(
            tooltip: localizations.myCollectionsAddFromCatalog,
            onPressed: _openCatalog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<UserCollection>>(
        stream: _userCollectionService.watchCollections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  localizations.myCollectionsLoadError(
                    snapshot.error.toString(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final userCollections = snapshot.data ?? [];

          if (userCollections.isEmpty) {
            return _EmptyCollectionsView(onAddCollection: _openCatalog);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              const maxContentWidth = 1280.0;
              const horizontalPadding = 16.0;
              const cardGap = 16.0;

              final availableWidth =
                  constraints.maxWidth - (horizontalPadding * 2);
              final contentWidth = math.min(
                availableWidth > 0 ? availableWidth : 0.0,
                maxContentWidth,
              );
              final useTwoColumns = contentWidth >= 960;
              final cardWidth = useTwoColumns
                  ? (contentWidth - cardGap) / 2
                  : contentWidth;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  96,
                ),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Wrap(
                      spacing: cardGap,
                      runSpacing: cardGap,
                      children: [
                        for (final userCollection in userCollections)
                          SizedBox(
                            width: cardWidth,
                            child: _buildCollectionEntry(
                              userCollection: userCollection,
                              localizations: localizations,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'my_collections_v2_fab',
        onPressed: _openCatalog,
        icon: const Icon(Icons.add),
        label: Text(localizations.myCollectionsAddButton),
      ),
    );
  }
}

class _EmptyCollectionsView extends StatelessWidget {
  final VoidCallback onAddCollection;

  const _EmptyCollectionsView({required this.onAddCollection});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.collections_bookmark_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              localizations.myCollectionsEmptyTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.myCollectionsEmptyDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddCollection,
              icon: const Icon(Icons.add),
              label: Text(localizations.myCollectionsOpenCatalog),
            ),
          ],
        ),
      ),
    );
  }
}
