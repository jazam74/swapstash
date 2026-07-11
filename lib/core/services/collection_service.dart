import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/collection.dart';

class CollectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _collectionsReference() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('collections');
  }

  Future<void> addCollection({
    required String name,
    required String publisher,
    required int totalItems,
  }) async {
    final trimmedName = name.trim();
    final trimmedPublisher = publisher.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Ime zbirke ne sme biti prazno.');
    }

    if (trimmedPublisher.isEmpty) {
      throw ArgumentError('Založnik ne sme biti prazen.');
    }

    if (totalItems <= 0) {
      throw ArgumentError(
        'Število predmetov mora biti večje od 0.',
      );
    }

    await _collectionsReference().add({
      'name': trimmedName,
      'publisher': trimmedPublisher,
      'totalItems': totalItems,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCollection({
    required String collectionId,
    required String name,
    required String publisher,
    required int totalItems,
  }) async {
    final trimmedName = name.trim();
    final trimmedPublisher = publisher.trim();

    if (collectionId.trim().isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    if (trimmedName.isEmpty) {
      throw ArgumentError('Ime zbirke ne sme biti prazno.');
    }

    if (trimmedPublisher.isEmpty) {
      throw ArgumentError('Založnik ne sme biti prazen.');
    }

    if (totalItems <= 0) {
      throw ArgumentError(
        'Število predmetov mora biti večje od 0.',
      );
    }

    await _collectionsReference().doc(collectionId).update({
      'name': trimmedName,
      'publisher': trimmedPublisher,
      'totalItems': totalItems,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCollection({
    required String collectionId,
  }) async {
    if (collectionId.trim().isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    final collectionDocument =
        _collectionsReference().doc(collectionId);

    final itemsReference =
        collectionDocument.collection('items');

    // Predmete brišemo v manjših paketih.
    while (true) {
      final snapshot = await itemsReference.limit(400).get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = _db.batch();

      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
    }

    await collectionDocument.delete();
  }

  Stream<List<Collection>> watchCollections() {
    return _collectionsReference()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return Collection.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }
}