import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/shared/widgets/app_card.dart';

class DashboardRecentCollectionsCard extends StatelessWidget {
  final List<Collection> collections;

  const DashboardRecentCollectionsCard({super.key, required this.collections});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          for (var index = 0; index < collections.length; index++) ...[
            _CollectionRow(collection: collections[index]),
            if (index < collections.length - 1)
              const Divider(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  final Collection collection;

  const _CollectionRow({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.collections_bookmark_outlined, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(collection.name, style: AppTextStyles.subtitle),
            ),
            Text(
              '${collection.completionPercent} %',
              style: AppTextStyles.body,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: collection.completion,
            minHeight: 7,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${collection.ownedCount} / ${collection.totalItems}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
