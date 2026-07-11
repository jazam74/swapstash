import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile(UserProfile user) async {
    await _db
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return UserProfile.fromMap(doc.data()!);
  }

  Future<void> updateUserProfile(UserProfile user) async {
    await _db
        .collection('users')
        .doc(user.uid)
        .update(user.toMap());
  }
}