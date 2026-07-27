import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/favorite_item.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/core/services/favorite_service.dart';
import 'package:swapstash/core/services/user_item_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class ItemDetailPage extends StatefulWidget {
  final CatalogCollection collection;
  final CatalogItem item;

  const ItemDetailPage({
    super.key,
    required this.collection,
    required this.item,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final UserItemService _service = UserItemService();
  final FavoriteService _favoriteService = FavoriteService();

  bool _isSaving = false;
  bool _isSavingFavorite = false;

  String _resolvedImageUrl() {
    final existingImageUrl = widget.item.imageUrl.trim();

    if (existingImageUrl.isNotEmpty) {
      return existingImageUrl;
    }

    final basePath = widget.collection.itemImageBasePath
        .trim()
        .replaceAll(RegExp(r'^/+|/+$'), '');

    if (basePath.isEmpty) {
      return '';
    }

    final imageNumber = widget.item.number.trim().padLeft(3, '0');

    return '/$basePath/$imageNumber.webp';
  }

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

      if (!mounted) {
        return;
      }

      final localizations = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            quantity == 0
                ? localizations.catalogItemMarkedMissing
                : localizations.catalogQuantityUpdated(quantity),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isSavingFavorite) {
      return;
    }

    setState(() {
      _isSavingFavorite = true;
    });

    try {
      final isFavorite = await _favoriteService.toggleFavorite(
        favorite: FavoriteItem(
          collectionId: widget.collection.id,
          itemId: widget.item.id,
          number: widget.item.number,
          name: widget.item.name,
          imageUrl: _resolvedImageUrl(),
        ),
      );

      if (!mounted) {
        return;
      }

      final localizations = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? localizations.catalogAddedToFavorites
                : localizations.catalogRemovedFromFavorites,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.catalogFavoriteChangeError(error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final itemName = widget.item.name.trim().isEmpty
        ? localizations.catalogItemDefaultName(widget.item.number)
        : widget.item.name.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          StreamBuilder<bool>(
            stream: _favoriteService.watchIsFavorite(
              collectionId: widget.collection.id,
              itemId: widget.item.id,
            ),
            initialData: false,
            builder: (context, snapshot) {
              final isFavorite = snapshot.data ?? false;

              return IconButton(
                tooltip: isFavorite
                    ? localizations.catalogRemoveFromFavorites
                    : localizations.catalogAddToFavorites,
                onPressed: _isSavingFavorite ? null : _toggleFavorite,
                icon: _isSavingFavorite
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<UserItem?>(
        stream: _service.watchItem(
          collectionId: widget.collection.id,
          itemId: widget.item.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  localizations.catalogItemStatusLoadErrorDetails(
                    snapshot.error.toString(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final userItem = snapshot.data;
          final quantity = userItem?.quantity ?? 0;
          final duplicateCount = userItem?.duplicateCount ?? 0;

          return LayoutBuilder(
            builder: (context, constraints) {
              const maxContentWidth = 1180.0;

              final horizontalPadding = constraints.maxWidth >= 900
                  ? 24.0
                  : 16.0;
              final availableWidth =
                  constraints.maxWidth - (horizontalPadding * 2);
              final contentWidth = availableWidth > maxContentWidth
                  ? maxContentWidth
                  : availableWidth;
              final useDesktopLayout = contentWidth >= 900;

              final imageCard = _ItemImageCard(
                imageUrl: _resolvedImageUrl(),
                number: widget.item.number,
                name: itemName,
              );

              final detailsColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ItemHeaderCard(
                    collectionName: widget.collection.name,
                    number: widget.item.number,
                    name: itemName,
                    rarity: widget.item.rarity,
                  ),
                  const SizedBox(height: 16),
                  _OwnershipCard(
                    quantity: quantity,
                    duplicateCount: duplicateCount,
                  ),
                  const SizedBox(height: 16),
                  _QuantityCard(
                    quantity: quantity,
                    isSaving: _isSaving,
                    onDecrease: quantity == 0 || _isSaving
                        ? null
                        : () => _saveQuantity(quantity - 1),
                    onIncrease: _isSaving
                        ? null
                        : () => _saveQuantity(quantity + 1),
                  ),
                ],
              );

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  32,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    child: useDesktopLayout
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: imageCard),
                              const SizedBox(width: 24),
                              Expanded(flex: 5, child: detailsColumn),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              imageCard,
                              const SizedBox(height: 18),
                              detailsColumn,
                            ],
                          ),
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

class _ItemImageCard extends StatelessWidget {
  final String imageUrl;
  final String number;
  final String name;

  const _ItemImageCard({
    required this.imageUrl,
    required this.number,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();

    return AspectRatio(
      aspectRatio: 1.35,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: trimmedUrl.isEmpty
            ? _ImagePlaceholder(number: number, name: name)
            : Image.network(
                trimmedUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return _ImagePlaceholder(number: number, name: name);
                },
              ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final String number;
  final String name;

  const _ImagePlaceholder({required this.number, required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 56,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.catalogImageNotAdded,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemHeaderCard extends StatelessWidget {
  final String collectionName;
  final String number;
  final String name;
  final String rarity;

  const _ItemHeaderCard({
    required this.collectionName,
    required this.number,
    required this.name,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedRarity = rarity.trim();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              collectionName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.tag, size: 18),
                  label: Text(number),
                ),
                if (trimmedRarity.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.diamond_outlined, size: 18),
                    label: Text(trimmedRarity),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnershipCard extends StatelessWidget {
  final int quantity;
  final int duplicateCount;

  const _OwnershipCard({required this.quantity, required this.duplicateCount});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final owned = quantity > 0;
    final statusColor = owned ? Colors.green : Colors.grey;
    final duplicateText = localizations.catalogOwnedSurplusCount(
      duplicateCount,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  owned ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: statusColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    owned
                        ? localizations.catalogItemOwned
                        : localizations.catalogItemMissing,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  localizations.catalogPiecesCount(quantity),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                const Icon(Icons.swap_horiz),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    duplicateText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  final int quantity;
  final bool isSaving;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const _QuantityCard({
    required this.quantity,
    required this.isSaving,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              localizations.catalogQuantity,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: localizations.catalogDecreaseQuantity,
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 88,
                  child: Center(
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                IconButton.filled(
                  tooltip: localizations.catalogIncreaseQuantity,
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
