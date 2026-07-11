import 'package:flutter/material.dart';
import 'package:swapstash/core/models/item.dart';
import 'package:swapstash/core/services/item_service.dart';
import 'package:swapstash/features/items/widgets/item_card.dart';
import 'package:swapstash/features/items/widgets/item_statistics.dart';

enum ItemFilter {
  all,
  owned,
  missing,
  duplicates,
}

class ItemsPage extends StatefulWidget {
  final String collectionId;
  final String collectionName;
  final int totalItems;

  const ItemsPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
    required this.totalItems,
  });

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final ItemService _itemService = ItemService();
  final TextEditingController _searchController =
      TextEditingController();

  final Map<int, Item> _localItems = {};
  final Set<int> _savingItems = {};

  String _search = '';
  ItemFilter _selectedFilter = ItemFilter.all;

  @override
  void initState() {
    super.initState();
    _rebuildStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _rebuildStats() async {
    try {
      await _itemService.rebuildCollectionStats(
        collectionId: widget.collectionId,
      );
    } catch (error) {
      debugPrint(
        'Statistike zbirke ni bilo mogoče preračunati: $error',
      );
    }
  }

  Future<void> _changeQuantity({
    required Item item,
    required int change,
  }) async {
    if (_savingItems.contains(item.number)) {
      return;
    }

    final newQuantity = (item.quantity + change).clamp(0, 999);

    if (newQuantity == item.quantity) {
      return;
    }

    final updatedItem = item.copyWith(
      quantity: newQuantity,
    );

    setState(() {
      _localItems[item.number] = updatedItem;
      _savingItems.add(item.number);
    });

    try {
      await _itemService.saveItemQuantity(
        collectionId: widget.collectionId,
        itemNumber: item.number,
        quantity: newQuantity,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _localItems[item.number] = item;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Količine ni bilo mogoče shraniti: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingItems.remove(item.number);
        });
      }
    }
  }

  List<Item> _createCompleteItemList(
    List<Item> storedItems,
  ) {
    final storedItemsByNumber = {
      for (final item in storedItems)
        if (item.number >= 1 &&
            item.number <= widget.totalItems)
          item.number: item,
    };

    return List.generate(
      widget.totalItems,
      (index) {
        final itemNumber = index + 1;

        return _localItems[itemNumber] ??
            storedItemsByNumber[itemNumber] ??
            Item(
              number: itemNumber,
              quantity: 0,
            );
      },
    );
  }

  List<Item> _filterItems(List<Item> items) {
    return items.where((item) {
      final matchesSearch = _search.isEmpty ||
          item.number.toString().contains(_search);

      if (!matchesSearch) {
        return false;
      }

      switch (_selectedFilter) {
        case ItemFilter.all:
          return true;

        case ItemFilter.owned:
          return item.isOwned;

        case ItemFilter.missing:
          return item.isMissing;

        case ItemFilter.duplicates:
          return item.hasDuplicates;
      }
    }).toList();
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        4,
      ),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Vsi'),
            selected: _selectedFilter == ItemFilter.all,
            onSelected: (_) {
              setState(() {
                _selectedFilter = ItemFilter.all;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Imam'),
            selected: _selectedFilter == ItemFilter.owned,
            onSelected: (_) {
              setState(() {
                _selectedFilter = ItemFilter.owned;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Manjkajo'),
            selected: _selectedFilter == ItemFilter.missing,
            onSelected: (_) {
              setState(() {
                _selectedFilter = ItemFilter.missing;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Viški'),
            selected: _selectedFilter == ItemFilter.duplicates,
            onSelected: (_) {
              setState(() {
                _selectedFilter = ItemFilter.duplicates;
              });
            },
          ),
        ],
      ),
    );
  }

  String _emptyMessage() {
    switch (_selectedFilter) {
      case ItemFilter.all:
        return 'Ni predmetov, ki ustrezajo iskanju.';

      case ItemFilter.owned:
        return 'Ni zbranih predmetov, ki ustrezajo iskanju.';

      case ItemFilter.missing:
        return 'Ni manjkajočih predmetov, ki ustrezajo iskanju.';

      case ItemFilter.duplicates:
        return 'Ni viškov, ki ustrezajo iskanju.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
      ),
      body: StreamBuilder<List<Item>>(
        stream: _itemService.watchItems(widget.collectionId),
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

          final items = _createCompleteItemList(
            snapshot.data ?? [],
          );

          final visibleItems = _filterItems(items);

          final ownedCount =
              items.where((item) => item.isOwned).length;

          final duplicateCount = items.fold<int>(
            0,
            (sum, item) => sum + item.duplicateCount,
          );

          final missingCount =
              items.where((item) => item.isMissing).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  4,
                ),
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Išči številko...',
                    border: const OutlineInputBorder(),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Počisti iskanje',
                            onPressed: () {
                              _searchController.clear();

                              setState(() {
                                _search = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _search = value.trim();
                    });
                  },
                ),
              ),
              _buildFilterBar(),
              ItemStatistics(
                ownedCount: ownedCount,
                duplicateCount: duplicateCount,
                missingCount: missingCount,
                totalItems: widget.totalItems,
              ),
              const Divider(),
              Expanded(
                child: visibleItems.isEmpty
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
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.55,
                        ),
                        itemCount: visibleItems.length,
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          final isSaving =
                              _savingItems.contains(item.number);

                          return ItemCard(
                            item: item,
                            isSaving: isSaving,
                            onIncrease: () {
                              _changeQuantity(
                                item: item,
                                change: 1,
                              );
                            },
                            onDecrease: () {
                              _changeQuantity(
                                item: item,
                                change: -1,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}