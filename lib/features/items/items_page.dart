import 'package:flutter/material.dart';

enum ItemStatus {
  missing,
  owned,
  duplicate,
}

class ItemsPage extends StatefulWidget {
  final String collectionName;
  final int totalItems;

  const ItemsPage({
    super.key,
    required this.collectionName,
    required this.totalItems,
  });

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late List<ItemStatus> _statuses;

  @override
  void initState() {
    super.initState();

    _statuses = List.generate(
      widget.totalItems,
      (_) => ItemStatus.missing,
    );
  }

  void _toggleStatus(int index) {
    setState(() {
      switch (_statuses[index]) {
        case ItemStatus.missing:
          _statuses[index] = ItemStatus.owned;
          break;

        case ItemStatus.owned:
          _statuses[index] = ItemStatus.duplicate;
          break;

        case ItemStatus.duplicate:
          _statuses[index] = ItemStatus.missing;
          break;
      }
    });
  }

  Widget _statusChip(ItemStatus status) {
    switch (status) {
      case ItemStatus.missing:
        return const Chip(
          label: Text("❌ Manjka"),
        );

      case ItemStatus.owned:
        return const Chip(
          label: Text("✅ Imam"),
        );

      case ItemStatus.duplicate:
        return const Chip(
          label: Text("🔄 Višek"),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
      ),
      body: ListView.builder(
        itemCount: widget.totalItems,
        itemBuilder: (context, index) {
          final itemNumber = index + 1;

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            child: ListTile(
              onTap: () => _toggleStatus(index),
              leading: CircleAvatar(
                child: Text(itemNumber.toString()),
              ),
              title: Text("#$itemNumber"),
              trailing: _statusChip(_statuses[index]),
            ),
          );
        },
      ),
    );
  }
}