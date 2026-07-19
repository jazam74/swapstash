import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/favorite_item.dart';

class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _favoritesReference {
    return _db.collection('users').doc(_currentUserId).collection('favorites');
  }

  String _normalizeRequiredId(String value, {required String fieldName}) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError('$fieldName ne sme biti prazen.');
    }

    return normalizedValue;
  }

  String _favoriteDocumentId({
    required String collectionId,
    required String itemId,
  }) {
    final normalizedCollectionId = _normalizeRequiredId(
      collectionId,
      fieldName: 'ID zbirke',
    );

    final normalizedItemId = _normalizeRequiredId(
      itemId,
      fieldName: 'ID predmeta',
    );

    final value = jsonEncode({
      'collectionId': normalizedCollectionId,
      'itemId': normalizedItemId,
    });

    return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
  }

  DocumentReference<Map<String, dynamic>> _favoriteReference({
    required String collectionId,
    required String itemId,
  }) {
    final documentId = _favoriteDocumentId(
      collectionId: collectionId,
      itemId: itemId,
    );

    return _favoritesReference.doc(documentId);
  }

  Stream<bool> watchIsFavorite({
    required String collectionId,
    required String itemId,
  }) {
    return _favoriteReference(
      collectionId: collectionId,
      itemId: itemId,
    ).snapshots().map((document) {
      return document.exists;
    });
  }

  Future<bool> isFavorite({
    required String collectionId,
    required String itemId,
  }) async {
    final document = await _favoriteReference(
      collectionId: collectionId,
      itemId: itemId,
    ).get();

    return document.exists;
  }

  Future<void> addFavorite({
    required FavoriteItem favorite,
  }) async {
    final normalizedCollectionId = _normalizeRequiredId(
      favorite.collectionId,
      fieldName: 'ID zbirke',
    );

    final normalizedItemId = _normalizeRequiredId(
      favorite.itemId,
      fieldName: 'ID predmeta',
    );

    await _favoriteReference(
      collectionId: normalizedCollectionId,
      itemId: normalizedItemId,
    ).set({
      'collectionId': normalizedCollectionId,
      'itemId': normalizedItemId,
      'number': favorite.number.trim(),
      'name': favorite.name.trim(),
      'imageUrl': favorite.imageUrl.trim(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite({
    required String collectionId,
    required String itemId,
  }) async {
    await _favoriteReference(
      collectionId: collectionId,
      itemId: itemId,
    ).delete();
  }

  Future<bool> toggleFavorite({
    required FavoriteItem favorite,
  }) async {
    final normalizedCollectionId = _normalizeRequiredId(
      favorite.collectionId,
      fieldName: 'ID zbirke',
    );

    final normalizedItemId = _normalizeRequiredId(
      favorite.itemId,
      fieldName: 'ID predmeta',
    );

    final reference = _favoriteReference(
      collectionId: normalizedCollectionId,
      itemId: normalizedItemId,
    );

    return _db.runTransaction<bool>((transaction) async {
      final document = await transaction.get(reference);

      if (document.exists) {
        transaction.delete(reference);
        return false;
      }

      transaction.set(reference, {
        'collectionId': normalizedCollectionId,
        'itemId': normalizedItemId,
        'number': favorite.number.trim(),
        'name': favorite.name.trim(),
        'imageUrl': favorite.imageUrl.trim(),
        'addedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  Stream<List<FavoriteItem>> watchFavorites() {
    return _favoritesReference
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(FavoriteItem.fromFirestore).toList();
        });
  }
}
