import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/services/catalog_item_service.dart';
import 'package:swapstash/features/catalog/widgets/item_card.dart';
import 'package:swapstash/features/catalog/item_detail_page.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/core/services/user_item_service.dart';

class CatalogItemsPage extends StatelessWidget {
  final CatalogCollection collection;

  const CatalogItemsPage({
    super.key,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final itemService = CatalogItemService();
    final userItemService = UserItemService();

    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
      ),
      body: StreamBuilder<List<CatalogItem>>(
        stream: itemService.watchItems(collection.id),
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
                  'Predmetov ni bilo mogoče naložiti:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'V tej zbirki še ni predmetov.',
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return StreamBuilder<UserItem?>(
                stream: userItemService.watchItem(
                  collectionId: collection.id,
                  itemId: item.id,
                ),
                builder: (context, userItemSnapshot) {
                  final quantity =
                      userItemSnapshot.data?.quantity ?? 0;

                  return ItemCard(
                    number: item.number,
                    quantity: quantity,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(
                            collection: collection,
                            item: item,
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
    );
  }
}