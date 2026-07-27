import 'package:flutter/material.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class ItemCard extends StatelessWidget {
  final String number;
  final String name;
  final String imageUrl;
  final String rarity;
  final int quantity;
  final bool quickEntryEnabled;
  final bool isSaving;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.number,
    this.name = '',
    this.imageUrl = '',
    this.rarity = '',
    required this.quantity,
    this.quickEntryEnabled = false,
    this.isSaving = false,
    this.onDecrease,
    this.onIncrease,
    this.onTap,
  });

  bool get _owned => quantity > 0;

  bool get _hasDuplicates => quantity > 1;

  String _quantityStatusLabel(AppLocalizations localizations) {
    if (!_owned) {
      return localizations.catalogNotOwned;
    }

    if (!_hasDuplicates) {
      return localizations.catalogOwned;
    }

    return localizations.catalogSurplusCount(quantity - 1);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final duplicateBackgroundColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFF3A2A16)
        : const Color(0xFFFFF3E0);

    final duplicateForegroundColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFFFFCC80)
        : const Color(0xFF8A4B08);

    final duplicateBorderColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFFD99A45)
        : const Color(0xFFE6A04B);

    final backgroundColor = _hasDuplicates
        ? duplicateBackgroundColor
        : _owned
        ? Colors.green.shade50
        : colorScheme.surfaceContainerLow;

    final foregroundColor = _hasDuplicates
        ? duplicateForegroundColor
        : _owned
        ? Colors.green.shade800
        : colorScheme.onSurfaceVariant;

    final borderColor = _hasDuplicates
        ? duplicateBorderColor
        : _owned
        ? Colors.green.shade300
        : colorScheme.outlineVariant;

    final trimmedName = name.trim();
    final trimmedImageUrl = imageUrl.trim();
    final trimmedRarity = rarity.trim();

    return Card(
      elevation: _hasDuplicates ? 2 : 1,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: _hasDuplicates ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: colorScheme.surfaceContainerHighest,
                      child: trimmedImageUrl.isEmpty
                          ? _ItemImagePlaceholder(
                              color: colorScheme.onSurfaceVariant,
                            )
                          : Image.network(
                              trimmedImageUrl,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.medium,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                }

                                final expectedBytes =
                                    progress.expectedTotalBytes;
                                final value = expectedBytes == null
                                    ? null
                                    : progress.cumulativeBytesLoaded /
                                          expectedBytes;

                                return Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: value,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return _ItemImagePlaceholder(
                                  color: colorScheme.onSurfaceVariant,
                                );
                              },
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                    child: Column(
                      children: [
                        Text(
                          number,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: foregroundColor,
                          ),
                        ),
                        if (trimmedName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            trimmedName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                              color: foregroundColor,
                            ),
                          ),
                        ],
                        if (trimmedRarity.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: double.infinity,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              trimmedRarity,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasDuplicates
                                  ? Icons.content_copy_rounded
                                  : _owned
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: foregroundColor,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _quantityStatusLabel(localizations),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: foregroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (quickEntryEnabled) ...[
            Divider(height: 1, thickness: 1, color: borderColor),
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CompactQuantityButton(
                    tooltip: localizations.catalogDecreaseQuantity,
                    icon: Icons.remove,
                    onPressed: isSaving || quantity <= 0 ? null : onDecrease,
                    filled: true,
                  ),
                  SizedBox(
                    width: 28,
                    child: Center(
                      child: isSaving
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              '$quantity',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: foregroundColor,
                              ),
                            ),
                    ),
                  ),
                  _CompactQuantityButton(
                    tooltip: localizations.catalogIncreaseQuantity,
                    icon: Icons.add,
                    onPressed: isSaving ? null : onIncrease,
                    filled: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemImagePlaceholder extends StatelessWidget {
  final Color color;

  const _ItemImagePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(Icons.photo_outlined, size: 34, color: color));
  }
}

class _CompactQuantityButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  const _CompactQuantityButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
    );

    if (!filled) {
      return button;
    }

    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
    );
  }
}
