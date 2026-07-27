import 'package:flutter/material.dart';
import 'package:swapstash/core/localization/catalog_category_localizer.dart';
import 'package:swapstash/core/models/collection_statistics.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/features/collections/models/collection_card_data.dart';
import 'package:swapstash/features/collections/widgets/collection_card.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context)!;

    if (currentCollection == null) {
      return AppCard(
        onTap: onTap,
        child: AppEmptyState(
          icon: Icons.collections_bookmark_outlined,
          title: localizations.dashboardNoCollectionsTitle,
          description: localizations.dashboardNoCollectionsDescription,
        ),
      );
    }

    return CollectionCard(
      data: CollectionCardData(
        title: currentCollection.name,
        subtitle:
            '${currentCollection.publisher} • '
            '${localizedCatalogCategory(localizations, currentCollection.category)} • '
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
