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

  factory UserProfile.fromMap(
    Map<String, dynamic> map,
  ) {
    final createdAtValue = map['createdAt'];

    return UserProfile(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      country: map['country'] as String? ?? 'SI',
      language: map['language'] as String? ?? 'sl',
      allowInternationalTrades:
          map['allowInternationalTrades'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      completedTrades:
          (map['completedTrades'] as num?)?.toInt() ?? 0,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue
          : Timestamp.now(),
    );
  }

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

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? country,
    String? language,
    bool? allowInternationalTrades,
    double? rating,
    int? completedTrades,
    Timestamp? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      country: country ?? this.country,
      language: language ?? this.language,
      allowInternationalTrades:
          allowInternationalTrades ?? this.allowInternationalTrades,
      rating: rating ?? this.rating,
      completedTrades: completedTrades ?? this.completedTrades,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}