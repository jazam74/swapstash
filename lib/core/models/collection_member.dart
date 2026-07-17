import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionMember {
  final String uid;

  final String displayName;
  final String photoUrl;

  final String country;
  final String city;

  final bool isPublic;
  final bool allowInternationalTrades;

  final int ownedCount;
  final int duplicateCount;

  final Timestamp lastUpdated;

  const CollectionMember({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.country,
    required this.city,
    required this.isPublic,
    required this.allowInternationalTrades,
    required this.ownedCount,
    required this.duplicateCount,
    required this.lastUpdated,
  });

  factory CollectionMember.fromMap(
    Map<String, dynamic> map,
  ) {
    return CollectionMember(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      isPublic: map['isPublic'] ?? true,
      allowInternationalTrades:
          map['allowInternationalTrades'] ?? false,
      ownedCount: map['ownedCount'] ?? 0,
      duplicateCount: map['duplicateCount'] ?? 0,
      lastUpdated:
          map['lastUpdated'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'country': country,
      'city': city,
      'isPublic': isPublic,
      'allowInternationalTrades':
          allowInternationalTrades,
      'ownedCount': ownedCount,
      'duplicateCount': duplicateCount,
      'lastUpdated': lastUpdated,
    };
  }
}