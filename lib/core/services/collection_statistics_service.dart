import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/collection_statistics.dart';
import 'package:swapstash/core/services/user_item_service.dart';

class CollectionStatisticsService {
  final UserItemService _userItemService;

  CollectionStatisticsService({UserItemService? userItemService})
    : _userItemService = userItemService ?? UserItemService();

  Stream<CollectionStatistics> watchStatistics({
    required CatalogCollection collection,
  }) {
    return _userItemService
        .watchCollectionStats(collectionId: collection.id)
        .map(
          (stats) => CollectionStatistics(
            catalogCollectionId: collection.id,
            name: collection.name,
            publisher: collection.publisher,
            category: collection.category,
            year: collection.year.toString(),
            totalItems: collection.totalItems,
            ownedCount: stats.owned,
            duplicateCount: stats.duplicates,
            totalQuantity: stats.totalQuantity,
          ),
        );
  }
}
