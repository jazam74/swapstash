import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String country;
  final String language;
  final bool allowInternationalTrades;
  final double rating;
  final int completedTrades;
  final Timestamp createdAt;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.country,
    required this.language,
    required this.allowInternationalTrades,
    required this.rating,
    required this.completedTrades,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'country': country,
      'language': language,
      'allowInternationalTrades': allowInternationalTrades,
      'rating': rating,
      'completedTrades': completedTrades,
      'createdAt': createdAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      country: map['country'] ?? 'SI',
      language: map['language'] ?? 'sl',
      allowInternationalTrades:
          map['allowInternationalTrades'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
      completedTrades: map['completedTrades'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}