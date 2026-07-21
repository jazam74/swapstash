import 'package:swapstash/core/models/collection_statistics.dart';
import 'package:swapstash/features/dashboard/models/dashboard_action.dart';

class DashboardData {
  final List<CollectionStatistics> collections;
  final CollectionStatistics? bestCollection;
  final List<CollectionStatistics> recentCollections;
  final List<DashboardAction> actions;
  final int collectionCount;
  final int ownedCount;
  final int duplicateCount;
  final int missingCount;

  const DashboardData({
    required this.collections,
    required this.bestCollection,
    required this.recentCollections,
    required this.actions,
    required this.collectionCount,
    required this.ownedCount,
    required this.duplicateCount,
    required this.missingCount,
  });

  factory DashboardData.fromStatistics(
    List<CollectionStatistics> collections, {
    List<DashboardAction> actions = const [],
  }) {
    CollectionStatistics? bestCollection;

    if (collections.isNotEmpty) {
      bestCollection = collections.reduce((first, second) {
        return second.completion > first.completion ? second : first;
      });
    }

    return DashboardData(
      collections: List<CollectionStatistics>.unmodifiable(collections),
      bestCollection: bestCollection,
      recentCollections: List<CollectionStatistics>.unmodifiable(
        collections.take(3),
      ),
      actions: List<DashboardAction>.unmodifiable(actions),
      collectionCount: collections.length,
      ownedCount: collections.fold<int>(
        0,
        (sum, collection) => sum + collection.ownedCount,
      ),
      duplicateCount: collections.fold<int>(
        0,
        (sum, collection) => sum + collection.duplicateCount,
      ),
      missingCount: collections.fold<int>(
        0,
        (sum, collection) => sum + collection.missingCount,
      ),
    );
  }

  factory DashboardData.empty() {
    return DashboardData.fromStatistics(const []);
  }
}
