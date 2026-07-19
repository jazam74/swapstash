import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/collection_stats.dart';
import 'package:swapstash/core/models/user_item.dart';
import 'package:swapstash/core/services/collection_members_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';

class UserItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirestoreService _firestoreService = FirestoreService();
  final CollectionMembersService _collectionMembersService =
      CollectionMembersService();

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
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    return _db
        .collection('users')
        .doc(_currentUserId)
        .collection('collections')
        .doc(id)
        .collection('items');
  }

  Future<void> syncCollectionMember({required String collectionId}) async {
    final profile = await _firestoreService.getUserProfile(_currentUserId);

    if (profile == null) {
      return;
    }

    final ownedCount = await getOwnedItemCount(collectionId: collectionId);

    final duplicateCount = await getDuplicateItemCount(
      collectionId: collectionId,
    );

    await _collectionMembersService.syncMember(
      collectionId: collectionId,
      profile: profile,
      ownedCount: ownedCount,
      duplicateCount: duplicateCount,
    );
  }

  Stream<UserItem?> watchItem({
    required String collectionId,
    required String itemId,
  }) {
    final id = itemId.trim();

    if (id.isEmpty) {
      return Stream<UserItem?>.value(null);
    }

    return _itemsReference(collectionId).doc(id).snapshots().map((document) {
      final data = document.data();

      if (!document.exists || data == null) {
        return null;
      }

      return UserItem.fromMap(document.id, data);
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

    final document = await _itemsReference(collectionId).doc(id).get();

    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return UserItem.fromMap(document.id, data);
  }

  Future<void> saveItem({
    required String collectionId,
    required String itemId,
    required int quantity,
  }) async {
    final id = itemId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID predmeta ne sme biti prazen.');
    }

    if (quantity < 0) {
      throw ArgumentError('Količina ne sme biti negativna.');
    }

    if (quantity == 0) {
      await _itemsReference(collectionId).doc(id).delete();

      await syncCollectionMember(collectionId: collectionId);

      return;
    }

    final userItem = UserItem(
      itemId: id,
      quantity: quantity,
      updatedAt: Timestamp.now(),
    );

    await _itemsReference(
      collectionId,
    ).doc(id).set(userItem.toMap(), SetOptions(merge: true));

    await syncCollectionMember(collectionId: collectionId);
  }

  Future<void> markAsOwned({
    required String collectionId,
    required String itemId,
  }) {
    return saveItem(collectionId: collectionId, itemId: itemId, quantity: 1);
  }

  Future<void> markAsMissing({
    required String collectionId,
    required String itemId,
  }) {
    return saveItem(collectionId: collectionId, itemId: itemId, quantity: 0);
  }

  Stream<int> watchOwnedItemCount({required String collectionId}) {
    return _itemsReference(collectionId).snapshots().map((snapshot) {
      return snapshot.docs.where((document) {
        final item = UserItem.fromMap(document.id, document.data());

        return item.quantity > 0;
      }).length;
    });
  }

  Stream<Map<String, UserItem>> watchItemsMap({required String collectionId}) {
    return _itemsReference(collectionId).snapshots().map((snapshot) {
      return {
        for (final document in snapshot.docs)
          document.id: UserItem.fromMap(document.id, document.data()),
      };
    });
  }

  Stream<CollectionStats> watchCollectionStats({required String collectionId}) {
    return _itemsReference(collectionId).snapshots().map((snapshot) {
      int owned = 0;
      int duplicates = 0;
      int totalQuantity = 0;

      for (final document in snapshot.docs) {
        final item = UserItem.fromMap(document.id, document.data());

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

  Future<int> getOwnedItemCount({required String collectionId}) async {
    final snapshot = await _itemsReference(collectionId).get();

    int owned = 0;

    for (final document in snapshot.docs) {
      final item = UserItem.fromMap(document.id, document.data());

      if (item.quantity > 0) {
        owned++;
      }
    }

    return owned;
  }

  Future<int> getDuplicateItemCount({required String collectionId}) async {
    final snapshot = await _itemsReference(collectionId).get();

    int duplicates = 0;

    for (final document in snapshot.docs) {
      final item = UserItem.fromMap(document.id, document.data());

      duplicates += item.duplicateCount;
    }

    return duplicates;
  }

  Future<Map<String, UserItem>> getItemsMap({
    required String userId,
    required String collectionId,
  }) async {
    final uid = userId.trim();
    final catalogCollectionId = collectionId.trim();

    if (uid.isEmpty) {
      throw ArgumentError('ID uporabnika ne sme biti prazen.');
    }

    if (catalogCollectionId.isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('collections')
        .doc(catalogCollectionId)
        .collection('items')
        .get();

    return {
      for (final document in snapshot.docs)
        document.id: UserItem.fromMap(document.id, document.data()),
    };
  }
}
