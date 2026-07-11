import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/item.dart';

class ItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _collectionDocument(
    String collectionId,
  ) {
    return _db
        .collection('users')
        .doc(_currentUserId)
        .collection('collections')
        .doc(collectionId);
  }

  CollectionReference<Map<String, dynamic>> _itemsCollection(
    String collectionId,
  ) {
    return _collectionDocument(collectionId).collection('items');
  }

  Future<void> saveItemQuantity({
    required String collectionId,
    required int itemNumber,
    required int quantity,
  }) async {
    if (collectionId.trim().isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    if (itemNumber <= 0) {
      throw ArgumentError(
        'Številka predmeta mora biti večja od 0.',
      );
    }

    if (quantity < 0 || quantity > 999) {
      throw ArgumentError(
        'Količina mora biti med 0 in 999.',
      );
    }

    final collectionDocument =
        _collectionDocument(collectionId);

    final itemDocument = _itemsCollection(collectionId)
        .doc(itemNumber.toString());

    await _db.runTransaction((transaction) async {
      final itemSnapshot =
          await transaction.get(itemDocument);

      final oldQuantity = itemSnapshot.exists
          ? _quantityFromData(itemSnapshot.data()!)
          : 0;

      final ownedDelta =
          _ownedValue(quantity) - _ownedValue(oldQuantity);

      final duplicateDelta =
          _duplicateValue(quantity) -
          _duplicateValue(oldQuantity);

      if (quantity == 0) {
        transaction.delete(itemDocument);
      } else {
        final item = Item(
          number: itemNumber,
          quantity: quantity,
        );

        transaction.set(
          itemDocument,
          {
            ...item.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }

      transaction.update(
        collectionDocument,
        {
          'stats.ownedCount':
              FieldValue.increment(ownedDelta),
          'stats.duplicateCount':
              FieldValue.increment(duplicateDelta),
          'stats.updatedAt':
              FieldValue.serverTimestamp(),
        },
      );
    });
  }

  Stream<List<Item>> watchItems(
    String collectionId,
  ) {
    return _itemsCollection(collectionId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((document) {
            final data = document.data();

            return Item(
              number: data['number'] as int? ??
                  int.tryParse(document.id) ??
                  0,
              quantity: _quantityFromData(data),
            );
          })
          .where((item) => item.number > 0)
          .toList();

      items.sort(
        (first, second) =>
            first.number.compareTo(second.number),
      );

      return items;
    });
  }

  /// Enkratno preračuna statistiko za stare zbirke, ki so
  /// obstajale, preden je bilo dodano polje `stats`.
  Future<void> rebuildCollectionStats({
    required String collectionId,
  }) async {
    if (collectionId.trim().isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    final snapshot =
        await _itemsCollection(collectionId).get();

    var ownedCount = 0;
    var duplicateCount = 0;

    for (final document in snapshot.docs) {
      final quantity = _quantityFromData(
        document.data(),
      );

      ownedCount += _ownedValue(quantity);
      duplicateCount += _duplicateValue(quantity);
    }

    await _collectionDocument(collectionId).set(
      {
        'stats': {
          'ownedCount': ownedCount,
          'duplicateCount': duplicateCount,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      SetOptions(merge: true),
    );
  }

  int _quantityFromData(
    Map<String, dynamic> data,
  ) {
    final quantity = data['quantity'];

    if (quantity is int) {
      return quantity < 0 ? 0 : quantity;
    }

    // Začasna podpora starim dokumentom.
    switch (data['status']) {
      case 'owned':
        return 1;
      case 'duplicate':
        return 2;
      case 'missing':
      default:
        return 0;
    }
  }

  int _ownedValue(int quantity) {
    return quantity > 0 ? 1 : 0;
  }

  int _duplicateValue(int quantity) {
    return quantity > 1 ? quantity - 1 : 0;
  }
}