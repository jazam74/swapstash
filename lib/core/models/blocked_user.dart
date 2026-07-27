import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUser {
  final String userId;
  final Timestamp createdAt;

  const BlockedUser({required this.userId, required this.createdAt});

  factory BlockedUser.fromMap(String documentId, Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];

    return BlockedUser(
      userId: map['blockedUserId']?.toString().trim().isNotEmpty == true
          ? map['blockedUserId'].toString().trim()
          : documentId,
      createdAt: createdAtValue is Timestamp ? createdAtValue : Timestamp.now(),
    );
  }
}
