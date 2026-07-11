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

  Future<void> saveItemStatus({
    required String collectionId,
    required int itemNumber,
    required String status,
  }) async {
    await _itemsCollection(collectionId)
        .doc(itemNumber.toString())
        .set({
      'number': itemNumber,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchItems(
    String collectionId,
  ) {
    return _itemsCollection(collectionId)
        .snapshots();
  }
}