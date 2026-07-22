import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteItem {
  final String collectionId;
  final String itemId;
  final String number;
  final String name;
  final String imageUrl;
  final DateTime? addedAt;

  const FavoriteItem({
    required this.collectionId,
    required this.itemId,
    required this.number,
    required this.name,
    required this.imageUrl,
    this.addedAt,
  });

  factory FavoriteItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return FavoriteItem(
      collectionId: data['collectionId'] as String,
      itemId: data['itemId'] as String,
      number: data['number'] as String? ?? '',
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'collectionId': collectionId,
      'itemId': itemId,
      'number': number,
      'name': name,
      'imageUrl': imageUrl,
      'addedAt': addedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(addedAt!),
    };
  }
}
