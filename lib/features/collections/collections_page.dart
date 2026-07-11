import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: collectionService.watchCollections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Napaka: ${snapshot.error}',
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Še nimaš nobene zbirke.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final name = data['name'] as String? ?? 'Neimenovana zbirka';
              final publisher = data['publisher'] as String? ?? '';
              final totalItems = data['totalItems'] as int? ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(Icons.collections_bookmark),
                  title: Text(name),
                  subtitle: Text(
                    '$publisher • $totalItems predmetov',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ItemsPage(
                          collectionName: name,
                          totalItems: totalItems,
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
          await showDialog(
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