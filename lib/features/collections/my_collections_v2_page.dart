import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/user_collection.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/core/services/user_collection_service.dart';
import 'package:swapstash/features/catalog/catalog_collections_page.dart';
import 'package:swapstash/features/catalog/catalog_items_page.dart';

class MyCollectionsV2Page extends StatefulWidget {
  const MyCollectionsV2Page({super.key});

  @override
  State<MyCollectionsV2Page> createState() =>
      _MyCollectionsV2PageState();
}

class _MyCollectionsV2PageState
    extends State<MyCollectionsV2Page> {
  final UserCollectionService _userCollectionService =
      UserCollectionService();

  final CatalogService _catalogService = CatalogService();

  final Map<String, Future<CatalogCollection?>>
      _catalogCollectionFutures = {};

  Future<CatalogCollection?> _loadCatalogCollection(
    String catalogCollectionId,
  ) {
    return _catalogCollectionFutures.putIfAbsent(
      catalogCollectionId,
      () => _catalogService.getCollection(
        catalogCollectionId,
      ),
    );
  }

  Future<void> _openCatalog() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CatalogCollectionsPage(),
      ),
    );
  }

  Future<void> _removeCollection(
    CatalogCollection collection,
  ) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Odstrani zbirko'),
          content: Text(
            'Ali želiš zbirko "${collection.name}" '
            'odstraniti iz svojih zbirk?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Prekliči'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Odstrani'),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    try {
      await _userCollectionService.removeCollection(
        collection.id,
      );

      _catalogCollectionFutures.remove(collection.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${collection.name} je bila odstranjena.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Zbirke ni bilo mogoče odstraniti: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje zbirke'),
        actions: [
          IconButton(
            tooltip: 'Dodaj zbirko iz kataloga',
            onPressed: _openCatalog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<UserCollection>>(
        stream: _userCollectionService.watchCollections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
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
                  'Tvojih zbirk ni bilo mogoče naložiti:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final userCollections = snapshot.data ?? [];

          if (userCollections.isEmpty) {
            return _EmptyCollectionsView(
              onAddCollection: _openCatalog,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              96,
            ),
            itemCount: userCollections.length,
            itemBuilder: (context, index) {
              final userCollection =
                  userCollections[index];

              return FutureBuilder<CatalogCollection?>(
                future: _loadCatalogCollection(
                  userCollection.catalogCollectionId,
                ),
                builder: (context, catalogSnapshot) {
                  if (catalogSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !catalogSnapshot.hasData) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        height: 110,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  if (catalogSnapshot.hasError) {
                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.error_outline,
                        ),
                        title: const Text(
                          'Zbirke ni bilo mogoče naložiti.',
                        ),
                        subtitle: Text(
                          '${catalogSnapshot.error}',
                        ),
                      ),
                    );
                  }

                  final collection =
                      catalogSnapshot.data;

                  if (collection == null) {
                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.warning_amber_outlined,
                        ),
                        title: const Text(
                          'Kataloška zbirka ne obstaja.',
                        ),
                        subtitle: Text(
                          userCollection
                              .catalogCollectionId,
                        ),
                      ),
                    );
                  }

                  return _UserCollectionCard(
                    collection: collection,
                    onRemove: () {
                      _removeCollection(collection);
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CatalogItemsPage(
                            collection: collection,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCatalog,
        icon: const Icon(Icons.add),
        label: const Text('Dodaj zbirko'),
      ),
    );
  }
}

class _UserCollectionCard extends StatelessWidget {
  final CatalogCollection collection;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _UserCollectionCard({
    required this.collection,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final publisherInitial =
        collection.publisher.trim().isEmpty
            ? '?'
            : collection.publisher
                .trim()
                .characters
                .first
                .toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                child: Text(
                  publisherInitial,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${collection.publisher} • '
                      '${collection.category}',
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${collection.year} • '
                      '${collection.totalItems} predmetov',
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Možnosti',
                onSelected: (value) {
                  if (value == 'remove') {
                    onRemove();
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 8),
                          Text('Odstrani'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCollectionsView extends StatelessWidget {
  final VoidCallback onAddCollection;

  const _EmptyCollectionsView({
    required this.onAddCollection,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.collections_bookmark_outlined,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Še nimaš dodanih zbirk.',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Izberi zbirko iz centralnega kataloga.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddCollection,
              icon: const Icon(Icons.add),
              label: const Text('Odpri katalog'),
            ),
          ],
        ),
      ),
    );
  }
}