class CatalogItem {
  final String id;
  final String collectionId;
  final String number;
  final String name;
  final String imageUrl;

  const CatalogItem({
    required this.id,
    required this.collectionId,
    required this.number,
    required this.name,
    required this.imageUrl,
  });

  factory CatalogItem.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CatalogItem(
      id: id,
      collectionId: map['collectionId'] ?? '',
      number: map['number'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'number': number,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}