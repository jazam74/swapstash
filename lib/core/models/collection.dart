class Collection {
  final String id;
  final String name;
  final String publisher;
  final int totalItems;
  final int ownedCount;
  final int duplicateCount;

  const Collection({
    required this.id,
    required this.name,
    required this.publisher,
    required this.totalItems,
    this.ownedCount = 0,
    this.duplicateCount = 0,
  });

  factory Collection.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final stats = map['stats'];

    return Collection(
      id: id,
      name: map['name'] as String? ?? '',
      publisher: map['publisher'] as String? ?? '',
      totalItems: map['totalItems'] as int? ?? 0,
      ownedCount: stats is Map
          ? stats['ownedCount'] as int? ?? 0
          : 0,
      duplicateCount: stats is Map
          ? stats['duplicateCount'] as int? ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'publisher': publisher,
      'totalItems': totalItems,
      'stats': {
        'ownedCount': ownedCount,
        'duplicateCount': duplicateCount,
      },
    };
  }

  int get missingCount {
    final missing = totalItems - ownedCount;
    return missing < 0 ? 0 : missing;
  }

  double get completion {
    if (totalItems <= 0) {
      return 0;
    }

    return (ownedCount / totalItems).clamp(0.0, 1.0);
  }

  int get completionPercent {
    return (completion * 100).round();
  }

  Collection copyWith({
    String? id,
    String? name,
    String? publisher,
    int? totalItems,
    int? ownedCount,
    int? duplicateCount,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      publisher: publisher ?? this.publisher,
      totalItems: totalItems ?? this.totalItems,
      ownedCount: ownedCount ?? this.ownedCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
    );
  }
}