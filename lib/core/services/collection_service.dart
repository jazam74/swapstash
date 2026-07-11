import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addCollection({
    required String name,
    required String publisher,
    required int totalItems,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('collections')
        .add({
      'name': name,
      'publisher': publisher,
      'totalItems': totalItems,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollections() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('collections')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}