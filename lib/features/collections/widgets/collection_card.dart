import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/features/collections/models/collection_card_data.dart';
import 'package:swapstash/features/collections/widgets/collection_popup_menu.dart';
import 'package:swapstash/features/collections/widgets/collection_progress.dart';
import 'package:swapstash/features/collections/widgets/collection_stats_row.dart';
import 'package:swapstash/shared/widgets/app_card.dart';

class CollectionCard extends StatelessWidget {
  final CollectionCardData data;
  final VoidCallback? onTap;
  final ValueChanged<CollectionMenuAction>? onMenuSelected;
  final bool compact;
  final bool showMenu;
  final bool allowEdit;
  final Color accentColor;

  const CollectionCard({
    super.key,
    required this.data,
    this.onTap,
    this.onMenuSelected,
    this.compact = false,
    this.showMenu = false,
    this.allowEdit = false,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CollectionIcon(
                title: data.title,
                accentColor: accentColor,
                compact: compact,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title.trim().isEmpty
                          ? 'Neimenovana zbirka'
                          : data.title,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: compact
                          ? AppTextStyles.subtitle
                          : AppTextStyles.title,
                    ),
                    if (data.subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ],
                ),
              ),
              if (showMenu && onMenuSelected != null)
                CollectionPopupMenu(
                  allowEdit: allowEdit,
                  onSelected: onMenuSelected!,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CollectionProgress(
            progress: data.progress,
            ownedCount: data.ownedCount,
            totalCount: data.totalCount,
            color: accentColor,
            compact: compact,
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.md),
            CollectionStatsRow(
              duplicateCount: data.duplicateCount,
              missingCount: data.missingCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _CollectionIcon extends StatelessWidget {
  final String title;
  final Color accentColor;
  final bool compact;

  const _CollectionIcon({
    required this.title,
    required this.accentColor,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedTitle = title.trim();
    final initial = trimmedTitle.isEmpty
        ? '?'
        : trimmedTitle.characters.first.toUpperCase();

    final size = compact ? 42.0 : 50.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.titleLarge.copyWith(color: accentColor),
      ),
    );
  }
}
