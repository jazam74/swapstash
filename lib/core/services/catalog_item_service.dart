import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/core/models/catalog_item.dart';

class CatalogItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _itemsReference(
    String collectionId,
  ) {
    final id = collectionId.trim();

    if (id.isEmpty) {
      throw ArgumentError(
        'ID kataloške zbirke ne sme biti prazen.',
      );
    }

    return _db
        .collection('catalogCollections')
        .doc(id)
        .collection('items');
  }

  Stream<List<CatalogItem>> watchItems(
    String collectionId,
  ) {
    return _itemsReference(collectionId)
        .orderBy('number')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => CatalogItem.fromMap(
                  document.id,
                  document.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<CatalogItem>> getItems(
    String collectionId,
  ) async {
    final snapshot = await _itemsReference(
      collectionId,
    ).orderBy('number').get();

    return snapshot.docs
        .map(
          (document) => CatalogItem.fromMap(
            document.id,
            document.data(),
          ),
        )
        .toList();
  }

  Future<CatalogItem?> getItem({
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

    return CatalogItem.fromMap(
      document.id,
      data,
    );
  }
}