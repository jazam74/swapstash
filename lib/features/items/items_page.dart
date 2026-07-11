import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/services/item_service.dart';
import 'package:swapstash/features/items/widgets/item_card.dart';

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

  final Map<int, int> _localQuantities = {};
  final Set<int> _savingItems = {};

  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _quantityFromData(Map<String, dynamic> data) {
    final quantity = data['quantity'];

    if (quantity is int) {
      return quantity;
    }

    // Začasna združljivost s starejšimi zapisi.
    switch (data['status']) {
      case 'owned':
        return 1;
      case 'duplicate':
        return 2;
      case 'missing':
      default:
        return 0;
    }
  }

  Future<void> _changeQuantity({
    required int itemNumber,
    required int currentQuantity,
    required int change,
  }) async {
    if (_savingItems.contains(itemNumber)) {
      return;
    }

    final newQuantity =
        (currentQuantity + change).clamp(0, 999);

    if (newQuantity == currentQuantity) {
      return;
    }

    setState(() {
      _localQuantities[itemNumber] = newQuantity;
      _savingItems.add(itemNumber);
    });

    try {
      await _itemService.saveItemQuantity(
        collectionId: widget.collectionId,
        itemNumber: itemNumber,
        quantity: newQuantity,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _localQuantities[itemNumber] = currentQuantity;
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
          _savingItems.remove(itemNumber);
        });
      }
    }
  }

  Widget _summaryCard({
    required String label,
    required int value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
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

          final firestoreQuantities = <int, int>{};

          for (final document in snapshot.data?.docs ?? []) {
            final data = document.data();
            final number = data['number'];

            if (number is int) {
              firestoreQuantities[number] =
                  _quantityFromData(data);
            }
          }

          final effectiveQuantities = <int, int>{};

          for (
            var itemNumber = 1;
            itemNumber <= widget.totalItems;
            itemNumber++
          ) {
            effectiveQuantities[itemNumber] =
                _localQuantities[itemNumber] ??
                firestoreQuantities[itemNumber] ??
                0;
          }

          final ownedCount = effectiveQuantities.values
              .where((quantity) => quantity > 0)
              .length;

          final duplicateCount =
              effectiveQuantities.values.fold<int>(
            0,
            (sum, quantity) =>
                sum + (quantity > 1 ? quantity - 1 : 0),
          );

          final missingCount = effectiveQuantities.values
              .where((quantity) => quantity == 0)
              .length;

          final progress = widget.totalItems == 0
              ? 0.0
              : ownedCount / widget.totalItems;

          final visibleItems =
              effectiveQuantities.entries.where((entry) {
            if (_search.isEmpty) {
              return true;
            }

            return entry.key
                .toString()
                .contains(_search);
          }).toList();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(12, 12, 12, 4),
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
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _summaryCard(
                          label: 'Zbranih',
                          value: ownedCount,
                          icon:
                              Icons.check_circle_outline,
                        ),
                        const SizedBox(width: 8),
                        _summaryCard(
                          label: 'Viški',
                          value: duplicateCount,
                          icon: Icons.swap_horiz,
                        ),
                        const SizedBox(width: 8),
                        _summaryCard(
                          label: 'Manjka',
                          value: missingCount,
                          icon:
                              Icons.remove_circle_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$ownedCount od '
                      '${widget.totalItems} zbranih predmetov',
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: visibleItems.isEmpty
                    ? const Center(
                        child: Text(
                          'Ni predmetov, ki ustrezajo iskanju.',
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
                          final itemNumber =
                              visibleItems[index].key;
                          final quantity =
                              visibleItems[index].value;
                          final isSaving =
                              _savingItems.contains(
                            itemNumber,
                          );

                          return ItemCard(
                            itemNumber: itemNumber,
                            quantity: quantity,
                            isSaving: isSaving,
                            onIncrease: () {
                              _changeQuantity(
                                itemNumber: itemNumber,
                                currentQuantity: quantity,
                                change: 1,
                              );
                            },
                            onDecrease: () {
                              _changeQuantity(
                                itemNumber: itemNumber,
                                currentQuantity: quantity,
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