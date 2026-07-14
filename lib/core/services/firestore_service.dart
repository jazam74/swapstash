import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/user_collection.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users {
    return _db.collection('users');
  }

  Future<void> createUserProfile(
    UserProfile user,
  ) async {
    await _users.doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<UserProfile?> getUserProfile(
    String uid,
  ) async {
    final document = await _users.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return UserProfile.fromMap({
      ...data,
      'uid': document.id,
    });
  }

  Stream<UserProfile?> watchUserProfile(
    String uid,
  ) {
    return _users.doc(uid).snapshots().map(
      (document) {
        final data = document.data();

        if (!document.exists || data == null) {
          return null;
        }

        return UserProfile.fromMap({
          ...data,
          'uid': document.id,
        });
      },
    );
  }

  Future<void> updateUserProfile(
    UserProfile user,
  ) async {
    await _users.doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }
  Future<List<UserProfile>> searchUsers(
    String query,
  ) async {
    final value = query.trim();

    if (value.isEmpty) {
      return [];
    }

    final snapshot = await _users
        .orderBy('displayName')
        .startAt([value])
        .endAt(['$value\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => UserProfile.fromMap({
              ...doc.data(),
              'uid': doc.id,
            }))
        .toList();
  }
  Future<void> addCollectionToUser(
    UserCollection collection,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('collections')
        .doc(collection.catalogCollectionId)
        .set(collection.toMap());
  }
}