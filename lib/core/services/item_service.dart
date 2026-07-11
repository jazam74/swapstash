import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/item.dart';

class ItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _itemsCollection(
    String collectionId,
  ) {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('collections')
        .doc(collectionId)
        .collection('items');
  }

  Future<void> saveItemQuantity({
    required String collectionId,
    required int itemNumber,
    required int quantity,
  }) async {
    if (quantity < 0) {
      throw ArgumentError('Količina ne sme biti negativna.');
    }

    final document = _itemsCollection(
      collectionId,
    ).doc(itemNumber.toString());

    if (quantity == 0) {
      await document.delete();
      return;
    }

    final item = Item(
      number: itemNumber,
      quantity: quantity,
    );

    await document.set({
      ...item.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Item>> watchItems(
    String collectionId,
  ) {
    return _itemsCollection(collectionId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        final data = document.data();

        // Začasna podpora starim zapisom s poljem "status".
        if (!data.containsKey('quantity')) {
          return Item(
            number: data['number'] as int? ?? 0,
            quantity: _legacyQuantityFromStatus(
              data['status'] as String?,
            ),
          );
        }

        return Item.fromMap(data);
      }).toList();
    });
  }

  int _legacyQuantityFromStatus(String? status) {
    switch (status) {
      case 'owned':
        return 1;
      case 'duplicate':
        return 2;
      case 'missing':
      default:
        return 0;
    }
  }
}