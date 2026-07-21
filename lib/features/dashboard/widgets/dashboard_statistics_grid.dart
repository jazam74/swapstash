import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/shared/widgets/app_card.dart';

class DashboardStatisticsGrid extends StatelessWidget {
  final int collectionCount;
  final int ownedCount;
  final int duplicateCount;
  final int missingCount;

  const DashboardStatisticsGrid({
    super.key,
    required this.collectionCount,
    required this.ownedCount,
    required this.duplicateCount,
    required this.missingCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatisticData(
        icon: Icons.collections_bookmark,
        label: 'Zbirke',
        value: collectionCount,
        color: AppColors.primary,
      ),
      _StatisticData(
        icon: Icons.check_circle_outline,
        label: 'Zbranih',
        value: ownedCount,
        color: AppColors.success,
      ),
      _StatisticData(
        icon: Icons.swap_horiz,
        label: 'Viški',
        value: duplicateCount,
        color: AppColors.warning,
      ),
      _StatisticData(
        icon: Icons.remove_circle_outline,
        label: 'Manjka',
        value: missingCount,
        color: AppColors.error,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        return _StatisticCard(data: items[index]);
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final _StatisticData data;

  const _StatisticCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${data.value}', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _StatisticData {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatisticData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
