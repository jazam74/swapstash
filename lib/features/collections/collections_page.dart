import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection.dart';
import 'package:swapstash/core/services/collection_service.dart';
import 'package:swapstash/features/collections/add_collection_dialog.dart';
import 'package:swapstash/features/collections/edit_collection_dialog.dart';
import 'package:swapstash/features/items/items_page.dart';

enum CollectionAction {
  edit,
  delete,
}

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  Future<void> _editCollection(
    BuildContext context,
    Collection collection,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => EditCollectionDialog(
        collection: collection,
      ),
    );
  }

  Future<void> _deleteCollection(
    BuildContext context,
    Collection collection,
    CollectionService collectionService,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Izbriši zbirko?'),
          content: Text(
            'Ali res želiš izbrisati zbirko '
            '"${collection.name}"?\n\n'
            'Izbrisani bodo tudi vsi shranjeni predmeti '
            'v tej zbirki. Tega dejanja ni mogoče razveljaviti.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Prekliči'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(dialogContext).colorScheme.error,
                foregroundColor:
                    Theme.of(dialogContext).colorScheme.onError,
              ),
              child: const Text('Izbriši'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await collectionService.deleteCollection(
        collectionId: collection.id,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Zbirka "${collection.name}" je bila izbrisana.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Zbirke ni bilo mogoče izbrisati: $error',
          ),
        ),
      );
    }
  }

  void _openCollection(
    BuildContext context,
    Collection collection,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemsPage(
          collectionId: collection.id,
          collectionName: collection.name,
          totalItems: collection.totalItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectionService = CollectionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje zbirke'),
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
                  'Zbirk ni bilo mogoče naložiti:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final collections = snapshot.data ?? [];

          if (collections.isEmpty) {
            return const Center(
              child: Text(
                'Še nimaš nobene zbirke.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 96,
            ),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];

              final displayName = collection.name.isEmpty
                  ? 'Neimenovana zbirka'
                  : collection.name;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                    left: 16,
                    right: 4,
                    top: 4,
                    bottom: 4,
                  ),
                  leading: const Icon(
                    Icons.collections_bookmark,
                  ),
                  title: Text(displayName),
                  subtitle: Text(
                    '${collection.publisher} • '
                    '${collection.totalItems} predmetov',
                  ),
                  onTap: () {
                    _openCollection(
                      context,
                      collection,
                    );
                  },
                  trailing: PopupMenuButton<CollectionAction>(
                    tooltip: 'Možnosti zbirke',
                    onSelected: (action) async {
                      switch (action) {
                        case CollectionAction.edit:
                          await _editCollection(
                            context,
                            collection,
                          );
                          break;

                        case CollectionAction.delete:
                          await _deleteCollection(
                            context,
                            collection,
                            collectionService,
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: CollectionAction.edit,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Uredi'),
                          ),
                        ),
                        PopupMenuItem(
                          value: CollectionAction.delete,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.delete_outline),
                            title: Text('Izbriši'),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog<bool>(
            context: context,
            builder: (_) => const AddCollectionDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Dodaj zbirko'),
      ),
    );
  }
}