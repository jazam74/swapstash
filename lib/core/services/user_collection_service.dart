import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/user_collection.dart';

class UserCollectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>>
      get _userCollections {
    return _db
        .collection('users')
        .doc(_currentUserId)
        .collection('collections');
  }

  Future<void> addCollection(
    String catalogCollectionId,
  ) async {
    final id = catalogCollectionId.trim();

    if (id.isEmpty) {
      throw ArgumentError(
        'ID kataloške zbirke ne sme biti prazen.',
      );
    }

    final collection = UserCollection(
      catalogCollectionId: id,
      createdAt: Timestamp.now(),
    );

    await _userCollections.doc(id).set(
          collection.toMap(),
          SetOptions(merge: true),
        );
  }

  Stream<List<UserCollection>> watchCollections() {
    return _userCollections
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((document) {
            return UserCollection.fromMap({
              ...document.data(),
              'catalogCollectionId': document.id,
            });
          }).toList(),
        );
  }

  Future<bool> hasCollection(
    String catalogCollectionId,
  ) async {
    final id = catalogCollectionId.trim();

    if (id.isEmpty) {
      return false;
    }

    final document = await _userCollections.doc(id).get();

    return document.exists;
  }

  Future<void> removeCollection(
    String catalogCollectionId,
  ) async {
    final id = catalogCollectionId.trim();

    if (id.isEmpty) {
      throw ArgumentError(
        'ID kataloške zbirke ne sme biti prazen.',
      );
    }

    await _userCollections.doc(id).delete();
  }
}