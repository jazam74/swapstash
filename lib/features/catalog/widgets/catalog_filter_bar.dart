import 'package:flutter/material.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

enum InventoryFilter { all, owned, missing, duplicates }

enum RarityFilter { all, common, rare, ultraRare, limitedEdition, other }

class CatalogFilterBar extends StatelessWidget {
  final InventoryFilter selectedFilter;
  final ValueChanged<InventoryFilter> onChanged;
  final RarityFilter selectedRarityFilter;
  final ValueChanged<RarityFilter> onRarityChanged;

  const CatalogFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
    required this.selectedRarityFilter,
    required this.onRarityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              _InventoryChip(
                label: localizations.catalogAll,
                filter: InventoryFilter.all,
                selectedFilter: selectedFilter,
                onChanged: onChanged,
              ),
              const SizedBox(width: 8),
              _InventoryChip(
                label: localizations.catalogOwned,
                filter: InventoryFilter.owned,
                selectedFilter: selectedFilter,
                onChanged: onChanged,
              ),
              const SizedBox(width: 8),
              _InventoryChip(
                label: localizations.catalogMissingPlural,
                filter: InventoryFilter.missing,
                selectedFilter: selectedFilter,
                onChanged: onChanged,
              ),
              const SizedBox(width: 8),
              _InventoryChip(
                label: localizations.catalogDuplicates,
                filter: InventoryFilter.duplicates,
                selectedFilter: selectedFilter,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Text(
            localizations.catalogRarity,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(
            children: [
              _RarityChip(
                label: localizations.catalogAll,
                filter: RarityFilter.all,
                selectedFilter: selectedRarityFilter,
                onChanged: onRarityChanged,
              ),
              const SizedBox(width: 8),
              _RarityChip(
                label: localizations.catalogRarityCommon,
                filter: RarityFilter.common,
                selectedFilter: selectedRarityFilter,
                onChanged: onRarityChanged,
              ),
              const SizedBox(width: 8),
              _RarityChip(
                label: localizations.catalogRarityRare,
                filter: RarityFilter.rare,
                selectedFilter: selectedRarityFilter,
                onChanged: onRarityChanged,
              ),
              const SizedBox(width: 8),
              _RarityChip(
                label: localizations.catalogRarityUltraRare,
                filter: RarityFilter.ultraRare,
                selectedFilter: selectedRarityFilter,
                onChanged: onRarityChanged,
              ),
              const SizedBox(width: 8),
              _RarityChip(
                label: localizations.catalogRarityLimitedEdition,
                filter: RarityFilter.limitedEdition,
                selectedFilter: selectedRarityFilter,
                onChanged: onRarityChanged,
              ),
              const SizedBox(width: 8),
              _RarityChip(
                label: localizations.catalogOther,
                filter: RarityFilter.other,
                selectedFilter: selectedRarityFilter,
                onChanged: onRarityChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InventoryChip extends StatelessWidget {
  final String label;
  final InventoryFilter filter;
  final InventoryFilter selectedFilter;
  final ValueChanged<InventoryFilter> onChanged;

  const _InventoryChip({
    required this.label,
    required this.filter,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selectedFilter == filter,
      onSelected: (_) => onChanged(filter),
    );
  }
}

class _RarityChip extends StatelessWidget {
  final String label;
  final RarityFilter filter;
  final RarityFilter selectedFilter;
  final ValueChanged<RarityFilter> onChanged;

  const _RarityChip({
    required this.label,
    required this.filter,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: const Icon(Icons.diamond_outlined, size: 17),
      label: Text(label),
      selected: selectedFilter == filter,
      onSelected: (_) => onChanged(filter),
    );
  }
}
