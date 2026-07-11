import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/services/item_service.dart';

enum ItemStatus {
  missing,
  owned,
  duplicate,
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

  final Map<int, ItemStatus> _localStatuses = {};
  final Set<int> _savingItems = {};

  ItemStatus _statusFromString(String? value) {
    switch (value) {
      case 'owned':
        return ItemStatus.owned;
      case 'duplicate':
        return ItemStatus.duplicate;
      case 'missing':
      default:
        return ItemStatus.missing;
    }
  }

  String _statusToString(ItemStatus status) {
    switch (status) {
      case ItemStatus.missing:
        return 'missing';
      case ItemStatus.owned:
        return 'owned';
      case ItemStatus.duplicate:
        return 'duplicate';
    }
  }

  ItemStatus _nextStatus(ItemStatus currentStatus) {
    switch (currentStatus) {
      case ItemStatus.missing:
        return ItemStatus.owned;
      case ItemStatus.owned:
        return ItemStatus.duplicate;
      case ItemStatus.duplicate:
        return ItemStatus.missing;
    }
  }

  Future<void> _toggleStatus({
    required int itemNumber,
    required ItemStatus currentStatus,
  }) async {
    if (_savingItems.contains(itemNumber)) {
      return;
    }

    final nextStatus = _nextStatus(currentStatus);

    setState(() {
      _localStatuses[itemNumber] = nextStatus;
      _savingItems.add(itemNumber);
    });

    try {
      await _itemService.saveItemStatus(
        collectionId: widget.collectionId,
        itemNumber: itemNumber,
        status: _statusToString(nextStatus),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _localStatuses[itemNumber] = currentStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Statusa ni bilo mogoče shraniti: $error',
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

  Widget _statusChip(ItemStatus status, bool isSaving) {
    if (isSaving) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    switch (status) {
      case ItemStatus.missing:
        return const Chip(
          avatar: Icon(
            Icons.close,
            size: 18,
          ),
          label: Text('Manjka'),
        );

      case ItemStatus.owned:
        return const Chip(
          avatar: Icon(
            Icons.check,
            size: 18,
          ),
          label: Text('Imam'),
        );

      case ItemStatus.duplicate:
        return const Chip(
          avatar: Icon(
            Icons.swap_horiz,
            size: 18,
          ),
          label: Text('Višek'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _itemService.watchItems(widget.collectionId),
        builder: (context, snapshot) {
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

          final firestoreStatuses = <int, ItemStatus>{};

          for (final document in snapshot.data?.docs ?? []) {
            final data = document.data();
            final number = data['number'];

            if (number is int) {
              firestoreStatuses[number] = _statusFromString(
                data['status'] as String?,
              );
            }
          }

          return ListView.builder(
            itemCount: widget.totalItems,
            itemBuilder: (context, index) {
              final itemNumber = index + 1;

              final status = _localStatuses[itemNumber] ??
                  firestoreStatuses[itemNumber] ??
                  ItemStatus.missing;

              final isSaving = _savingItems.contains(itemNumber);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: ListTile(
                  enabled: !isSaving,
                  onTap: () {
                    _toggleStatus(
                      itemNumber: itemNumber,
                      currentStatus: status,
                    );
                  },
                  leading: CircleAvatar(
                    child: Text('$itemNumber'),
                  ),
                  title: Text('#$itemNumber'),
                  subtitle: const Text(
                    'Tapni za spremembo statusa',
                  ),
                  trailing: _statusChip(
                    status,
                    isSaving,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}