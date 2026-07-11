import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/services/collection_service.dart';
import 'package:swapstash/features/collections/add_collection_dialog.dart';

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

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(Icons.collections_bookmark),
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(
                    '${data['publisher']} • ${data['totalItems']} predmetov',
                  ),
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