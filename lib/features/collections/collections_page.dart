import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection.dart';
import 'package:swapstash/core/services/collection_service.dart';
import 'package:swapstash/features/collections/add_collection_dialog.dart';
import 'package:swapstash/features/items/items_page.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

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
                  'Zbirk ni bilo mogoče naložiti:\n${snapshot.error}',
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
                style: TextStyle(fontSize: 18),
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

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.collections_bookmark,
                  ),
                  title: Text(
                    collection.name.isEmpty
                        ? 'Neimenovana zbirka'
                        : collection.name,
                  ),
                  subtitle: Text(
                    '${collection.publisher} • '
                    '${collection.totalItems} predmetov',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ItemsPage(
                          collectionId: collection.id,
                          collectionName: collection.name,
                          totalItems: collection.totalItems,
                        ),
                      ),
                    );
                  },
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