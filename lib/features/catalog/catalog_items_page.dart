import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/collection_stats.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/core/services/catalog_item_service.dart';
import 'package:swapstash/core/services/user_item_service.dart';
import 'package:swapstash/features/catalog/widgets/catalog_filter_bar.dart';
import 'package:swapstash/features/catalog/widgets/catalog_grid.dart';
import 'package:swapstash/features/catalog/widgets/catalog_progress.dart';
import 'package:swapstash/features/catalog/widgets/catalog_search_bar.dart';
import 'package:swapstash/features/trades/find_trades_page.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

enum CatalogSortOption {
  numberAscending,
  numberDescending,
  nameAscending,
  nameDescending,
  rarityAscending,
  rarityDescending,
}

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
  String? _selectedRarity;
  final Map<String, String> _selectedAttributes = {};
  CatalogSortOption _selectedSortOption = CatalogSortOption.numberAscending;
  String _searchQuery = '';
  bool _quickEntryEnabled = false;
  int _searchFieldVersion = 0;

  final Map<String, int> _pendingQuantities = {};
  final Map<String, Timer> _saveTimers = {};
  final Set<String> _savingItemIds = {};

  @override
  void initState() {
    super.initState();
    unawaited(_migrateLegacyInventory());
  }

  Future<void> _migrateLegacyInventory() async {
    try {
      await _userItemService.migrateLegacyItemDocuments(
        collectionId: widget.collection.id,
      );
    } catch (error, stackTrace) {
      debugPrint('Migracija stare zaloge ni uspela: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  int _storedQuantityForItem({
    required CatalogItem item,
    required Map<String, UserItem> userItems,
  }) {
    return userItems[item.id]?.quantity ??
        userItems[item.number]?.quantity ??
        0;
  }

  @override
  void dispose() {
    for (final timer in _saveTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  List<CatalogItem> _filterItems({
    required List<CatalogItem> catalogItems,
    required Map<String, UserItem> userItems,
  }) {
    final query = _searchQuery.trim().toLowerCase();

    final filteredItems = catalogItems.where((item) {
      if (query.isNotEmpty) {
        final matches =
            item.number.toLowerCase().contains(query) ||
            item.name.toLowerCase().contains(query) ||
            item.rarity.toLowerCase().contains(query) ||
            item.attributes.entries.any(
              (entry) =>
                  entry.key.toLowerCase().contains(query) ||
                  entry.value.toLowerCase().contains(query),
            );

        if (!matches) {
          return false;
        }
      }

      if (!_matchesRarity(item.rarity)) {
        return false;
      }

      if (!_matchesSelectedAttributes(item)) {
        return false;
      }

      final quantity =
          _pendingQuantities[item.id] ??
          _storedQuantityForItem(item: item, userItems: userItems);

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

    switch (_selectedSortOption) {
      case CatalogSortOption.numberAscending:
        // CatalogItemService že vrne elemente v vrstnem redu sortOrder.
        return filteredItems;

      case CatalogSortOption.numberDescending:
        return filteredItems.reversed.toList(growable: false);

      case CatalogSortOption.nameAscending:
      case CatalogSortOption.nameDescending:
      case CatalogSortOption.rarityAscending:
      case CatalogSortOption.rarityDescending:
        filteredItems.sort(_compareItems);
        return filteredItems;
    }
  }

  int _compareItems(CatalogItem first, CatalogItem second) {
    switch (_selectedSortOption) {
      case CatalogSortOption.numberAscending:
        return _compareNumbers(first.number, second.number);

      case CatalogSortOption.numberDescending:
        return _compareNumbers(second.number, first.number);

      case CatalogSortOption.nameAscending:
        return first.name.toLowerCase().compareTo(second.name.toLowerCase());

      case CatalogSortOption.nameDescending:
        return second.name.toLowerCase().compareTo(first.name.toLowerCase());

      case CatalogSortOption.rarityAscending:
        return _compareRarity(first, second);

      case CatalogSortOption.rarityDescending:
        return _compareRarity(second, first);
    }
  }

  int _compareNumbers(String first, String second) {
    final firstNumber = int.tryParse(first.replaceAll(RegExp(r'[^0-9]'), ''));
    final secondNumber = int.tryParse(second.replaceAll(RegExp(r'[^0-9]'), ''));

    if (firstNumber != null && secondNumber != null) {
      final comparison = firstNumber.compareTo(secondNumber);
      if (comparison != 0) {
        return comparison;
      }
    }

    return first.toLowerCase().compareTo(second.toLowerCase());
  }

  int _compareRarity(CatalogItem first, CatalogItem second) {
    final comparison = first.rarity.trim().toLowerCase().compareTo(
      second.rarity.trim().toLowerCase(),
    );

    if (comparison != 0) {
      return comparison;
    }

    return _compareNumbers(first.number, second.number);
  }

  String _sortLabel(CatalogSortOption option, AppLocalizations localizations) {
    switch (option) {
      case CatalogSortOption.numberAscending:
        return localizations.catalogSortNumberAscending;
      case CatalogSortOption.numberDescending:
        return localizations.catalogSortNumberDescending;
      case CatalogSortOption.nameAscending:
        return localizations.catalogSortNameAscending;
      case CatalogSortOption.nameDescending:
        return localizations.catalogSortNameDescending;
      case CatalogSortOption.rarityAscending:
        return localizations.catalogSortRarityAscending;
      case CatalogSortOption.rarityDescending:
        return localizations.catalogSortRarityDescending;
    }
  }

  List<String> _availableRarities(List<CatalogItem> items) {
    final valuesByNormalizedName = <String, String>{};

    for (final item in items) {
      final value = item.rarity.trim();
      if (value.isEmpty) {
        continue;
      }

      valuesByNormalizedName.putIfAbsent(value.toLowerCase(), () => value);
    }

    final values = valuesByNormalizedName.values.toList(growable: false)
      ..sort((first, second) {
        return first.toLowerCase().compareTo(second.toLowerCase());
      });

    return values;
  }

  bool _isSameRarity(String first, String second) {
    return first.trim().toLowerCase() == second.trim().toLowerCase();
  }

  Map<String, List<String>> _availableAttributeOptions(
    List<CatalogItem> items,
    AppLocalizations localizations,
  ) {
    final canonicalKeys = <String, String>{};
    final valuesByKey = <String, Map<String, String>>{};

    for (final item in items) {
      for (final entry in item.attributes.entries) {
        final key = entry.key.trim();
        final value = entry.value.trim();
        final normalizedKey = key.toLowerCase();
        final normalizedValue = value.toLowerCase();

        if (key.isEmpty || value.isEmpty || normalizedKey == 'rarity') {
          continue;
        }

        canonicalKeys.putIfAbsent(normalizedKey, () => key);
        valuesByKey
            .putIfAbsent(normalizedKey, () => <String, String>{})
            .putIfAbsent(normalizedValue, () => value);
      }
    }

    final normalizedKeys = valuesByKey.keys.toList(growable: false)
      ..sort((first, second) {
        return _attributeLabel(
          canonicalKeys[first] ?? first,
          localizations,
        ).compareTo(
          _attributeLabel(canonicalKeys[second] ?? second, localizations),
        );
      });

    return {
      for (final normalizedKey in normalizedKeys)
        canonicalKeys[normalizedKey] ?? normalizedKey:
            (valuesByKey[normalizedKey]!.values.toList(growable: false)..sort(
              (first, second) =>
                  first.toLowerCase().compareTo(second.toLowerCase()),
            )),
    };
  }

  String _attributeLabel(String key, AppLocalizations localizations) {
    switch (key.trim().toLowerCase()) {
      case 'country':
        return localizations.catalogAttributeCountry;
      case 'team':
        return localizations.catalogAttributeTeam;
      case 'year':
        return localizations.catalogAttributeYear;
      case 'type':
        return localizations.catalogAttributeType;
      case 'series':
        return localizations.catalogAttributeSeries;
      case 'set':
        return localizations.catalogAttributeSet;
      case 'brand':
        return localizations.catalogAttributeBrand;
      case 'manufacturer':
        return localizations.catalogAttributeManufacturer;
      case 'material':
        return localizations.catalogAttributeMaterial;
      case 'denomination':
        return localizations.catalogAttributeDenomination;
      case 'theme':
        return localizations.catalogAttributeTheme;
      case 'character':
        return localizations.catalogAttributeCharacter;
      case 'franchise':
        return localizations.catalogAttributeFranchise;
      default:
        return _humanizeAttributeKey(key);
    }
  }

  String _humanizeAttributeKey(String key) {
    final withSpaces = key
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();

    if (withSpaces.isEmpty) {
      return key;
    }

    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }

  bool _matchesSelectedAttributes(CatalogItem item) {
    for (final selectedEntry in _selectedAttributes.entries) {
      final itemValue = item.attributeValue(selectedEntry.key);

      if (itemValue.trim().toLowerCase() !=
          selectedEntry.value.trim().toLowerCase()) {
        return false;
      }
    }

    return true;
  }

  Future<void> _openAttributeFilters(
    Map<String, List<String>> availableAttributes,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final draftSelection = Map<String, String>.from(_selectedAttributes);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return FractionallySizedBox(
              heightFactor: 0.82,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            localizations.catalogAdditionalFilters,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: localizations.catalogClose,
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: availableAttributes.entries
                          .map((entry) {
                            final key = entry.key;
                            final values = entry.value;
                            final selectedValue = draftSelection[key] ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: DropdownButtonFormField<String>(
                                key: ValueKey('$key-$selectedValue'),
                                initialValue: selectedValue,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: _attributeLabel(
                                    key,
                                    localizations,
                                  ),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: '',
                                    child: Text(localizations.catalogAll),
                                  ),
                                  ...values.map(
                                    (value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setSheetState(() {
                                    if (value == null || value.isEmpty) {
                                      draftSelection.remove(key);
                                    } else {
                                      draftSelection[key] = value;
                                    }
                                  });
                                },
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setSheetState(draftSelection.clear);
                          },
                          child: Text(localizations.catalogClear),
                        ),
                        const Spacer(),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                          ),
                          onPressed: () {
                            Navigator.of(sheetContext).pop(draftSelection);
                          },
                          child: Text(localizations.catalogApply),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _selectedAttributes
        ..clear()
        ..addAll(result);
    });
  }

  void _removeInvalidAttributeSelections(
    Map<String, List<String>> availableAttributes,
  ) {
    final invalidKeys = _selectedAttributes.entries
        .where((selectedEntry) {
          final availableEntry = availableAttributes.entries.where(
            (entry) =>
                entry.key.trim().toLowerCase() ==
                selectedEntry.key.trim().toLowerCase(),
          );

          if (availableEntry.isEmpty) {
            return true;
          }

          return !availableEntry.first.value.any(
            (value) =>
                value.trim().toLowerCase() ==
                selectedEntry.value.trim().toLowerCase(),
          );
        })
        .map((entry) => entry.key)
        .toList(growable: false);

    if (invalidKeys.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        for (final key in invalidKeys) {
          _selectedAttributes.remove(key);
        }
      });
    });
  }

  String _inventoryLabel(
    InventoryFilter filter,
    AppLocalizations localizations,
  ) {
    switch (filter) {
      case InventoryFilter.all:
        return localizations.catalogAll;
      case InventoryFilter.owned:
        return localizations.catalogOwned;
      case InventoryFilter.missing:
        return localizations.catalogMissingPlural;
      case InventoryFilter.duplicates:
        return localizations.catalogDuplicates;
    }
  }

  bool get _hasActiveSearchOrFilters {
    return _searchQuery.trim().isNotEmpty ||
        _selectedFilter != InventoryFilter.all ||
        _selectedRarity != null ||
        _selectedAttributes.isNotEmpty;
  }

  void _resetSearchAndFilters() {
    setState(() {
      _searchQuery = '';
      _selectedFilter = InventoryFilter.all;
      _selectedRarity = null;
      _selectedAttributes.clear();
      _searchFieldVersion++;
    });
  }

  bool _matchesRarity(String rarity) {
    final selectedRarity = _selectedRarity;

    if (selectedRarity == null) {
      return true;
    }

    return _isSameRarity(rarity, selectedRarity);
  }

  String _emptyMessage(AppLocalizations localizations) {
    if (_searchQuery.trim().isNotEmpty) {
      return localizations.catalogNoSearchResults;
    }

    if (_selectedRarity != null || _selectedAttributes.isNotEmpty) {
      return localizations.catalogNoFilterResults;
    }

    switch (_selectedFilter) {
      case InventoryFilter.all:
        return localizations.catalogNoItems;
      case InventoryFilter.owned:
        return localizations.catalogNoOwnedItems;
      case InventoryFilter.missing:
        return localizations.catalogCollectionComplete;
      case InventoryFilter.duplicates:
        return localizations.catalogNoDuplicates;
    }
  }

  void _openTradeFinder() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FindTradesPage(collection: widget.collection),
      ),
    );
  }

  void _changeQuantity({
    required CatalogItem item,
    required Map<String, UserItem> userItems,
    required int change,
  }) {
    final currentQuantity =
        _pendingQuantities[item.id] ??
        _storedQuantityForItem(item: item, userItems: userItems);
    final nextQuantity = currentQuantity + change;

    if (nextQuantity < 0 || nextQuantity == currentQuantity) {
      return;
    }

    setState(() {
      _pendingQuantities[item.id] = nextQuantity;
    });

    _saveTimers.remove(item.id)?.cancel();
    _saveTimers[item.id] = Timer(
      const Duration(milliseconds: 450),
      () => _persistQuantity(itemId: item.id, quantity: nextQuantity),
    );
  }

  Future<void> _persistQuantity({
    required String itemId,
    required int quantity,
  }) async {
    _saveTimers.remove(itemId);

    if (!mounted) {
      return;
    }

    setState(() {
      _savingItemIds.add(itemId);
    });

    try {
      await _userItemService.saveItem(
        collectionId: widget.collection.id,
        itemId: itemId,
        quantity: quantity,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _pendingQuantities.remove(itemId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.catalogQuantitySaveError(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingItemIds.remove(itemId);
        });
      }
    }
  }

  void _reconcilePendingQuantities(Map<String, UserItem> userItems) {
    final resolvedIds = _pendingQuantities.entries
        .where((entry) {
          final itemId = entry.key;
          final serverQuantity = userItems[itemId]?.quantity ?? 0;

          return !_saveTimers.containsKey(itemId) &&
              !_savingItemIds.contains(itemId) &&
              serverQuantity == entry.value;
        })
        .map((entry) => entry.key)
        .toList(growable: false);

    if (resolvedIds.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        for (final itemId in resolvedIds) {
          final pendingQuantity = _pendingQuantities[itemId];
          final serverQuantity = userItems[itemId]?.quantity ?? 0;

          if (pendingQuantity == serverQuantity &&
              !_saveTimers.containsKey(itemId) &&
              !_savingItemIds.contains(itemId)) {
            _pendingQuantities.remove(itemId);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                  localizations.catalogItemsLoadErrorDetails(
                    catalogSnapshot.error.toString(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final catalogItems = catalogSnapshot.data ?? <CatalogItem>[];
          final availableRarities = _availableRarities(catalogItems);
          final hasRarityFilter = availableRarities.isNotEmpty;
          final availableAttributes = _availableAttributeOptions(
            catalogItems,
            localizations,
          );
          final hasAdditionalFilters = availableAttributes.isNotEmpty;
          _removeInvalidAttributeSelections(availableAttributes);
          final selectedRarityStillExists =
              _selectedRarity == null ||
              availableRarities.any(
                (rarity) => _isSameRarity(rarity, _selectedRarity!),
              );

          if (!selectedRarityStillExists) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedRarity != null) {
                setState(() {
                  _selectedRarity = null;
                });
              }
            });
          }

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
                      localizations.catalogInventoryLoadErrorDetails(
                        userItemsSnapshot.error.toString(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final userItems = userItemsSnapshot.data ?? <String, UserItem>{};
              _reconcilePendingQuantities(userItems);

              final filteredItems = _filterItems(
                catalogItems: catalogItems,
                userItems: userItems,
              );

              return LayoutBuilder(
                builder: (context, constraints) {
                  const maxContentWidth = 1400.0;

                  final contentWidth = constraints.maxWidth > maxContentWidth
                      ? maxContentWidth
                      : constraints.maxWidth;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        children: [
                  if (!_hasActiveSearchOrFilters)
                    StreamBuilder<CollectionStats>(
                      stream: _userItemService.watchCollectionStats(
                        collectionId: collection.id,
                      ),
                      builder: (context, snapshot) {
                        return CatalogProgress(
                          stats:
                              snapshot.data ??
                              const CollectionStats(
                                owned: 0,
                                duplicates: 0,
                                totalQuantity: 0,
                              ),
                          totalCount: collection.totalItems,
                        );
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${localizations.catalogResultsCount(filteredItems.length)}'
                              ' • ${_inventoryLabel(_selectedFilter, localizations)}'
                              '${_selectedRarity == null ? '' : ' • $_selectedRarity'}'
                              '${_selectedAttributes.isEmpty ? '' : ' • ${localizations.catalogAdditionalFilterCount(_selectedAttributes.length)}'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          TextButton(
                            onPressed: _resetSearchAndFilters,
                            child: Text(localizations.catalogClear),
                          ),
                        ],
                      ),
                    ),
                  CatalogSearchBar(
                    key: ValueKey(_searchFieldVersion),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text(localizations.catalogAll),
                          selected: _selectedFilter == InventoryFilter.all,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = InventoryFilter.all;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: Text(localizations.catalogOwned),
                          selected: _selectedFilter == InventoryFilter.owned,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = InventoryFilter.owned;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: Text(localizations.catalogMissingPlural),
                          selected: _selectedFilter == InventoryFilter.missing,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = InventoryFilter.missing;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: Text(localizations.catalogDuplicates),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                    child: Row(
                      children: [
                        if (hasRarityFilter) ...[
                          Expanded(
                            child: PopupMenuButton<String>(
                              tooltip: localizations.catalogFilterByRarity,
                              initialValue: _selectedRarity ?? '',
                              onSelected: (rarity) {
                                setState(() {
                                  _selectedRarity = rarity.isEmpty
                                      ? null
                                      : rarity;
                                });
                              },
                              itemBuilder: (context) {
                                return <PopupMenuEntry<String>>[
                                  CheckedPopupMenuItem<String>(
                                    value: '',
                                    checked: _selectedRarity == null,
                                    child: Text(
                                      localizations.catalogAllRarities,
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  ...availableRarities.map(
                                    (rarity) => CheckedPopupMenuItem<String>(
                                      value: rarity,
                                      checked:
                                          _selectedRarity != null &&
                                          _isSameRarity(
                                            rarity,
                                            _selectedRarity!,
                                          ),
                                      child: Text(rarity),
                                    ),
                                  ),
                                ];
                              },
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.diamond_outlined,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedRarity == null
                                            ? localizations.catalogRarityAll
                                            : localizations
                                                  .catalogRaritySelected(
                                                    _selectedRarity!,
                                                  ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (hasAdditionalFilters)
                          IconButton.filledTonal(
                            tooltip: _selectedAttributes.isEmpty
                                ? localizations.catalogAdditionalFilters
                                : localizations.catalogAdditionalFiltersCount(
                                    _selectedAttributes.length,
                                  ),
                            onPressed: () {
                              _openAttributeFilters(availableAttributes);
                            },
                            icon: Badge(
                              isLabelVisible: _selectedAttributes.isNotEmpty,
                              label: Text(
                                _selectedAttributes.length.toString(),
                              ),
                              child: const Icon(Icons.tune),
                            ),
                          ),
                        IconButton.filledTonal(
                          tooltip: _quickEntryEnabled
                              ? localizations.catalogDisableQuickEntry
                              : localizations.catalogEnableQuickEntry,
                          isSelected: _quickEntryEnabled,
                          selectedIcon: const Icon(Icons.edit_note),
                          onPressed: () {
                            setState(() {
                              _quickEntryEnabled = !_quickEntryEnabled;
                            });
                          },
                          icon: const Icon(Icons.edit_note_outlined),
                        ),
                        PopupMenuButton<CatalogSortOption>(
                          tooltip: localizations.catalogSortItems,
                          initialValue: _selectedSortOption,
                          icon: const Icon(Icons.sort),
                          onSelected: (option) {
                            setState(() {
                              _selectedSortOption = option;
                            });
                          },
                          itemBuilder: (context) {
                            final options = CatalogSortOption.values.where((
                              option,
                            ) {
                              if (hasRarityFilter) {
                                return true;
                              }

                              return option !=
                                      CatalogSortOption.rarityAscending &&
                                  option != CatalogSortOption.rarityDescending;
                            });

                            return options
                                .map(
                                  (option) =>
                                      CheckedPopupMenuItem<CatalogSortOption>(
                                        value: option,
                                        checked: option == _selectedSortOption,
                                        child: Text(
                                          _sortLabel(option, localizations),
                                        ),
                                      ),
                                )
                                .toList(growable: false);
                          },
                        ),
                        IconButton.filledTonal(
                          tooltip: localizations.catalogFindTrades,
                          onPressed: _openTradeFinder,
                          icon: const Icon(Icons.handshake_outlined),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CatalogGrid(
                      collection: collection,
                      items: filteredItems,
                      userItems: userItems,
                      quantityOverrides: _pendingQuantities,
                      savingItemIds: _savingItemIds,
                      quickEntryEnabled: _quickEntryEnabled,
                      emptyMessage: _emptyMessage(localizations),
                      onQuantityChanged: (item, change) {
                        _changeQuantity(
                          item: item,
                          userItems: userItems,
                          change: change,
                        );
                      },
                    ),
                  ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

