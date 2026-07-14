import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/core/models/catalog_collection.dart';

class CatalogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _catalogCollections {
    return _db.collection('catalogCollections');
  }

  Stream<List<CatalogCollection>>
      watchActiveCollections() {
    return _catalogCollections
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return CatalogCollection.fromMap(
          document.id,
          document.data(),
        );
      }).toList();
    });
  }

  Future<List<CatalogCollection>>
      getActiveCollections() async {
    final snapshot = await _catalogCollections
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();

    return snapshot.docs.map((document) {
      return CatalogCollection.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  Future<CatalogCollection?> getCollection(
    String catalogCollectionId,
  ) async {
    final id = catalogCollectionId.trim();

    if (id.isEmpty) {
      return null;
    }

    final document =
        await _catalogCollections.doc(id).get();

    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return CatalogCollection.fromMap(
      document.id,
      data,
    );
  }

  Future<List<CatalogCollection>>
      searchCollections(String query) async {
    final value = query.trim();

    if (value.isEmpty) {
      return getActiveCollections();
    }

    final snapshot = await _catalogCollections
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .startAt([value])
        .endAt(['$value\uf8ff'])
        .limit(30)
        .get();

    return snapshot.docs.map((document) {
      return CatalogCollection.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }
}