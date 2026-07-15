import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/core/services/user_item_service.dart';

class ItemDetailPage extends StatefulWidget {
  final CatalogCollection collection;
  final CatalogItem item;

  const ItemDetailPage({
    super.key,
    required this.collection,
    required this.item,
  });

  @override
  State<ItemDetailPage> createState() =>
      _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final UserItemService _service = UserItemService();

  bool _isSaving = false;

  Future<void> _saveQuantity(int quantity) async {
    if (_isSaving || quantity < 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _service.saveItem(
        collectionId: widget.collection.id,
        itemId: widget.item.id,
        quantity: quantity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            quantity == 0
                ? 'Predmet je označen kot manjkajoč.'
                : 'Količina je posodobljena na $quantity.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

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
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.number),
      ),
      body: StreamBuilder<UserItem?>(
        stream: _service.watchItem(
          collectionId: widget.collection.id,
          itemId: widget.item.id,
        ),
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
                  'Statusa predmeta ni bilo mogoče naložiti:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final userItem = snapshot.data;
          final quantity = userItem?.quantity ?? 0;
          final duplicateCount =
              userItem?.duplicateCount ?? 0;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.item.number,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.item.name.isEmpty
                      ? 'Predmet ${widget.item.number}'
                      : widget.item.name,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Icon(
                      quantity > 0
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: quantity > 0
                          ? Colors.green
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      quantity > 0 ? 'Imam' : 'Nimam',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Količina',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Zmanjšaj količino',
                      onPressed:
                          quantity == 0 || _isSaving
                              ? null
                              : () => _saveQuantity(
                                    quantity - 1,
                                  ),
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 72,
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: 'Povečaj količino',
                      onPressed: _isSaving
                          ? null
                          : () => _saveQuantity(
                                quantity + 1,
                              ),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            duplicateCount == 0
                                ? 'Nimaš viškov.'
                                : duplicateCount == 1
                                    ? 'Imaš 1 višek.'
                                    : 'Imaš $duplicateCount viškov.',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}