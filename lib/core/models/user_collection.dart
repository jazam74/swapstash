import 'package:cloud_firestore/cloud_firestore.dart';

class UserCollection {
  final String catalogCollectionId;
  final Timestamp createdAt;

  const UserCollection({
    required this.catalogCollectionId,
    required this.createdAt,
  });

  factory UserCollection.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserCollection(
      catalogCollectionId:
          map['catalogCollectionId'] as String? ?? '',
      createdAt:
          map['createdAt'] as Timestamp? ??
              Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'catalogCollectionId': catalogCollectionId,
      'createdAt': createdAt,
    };
  }
}