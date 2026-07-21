import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection_statistics.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/features/collections/models/collection_card_data.dart';
import 'package:swapstash/features/collections/widgets/collection_card.dart';

class DashboardRecentCollectionsCard extends StatelessWidget {
  final List<CollectionStatistics> collections;
  final ValueChanged<CollectionStatistics>? onCollectionTap;

  const DashboardRecentCollectionsCard({
    super.key,
    required this.collections,
    this.onCollectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < collections.length; index++) ...[
          CollectionCard(
            data: CollectionCardData(
              title: collections[index].name,
              subtitle:
                  '${collections[index].publisher} • '
                  '${collections[index].category} • '
                  '${collections[index].year}',
              ownedCount: collections[index].ownedCount,
              totalCount: collections[index].totalItems,
              duplicateCount: collections[index].duplicateCount,
              missingCount: collections[index].missingCount,
            ),
            compact: true,
            onTap: onCollectionTap == null
                ? null
                : () => onCollectionTap!(collections[index]),
          ),
          if (index < collections.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
