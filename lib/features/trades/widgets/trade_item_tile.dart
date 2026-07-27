import 'package:flutter/material.dart';
import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/trade_item.dart';
import 'package:swapstash/core/services/catalog_service.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class TradeItemTile extends StatelessWidget {
  static final CatalogService _catalogService = CatalogService();

  static final Map<String, Future<CatalogCollection?>> _collectionFutureById =
      {};

  final TradeItem item;
  final Color accentColor;

  const TradeItemTile({
    super.key,
    required this.item,
    required this.accentColor,
  });

  Future<CatalogCollection?> _loadCollection() {
    final collectionId = item.collectionId.trim();

    if (collectionId.isEmpty) {
      return Future<CatalogCollection?>.value(null);
    }

    return _collectionFutureById.putIfAbsent(
      collectionId,
      () => _catalogService.getCollection(collectionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.image_outlined, color: accentColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${item.itemNumber}', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                FutureBuilder<CatalogCollection?>(
                  future: _loadCollection(),
                  builder: (context, snapshot) {
                    final collectionName = snapshot.data?.name.trim() ?? '';

                    final text = collectionName.isEmpty
                        ? localizations.tradeCardFromCollection
                        : '${localizations.tradeCardFromCollection}: '
                              '$collectionName';

                    return Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    );
                  },
                ),
              ],
            ),
          ),
          if (item.quantity > 1)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '×${item.quantity}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
