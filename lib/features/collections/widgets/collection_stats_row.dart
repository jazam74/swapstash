import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';

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
    return Row(
      children: [
        Expanded(
          child: _CollectionStat(
            icon: Icons.swap_horiz,
            label: 'Viški',
            value: duplicateCount,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _CollectionStat(
            icon: Icons.remove_circle_outline,
            label: 'Manjka',
            value: missingCount,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _CollectionStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _CollectionStat({
    required this.icon,
    required this.label,
    required this.value,
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
            '$value $label',
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
