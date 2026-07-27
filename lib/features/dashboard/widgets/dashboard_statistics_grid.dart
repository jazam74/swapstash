import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';
import 'package:swapstash/shared/widgets/app_card.dart';

class DashboardStatisticsGrid extends StatelessWidget {
  final int collectionCount;
  final int ownedCount;
  final int duplicateCount;
  final int missingCount;
  final VoidCallback? onCollectionsTap;

  const DashboardStatisticsGrid({
    super.key,
    required this.collectionCount,
    required this.ownedCount,
    required this.duplicateCount,
    required this.missingCount,
    this.onCollectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final items = [
      _StatisticData(
        icon: Icons.collections_bookmark,
        label: localizations.collections,
        value: collectionCount,
        color: AppColors.primary,
        onTap: onCollectionsTap,
      ),
      _StatisticData(
        icon: Icons.check_circle_outline,
        label: localizations.dashboardCollected,
        value: ownedCount,
        color: AppColors.success,
      ),
      _StatisticData(
        icon: Icons.swap_horiz,
        label: localizations.dashboardDuplicates,
        value: duplicateCount,
        color: AppColors.warning,
      ),
      _StatisticData(
        icon: Icons.remove_circle_outline,
        label: localizations.dashboardMissing,
        value: missingCount,
        color: AppColors.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompactDesktopLayout = constraints.maxWidth >= 560;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: useCompactDesktopLayout ? 4 : 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: useCompactDesktopLayout ? 1.45 : 1.25,
          ),
          itemBuilder: (context, index) {
            return _StatisticCard(
              data: items[index],
              compact: useCompactDesktopLayout,
            );
          },
        );
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final _StatisticData data;
  final bool compact;

  const _StatisticCard({
    required this.data,
    required this.compact,
  });

  Widget _buildIcon({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Icon(
        data.icon,
        color: data.color,
        size: compact ? 20 : 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: data.onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: compact
          ? Row(
              children: [
                _buildIcon(size: 36),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(size: 38),
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
  final VoidCallback? onTap;

  const _StatisticData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });
}
