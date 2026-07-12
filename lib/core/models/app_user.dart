class AppUser {
  final String uid;
  final String email;
  final String displayName;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  factory AppUser.fromMap(
    String uid,
    Map<String, dynamic> map,
  ) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }
}