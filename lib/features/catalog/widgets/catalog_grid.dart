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
  final Map<String, int> quantityOverrides;
  final Set<String> savingItemIds;
  final bool quickEntryEnabled;
  final String emptyMessage;
  final void Function(CatalogItem item, int change)? onQuantityChanged;

  const CatalogGrid({
    super.key,
    required this.collection,
    required this.items,
    required this.userItems,
    this.quantityOverrides = const {},
    this.savingItemIds = const {},
    this.quickEntryEnabled = false,
    required this.emptyMessage,
    this.onQuantityChanged,
  });

  String _resolvedImageUrl(CatalogItem item) {
    final existingImageUrl = item.imageUrl.trim();

    if (existingImageUrl.isNotEmpty) {
      return existingImageUrl;
    }

    final basePath = collection.itemImageBasePath
        .trim()
        .replaceAll(RegExp(r'^/+|/+$'), '');

    if (basePath.isEmpty) {
      return '';
    }

    final imageNumber = item.number.trim().padLeft(3, '0');

    return '/$basePath/$imageNumber.webp';
  }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final int crossAxisCount;
        if (width >= 1320) {
          crossAxisCount = 6;
        } else if (width >= 1080) {
          crossAxisCount = 5;
        } else if (width >= 820) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 3;
        }

        final isDesktop = width >= 820;
        final childAspectRatio = quickEntryEnabled
            ? (isDesktop ? 0.62 : 0.50)
            : (isDesktop ? 0.78 : 0.62);

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 16 : 12,
            12,
            isDesktop ? 16 : 12,
            24,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isDesktop ? 14 : 10,
            mainAxisSpacing: isDesktop ? 14 : 10,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final quantity =
                quantityOverrides[item.id] ??
                userItems[item.id]?.quantity ??
                0;
            final isSaving = savingItemIds.contains(item.id);

            return ItemCard(
              number: item.number,
              name: item.name,
              imageUrl: _resolvedImageUrl(item),
              rarity: item.rarity,
              quantity: quantity,
              quickEntryEnabled: quickEntryEnabled,
              isSaving: isSaving,
              onDecrease: quantity == 0 || onQuantityChanged == null
                  ? null
                  : () => onQuantityChanged!(item, -1),
              onIncrease: onQuantityChanged == null
                  ? null
                  : () => onQuantityChanged!(item, 1),
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
      },
    );
  }
}
