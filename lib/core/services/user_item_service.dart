import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/core/models/collection_stats.dart';

class UserItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _itemsReference(
    String collectionId,
  ) {
    final id = collectionId.trim();

    if (id.isEmpty) {
      throw ArgumentError(
        'ID zbirke ne sme biti prazen.',
      );
    }

    return _db
        .collection('users')
        .doc(_currentUserId)
        .collection('collections')
        .doc(id)
        .collection('items');
  }

  Stream<UserItem?> watchItem({
    required String collectionId,
    required String itemId,
  }) {
    final id = itemId.trim();

    if (id.isEmpty) {
      return Stream<UserItem?>.value(null);
    }

    return _itemsReference(collectionId)
        .doc(id)
        .snapshots()
        .map((document) {
      final data = document.data();

      if (!document.exists || data == null) {
        return null;
      }

      return UserItem.fromMap(
        document.id,
        data,
      );
    });
  }

  Future<UserItem?> getItem({
    required String collectionId,
    required String itemId,
  }) async {
    final id = itemId.trim();

    if (id.isEmpty) {
      return null;
    }

    final document = await _itemsReference(
      collectionId,
    ).doc(id).get();

    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return UserItem.fromMap(
      document.id,
      data,
    );
  }

  Future<void> saveItem({
    required String collectionId,
    required String itemId,
    required int quantity,
  }) async {
    final id = itemId.trim();

    if (id.isEmpty) {
      throw ArgumentError(
        'ID predmeta ne sme biti prazen.',
      );
    }

    if (quantity < 0) {
      throw ArgumentError(
        'Količina ne sme biti negativna.',
      );
    }

    final userItem = UserItem(
      itemId: id,
      quantity: quantity,
      updatedAt: Timestamp.now(),
    );

    if (quantity == 0) {
      await _itemsReference(
        collectionId,
      ).doc(id).delete();

      return;
    }

    await _itemsReference(collectionId).doc(id).set(
          userItem.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> markAsOwned({
    required String collectionId,
    required String itemId,
  }) {
    return saveItem(
      collectionId: collectionId,
      itemId: itemId,
      quantity: 1,
    );
  }

  Stream<int> watchOwnedItemCount({
    required String collectionId,
  }) {
    return _itemsReference(collectionId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAsMissing({
    required String collectionId,
    required String itemId,
  }) {
    return saveItem(
      collectionId: collectionId,
      itemId: itemId,
      quantity: 0,
    );
  }
  Stream<Map<String, UserItem>> watchItemsMap({
    required String collectionId,
  }) {
    return _itemsReference(collectionId)
        .snapshots()
        .map((snapshot) {
      return {
        for (final document in snapshot.docs)
          document.id: UserItem.fromMap(
            document.id,
            document.data(),
          ),
      };
    });
  }
  Stream<CollectionStats> watchCollectionStats({
    required String collectionId,
  }) {
    return _itemsReference(collectionId)
        .snapshots()
        .map((snapshot) {
      int owned = 0;
      int duplicates = 0;
      int totalQuantity = 0;

      for (final doc in snapshot.docs) {
        final item = UserItem.fromMap(
          doc.id,
          doc.data(),
        );

        if (item.quantity > 0) {
        owned++;
        }

        totalQuantity += item.quantity;

        if (item.quantity > 1) {
          duplicates += item.duplicateCount;
        }
      }

      return CollectionStats(
        owned: owned,
        duplicates: duplicates,
        totalQuantity: totalQuantity,
      );
    });
  }
}