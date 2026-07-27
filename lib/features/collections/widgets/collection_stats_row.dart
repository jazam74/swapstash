import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class CollectionStatsRow extends StatelessWidget {
  final int duplicateCount;
  final int missingCount;

  const CollectionStatsRow({
    super.key,
    required this.duplicateCount,
    required this.missingCount,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _CollectionStat(
            icon: Icons.swap_horiz,
            text: localizations.myCollectionsDuplicateCount(duplicateCount),
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _CollectionStat(
            icon: Icons.remove_circle_outline,
            text: localizations.myCollectionsMissingCount(missingCount),
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _CollectionStat extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _CollectionStat({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
