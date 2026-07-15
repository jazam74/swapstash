import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/features/catalog/item_detail_page.dart';
import 'package:swapstash/features/catalog/widgets/item_card.dart';

class CatalogGrid extends StatelessWidget {
  final CatalogCollection collection;
  final List<CatalogItem> items;
  final Map<String, UserItem> userItems;
  final String emptyMessage;

  const CatalogGrid({
    super.key,
    required this.collection,
    required this.items,
    required this.userItems,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyMessage, textAlign: TextAlign.center),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final quantity = userItems[item.id]?.quantity ?? 0;

        return ItemCard(
          number: item.number,
          quantity: quantity,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ItemDetailPage(collection: collection, item: item),
              ),
            );
          },
        );
      },
    );
  }
}
