import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/user_collection.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/block_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BlockService _blockService = BlockService();

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> createUserProfile(UserProfile user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final document = await _users.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return UserProfile.fromMap({...data, 'uid': document.id});
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((document) {
      final data = document.data();

      if (!document.exists || data == null) {
        return null;
      }

      return UserProfile.fromMap({...data, 'uid': document.id});
    });
  }

  Stream<UserProfile?> watchCurrentUserProfile() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream<UserProfile?>.value(null);
    }

    return watchUserProfile(user.uid);
  }

  Future<void> updateUserProfile(UserProfile user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateCurrentUserProfile(UserProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    if (profile.uid != user.uid) {
      throw Exception('Cannot update another user profile.');
    }

    await updateUserProfile(profile);
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Za MVP preberemo omejeno število profilov in filtriramo lokalno.
    // Tako iskanje ni občutljivo na velike/male črke in ne zahteva
    // migracije obstoječih profilov ali dodatnega Firestore indeksa.
    final snapshot = await _users.limit(200).get();

    final results = snapshot.docs
        .where((document) => document.id != currentUserId)
        .map(
          (document) =>
              UserProfile.fromMap({...document.data(), 'uid': document.id}),
        )
        .where((profile) => profile.isPublic)
        .where(
          (profile) => profile.displayName.trim().toLowerCase().contains(
            normalizedQuery,
          ),
        )
        .toList();

    results.sort((first, second) {
      final firstName = first.displayName.trim().toLowerCase();
      final secondName = second.displayName.trim().toLowerCase();

      final firstStarts = firstName.startsWith(normalizedQuery);
      final secondStarts = secondName.startsWith(normalizedQuery);

      if (firstStarts != secondStarts) {
        return firstStarts ? -1 : 1;
      }

      return firstName.compareTo(secondName);
    });

    final preliminaryResults = results.take(40).toList(growable: false);
    final allowedUserIds = await _blockService.filterAllowedUserIds(
      preliminaryResults.map((profile) => profile.uid),
    );

    return preliminaryResults
        .where((profile) => allowedUserIds.contains(profile.uid))
        .take(20)
        .toList(growable: false);
  }

  Future<void> addCollectionToUser(UserCollection collection) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    await _users
        .doc(user.uid)
        .collection('collections')
        .doc(collection.catalogCollectionId)
        .set(collection.toMap());
  }

  Future<void> saveNotificationToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      return;
    }

    await _users.doc(user.uid).set({
      'notificationTokens': FieldValue.arrayUnion([normalizedToken]),
      'notificationTokensUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeNotificationToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      return;
    }

    await _users.doc(user.uid).update({
      'notificationTokens': FieldValue.arrayRemove([normalizedToken]),
      'notificationTokensUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}
