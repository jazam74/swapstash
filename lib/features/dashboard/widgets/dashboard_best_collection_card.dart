import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection_statistics.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/features/collections/models/collection_card_data.dart';
import 'package:swapstash/features/collections/widgets/collection_card.dart';
import 'package:swapstash/shared/widgets/app_card.dart';
import 'package:swapstash/shared/widgets/app_empty_state.dart';

class DashboardBestCollectionCard extends StatelessWidget {
  final CollectionStatistics? collection;
  final VoidCallback? onTap;

  const DashboardBestCollectionCard({
    super.key,
    required this.collection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentCollection = collection;

    if (currentCollection == null) {
      return AppCard(
        onTap: onTap,
        child: const AppEmptyState(
          icon: Icons.collections_bookmark_outlined,
          title: 'Še nimaš nobene zbirke',
          description: 'Odpri zavihek Zbirke in dodaj svojo prvo zbirko.',
        ),
      );
    }

    return CollectionCard(
      data: CollectionCardData(
        title: currentCollection.name,
        subtitle:
            '${currentCollection.publisher} • '
            '${currentCollection.category} • '
            '${currentCollection.year}',
        ownedCount: currentCollection.ownedCount,
        totalCount: currentCollection.totalItems,
        duplicateCount: currentCollection.duplicateCount,
        missingCount: currentCollection.missingCount,
      ),
      accentColor: AppColors.warning,
      onTap: onTap,
    );
  }
}
