import 'package:swapstash/core/models/collection.dart';
import 'package:swapstash/features/dashboard/models/dashboard_action.dart';

class DashboardData {
  final List<Collection> collections;
  final Collection? bestCollection;
  final List<Collection> recentCollections;
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

  factory DashboardData.fromCollections(
    List<Collection> collections, {
    List<DashboardAction> actions = const [],
  }) {
    final ownedCount = collections.fold<int>(
      0,
      (sum, collection) => sum + collection.ownedCount,
    );

    final duplicateCount = collections.fold<int>(
      0,
      (sum, collection) => sum + collection.duplicateCount,
    );

    final missingCount = collections.fold<int>(
      0,
      (sum, collection) => sum + collection.missingCount,
    );

    Collection? bestCollection;

    if (collections.isNotEmpty) {
      bestCollection = collections.reduce((first, second) {
        return second.completion > first.completion ? second : first;
      });
    }

    return DashboardData(
      collections: List<Collection>.unmodifiable(collections),
      bestCollection: bestCollection,
      recentCollections: List<Collection>.unmodifiable(collections.take(3)),
      actions: List<DashboardAction>.unmodifiable(actions),
      collectionCount: collections.length,
      ownedCount: ownedCount,
      duplicateCount: duplicateCount,
      missingCount: missingCount,
    );
  }
}
