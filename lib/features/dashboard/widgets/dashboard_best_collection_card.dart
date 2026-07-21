import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/shared/widgets/app_card.dart';
import 'package:swapstash/shared/widgets/app_empty_state.dart';

class DashboardBestCollectionCard extends StatelessWidget {
  final Collection? collection;

  const DashboardBestCollectionCard({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final currentCollection = collection;

    if (currentCollection == null) {
      return const AppCard(
        child: AppEmptyState(
          icon: Icons.collections_bookmark_outlined,
          title: 'Še nimaš nobene zbirke',
          description: 'Odpri zavihek Zbirke in dodaj svojo prvo zbirko.',
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(currentCollection.name, style: AppTextStyles.title),
              ),
              Text(
                '${currentCollection.completionPercent} %',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(currentCollection.publisher, style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: currentCollection.completion,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${currentCollection.ownedCount} od '
            '${currentCollection.totalItems} zbranih predmetov',
            style: AppTextStyles.body,
          ),
          if (currentCollection.duplicateCount > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${currentCollection.duplicateCount} viškov',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ],
      ),
    );
  }
}
