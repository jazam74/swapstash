import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/core/services/catalog_item_service.dart';
import 'package:swapstash/core/services/user_item_service.dart';
import 'package:swapstash/features/catalog/item_detail_page.dart';
import 'package:swapstash/features/catalog/widgets/catalog_progress.dart';
import 'package:swapstash/features/catalog/widgets/catalog_search_bar.dart';
import 'package:swapstash/features/catalog/widgets/item_card.dart';

enum InventoryFilter { all, owned, missing, duplicates }

class CatalogItemsPage extends StatefulWidget {
  final CatalogCollection collection;

  const CatalogItemsPage({super.key, required this.collection});

  @override
  State<CatalogItemsPage> createState() => _CatalogItemsPageState();
}

class _CatalogItemsPageState extends State<CatalogItemsPage> {
  final CatalogItemService _catalogItemService = CatalogItemService();

  final UserItemService _userItemService = UserItemService();

  InventoryFilter _selectedFilter = InventoryFilter.all;
  String _searchQuery = '';

  List<CatalogItem> _filterItems({
    required List<CatalogItem> catalogItems,
    required Map<String, UserItem> userItems,
  }) {
    final query = _searchQuery.trim().toLowerCase();

    return catalogItems.where((item) {
      if (query.isNotEmpty) {
        final matches =
            item.number.toLowerCase().contains(query) ||
            item.name.toLowerCase().contains(query);

        if (!matches) {
          return false;
        }
      }

      final quantity = userItems[item.id]?.quantity ?? 0;

      switch (_selectedFilter) {
        case InventoryFilter.all:
          return true;

        case InventoryFilter.owned:
          return quantity > 0;

        case InventoryFilter.missing:
          return quantity == 0;

        case InventoryFilter.duplicates:
          return quantity > 1;
      }
    }).toList();
  }

  String _emptyMessage() {
    if (_searchQuery.trim().isNotEmpty) {
      return 'Za iskani izraz ni rezultatov.';
    }

    switch (_selectedFilter) {
      case InventoryFilter.all:
        return 'V tej zbirki še ni predmetov.';

      case InventoryFilter.owned:
        return 'Nimaš še nobenega predmeta.';

      case InventoryFilter.missing:
        return 'Zbirka je popolna. Ni manjkajočih predmetov.';

      case InventoryFilter.duplicates:
        return 'Nimaš še nobenih viškov.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = widget.collection;

    return Scaffold(
      appBar: AppBar(title: Text(collection.name)),
      body: StreamBuilder<List<CatalogItem>>(
        stream: _catalogItemService.watchItems(collection.id),
        builder: (context, catalogSnapshot) {
          if (catalogSnapshot.connectionState == ConnectionState.waiting &&
              !catalogSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catalogSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Predmetov ni bilo mogoče naložiti:\n'
                  '${catalogSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final catalogItems = catalogSnapshot.data ?? <CatalogItem>[];

          return StreamBuilder<Map<String, UserItem>>(
            stream: _userItemService.watchItemsMap(collectionId: collection.id),
            builder: (context, userItemsSnapshot) {
              if (userItemsSnapshot.connectionState ==
                      ConnectionState.waiting &&
                  !userItemsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userItemsSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Inventarja ni bilo mogoče naložiti:\n'
                      '${userItemsSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final userItems = userItemsSnapshot.data ?? <String, UserItem>{};

              final filteredItems = _filterItems(
                catalogItems: catalogItems,
                userItems: userItems,
              );

              return Column(
                children: [
                  StreamBuilder<int>(
                    stream: _userItemService.watchOwnedItemCount(
                      collectionId: collection.id,
                    ),
                    builder: (context, snapshot) {
                      return CatalogProgress(
                        ownedCount: snapshot.data ?? 0,
                        totalCount: collection.totalItems,
                      );
                    },
                  ),
                  CatalogSearchBar(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Vse'),
                          selected: _selectedFilter == InventoryFilter.all,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = InventoryFilter.all;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Imam'),
                          selected: _selectedFilter == InventoryFilter.owned,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = InventoryFilter.owned;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Manjkajo'),
                          selected: _selectedFilter == InventoryFilter.missing,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = InventoryFilter.missing;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Viški'),
                          selected:
                              _selectedFilter == InventoryFilter.duplicates,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = InventoryFilter.duplicates;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _emptyMessage(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];

                              final quantity =
                                  userItems[item.id]?.quantity ?? 0;

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
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
