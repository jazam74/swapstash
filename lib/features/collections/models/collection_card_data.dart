class CollectionCardData {
  final String title;
  final String subtitle;
  final int ownedCount;
  final int totalCount;
  final int duplicateCount;
  final int missingCount;

  const CollectionCardData({
    required this.title,
    required this.subtitle,
    required this.ownedCount,
    required this.totalCount,
    required this.duplicateCount,
    required this.missingCount,
  });

  double get progress {
    if (totalCount <= 0) return 0;
    return (ownedCount / totalCount).clamp(0, 1);
  }

  int get progressPercent => (progress * 100).round();
}
