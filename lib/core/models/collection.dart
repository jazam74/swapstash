class Collection {
  final String id;
  final String name;
  final String publisher;
  final int totalItems;

  const Collection({
    required this.id,
    required this.name,
    required this.publisher,
    required this.totalItems,
  });

  factory Collection.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Collection(
      id: id,
      name: map['name'] as String? ?? '',
      publisher: map['publisher'] as String? ?? '',
      totalItems: map['totalItems'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'publisher': publisher,
      'totalItems': totalItems,
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    String? publisher,
    int? totalItems,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      publisher: publisher ?? this.publisher,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}