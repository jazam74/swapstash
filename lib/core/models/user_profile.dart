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

  final String city;
  final String bio;
  final String photoUrl;
  final bool isPublic;

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
    this.city = '',
    this.bio = '',
    this.photoUrl = '',
    this.isPublic = true,
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
      city: map['city'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      isPublic: map['isPublic'] as bool? ?? true,
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
      'city': city,
      'bio': bio,
      'photoUrl': photoUrl,
      'isPublic': isPublic,
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
    String? city,
    String? bio,
    String? photoUrl,
    bool? isPublic,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      country: country ?? this.country,
      language: language ?? this.language,
      allowInternationalTrades:
          allowInternationalTrades ??
              this.allowInternationalTrades,
      rating: rating ?? this.rating,
      completedTrades:
          completedTrades ?? this.completedTrades,
      createdAt: createdAt ?? this.createdAt,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}