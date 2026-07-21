class CollectionStatistics {
  final String catalogCollectionId;
  final String name;
  final String publisher;
  final String category;
  final String year;
  final int totalItems;
  final int ownedCount;
  final int duplicateCount;
  final int totalQuantity;

  const CollectionStatistics({
    required this.catalogCollectionId,
    required this.name,
    required this.publisher,
    required this.category,
    required this.year,
    required this.totalItems,
    required this.ownedCount,
    required this.duplicateCount,
    required this.totalQuantity,
  });

  int get missingCount {
    final missing = totalItems - ownedCount;
    return missing > 0 ? missing : 0;
  }

  double get completion {
    if (totalItems <= 0) {
      return 0;
    }

    return (ownedCount / totalItems).clamp(0.0, 1.0);
  }

  int get completionPercent => (completion * 100).round();
}
