import 'package:flutter/material.dart';

enum InventoryFilter {
  all,
  owned,
 missing,
  duplicates,
}

class CatalogFilterBar extends StatelessWidget {
  final InventoryFilter selectedFilter;
  final ValueChanged<InventoryFilter> onChanged;

  const CatalogFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        4,
      ),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Vse'),
            selected: selectedFilter == InventoryFilter.all,
            onSelected: (_) => onChanged(InventoryFilter.all),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Imam'),
            selected: selectedFilter == InventoryFilter.owned,
            onSelected: (_) => onChanged(InventoryFilter.owned),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Manjkajo'),
            selected: selectedFilter == InventoryFilter.missing,
            onSelected: (_) => onChanged(InventoryFilter.missing),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Viški'),
            selected: selectedFilter == InventoryFilter.duplicates,
            onSelected: (_) => onChanged(InventoryFilter.duplicates),
          ),
        ],
      ),
    );
  }
}