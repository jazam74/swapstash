import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  final Map<String, Timer> _memberSyncTimers = {};

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
    final id = collectionId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    final profile = await _firestoreService.getUserProfile(_currentUserId);

    if (profile == null) {
      return;
    }

    // En sam Firestore read za obe statistiki.
    final snapshot = await _itemsReference(id).get();

    int ownedCount = 0;
    int duplicateCount = 0;

    for (final document in snapshot.docs) {
      final item = UserItem.fromMap(document.id, document.data());

      if (item.quantity > 0) {
        ownedCount++;
      }

      duplicateCount += item.duplicateCount;
    }

    await _collectionMembersService.syncMember(
      collectionId: id,
      profile: profile,
      ownedCount: ownedCount,
      duplicateCount: duplicateCount,
    );
  }

  void _scheduleCollectionMemberSync({required String collectionId}) {
    final id = collectionId.trim();

    if (id.isEmpty) {
      return;
    }

    // Več hitrih klikov združi v eno samo posodobitev javnega indeksa.
    _memberSyncTimers.remove(id)?.cancel();

    _memberSyncTimers[id] = Timer(const Duration(seconds: 2), () async {
      _memberSyncTimers.remove(id);

      try {
        await syncCollectionMember(collectionId: id);
      } catch (error, stackTrace) {
        // Količina je že shranjena. Napaka javnega indeksa zato
        // ne sme zakleniti hitrega vnosa.
        debugPrint('Posodobitev člana zbirke ni uspela: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
  }

  Future<int> migrateLegacyItemDocuments({required String collectionId}) async {
    final id = collectionId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    final catalogSnapshot = await _db
        .collection('catalogCollections')
        .doc(id)
        .collection('items')
        .get();

    final canonicalIds = <String>{};
    final canonicalIdByNumber = <String, String>{};

    for (final document in catalogSnapshot.docs) {
      canonicalIds.add(document.id);

      final number = document.data()['number']?.toString() ?? '';
      final normalizedNumber = _normalizeItemNumber(number);

      if (normalizedNumber.isNotEmpty) {
        canonicalIdByNumber.putIfAbsent(normalizedNumber, () => document.id);
      }
    }

    final inventorySnapshot = await _itemsReference(id).get();
    var migratedCount = 0;

    for (final document in inventorySnapshot.docs) {
      if (canonicalIds.contains(document.id)) {
        continue;
      }

      final canonicalId =
          canonicalIdByNumber[_normalizeItemNumber(document.id)];

      if (canonicalId == null || canonicalId == document.id) {
        continue;
      }

      final legacyReference = document.reference;
      final canonicalReference = _itemsReference(id).doc(canonicalId);

      final migrated = await _db.runTransaction<bool>((transaction) async {
        final legacySnapshot = await transaction.get(legacyReference);
        final canonicalSnapshot = await transaction.get(canonicalReference);

        if (!legacySnapshot.exists || legacySnapshot.data() == null) {
          return false;
        }

        final legacyQuantity =
            (legacySnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
        final canonicalQuantity =
            (canonicalSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;

        if (legacyQuantity > 0) {
          transaction.set(canonicalReference, {
            'itemId': canonicalId,
            'quantity': canonicalQuantity + legacyQuantity,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        transaction.delete(legacyReference);
        return true;
      });

      if (migrated) {
        migratedCount++;
      }
    }

    if (migratedCount > 0) {
      await syncCollectionMember(collectionId: id);
    }

    return migratedCount;
  }

  String _normalizeItemNumber(String value) {
    return value.trim().toLowerCase();
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
    final collection = collectionId.trim();
    final id = itemId.trim();

    if (collection.isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    if (id.isEmpty) {
      throw ArgumentError('ID predmeta ne sme biti prazen.');
    }

    if (quantity < 0) {
      throw ArgumentError('Količina ne sme biti negativna.');
    }

    final reference = _itemsReference(collection).doc(id);

    if (quantity == 0) {
      await reference.delete();
    } else {
      final userItem = UserItem(
        itemId: id,
        quantity: quantity,
        updatedAt: Timestamp.now(),
      );

      await reference.set(userItem.toMap(), SetOptions(merge: true));
    }

    // Ne čakamo več na dodatno štetje in javni indeks.
    // Hitri vnos se zaključi takoj po shranjeni količini.
    _scheduleCollectionMemberSync(collectionId: collection);
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
        duplicates += item.duplicateCount;
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
