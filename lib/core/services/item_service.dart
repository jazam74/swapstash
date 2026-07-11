import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    await document.set({
      'number': itemNumber,
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchItems(
    String collectionId,
  ) {
    return _itemsCollection(collectionId).snapshots();
  }
}