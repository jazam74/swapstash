import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class CollectionProgress extends StatelessWidget {
  final double progress;
  final int ownedCount;
  final int totalCount;
  final Color color;
  final bool compact;

  const CollectionProgress({
    super.key,
    required this.progress,
    required this.ownedCount,
    required this.totalCount,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final double safeProgress = progress < 0.0
        ? 0.0
        : (progress > 1.0 ? 1.0 : progress);
    final percent = (safeProgress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: safeProgress,
                  minHeight: compact ? 7 : 9,
                  backgroundColor: color.withValues(alpha: 0.12),
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$percent %',
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          localizations.myCollectionsProgressCount(ownedCount, totalCount),
          style: compact ? AppTextStyles.caption : AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
