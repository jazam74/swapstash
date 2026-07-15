class CollectionStats {
  final int owned;
  final int duplicates;
  final int totalQuantity;

  const CollectionStats({
    required this.owned,
    required this.duplicates,
    required this.totalQuantity,
  });

  int missing(int totalItems) => totalItems - owned;

  double progress(int totalItems) =>
      totalItems == 0 ? 0 : owned / totalItems;
}