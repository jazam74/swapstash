class UserProfile {
  final String uid;
  final String email;
  final String displayName;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  factory UserProfile.fromMap(
    String uid,
    Map<String, dynamic> map,
  ) {
    return UserProfile(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName:
          map['displayName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName:
          displayName ?? this.displayName,
    );
  }
}