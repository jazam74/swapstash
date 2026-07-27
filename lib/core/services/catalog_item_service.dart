import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/core/models/catalog_item.dart';

enum CatalogItemImportMode { skipExisting, updateExisting }

class CatalogItemImportSummary {
  final int created;
  final int updated;
  final int skipped;

  const CatalogItemImportSummary({
    required this.created,
    required this.updated,
    required this.skipped,
  });

  int get processed => created + updated + skipped;
}

class CatalogItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _itemsReference(
    String collectionId,
  ) {
    final id = collectionId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID kataloške zbirke ne sme biti prazen.');
    }

    return _db.collection('catalogCollections').doc(id).collection('items');
  }

  Stream<List<CatalogItem>> watchItems(String collectionId) {
    return _itemsReference(collectionId).snapshots().map((snapshot) {
      final documents = snapshot.docs.toList(growable: false)
        ..sort(_compareDocuments);

      return documents
          .map(
            (document) => CatalogItem.fromMap(document.id, document.data()),
          )
          .toList(growable: false);
    });
  }

  Future<List<CatalogItem>> getItems(String collectionId) async {
    final snapshot = await _itemsReference(collectionId).get();
    final documents = snapshot.docs.toList(growable: false)
      ..sort(_compareDocuments);

    return documents
        .map((document) => CatalogItem.fromMap(document.id, document.data()))
        .toList(growable: false);
  }

  Future<CatalogItem?> getItem({
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

    return CatalogItem.fromMap(document.id, data);
  }

  Future<CatalogItemImportSummary> importItems({
    required String collectionId,
    required List<CatalogItem> items,
    required CatalogItemImportMode mode,
  }) async {
    final normalizedCollectionId = collectionId.trim();

    if (normalizedCollectionId.isEmpty) {
      throw ArgumentError('Izberi ciljno zbirko.');
    }

    if (items.isEmpty) {
      return const CatalogItemImportSummary(created: 0, updated: 0, skipped: 0);
    }

    final itemsReference = _itemsReference(normalizedCollectionId);
    final existingSnapshot = await itemsReference.get();

    final existingByNumber =
        <String, DocumentReference<Map<String, dynamic>>>{};

    for (final document in existingSnapshot.docs) {
      final number = document.data()['number']?.toString() ?? '';
      final normalizedNumber = _normalizeNumber(number);

      if (normalizedNumber.isNotEmpty) {
        existingByNumber.putIfAbsent(
          normalizedNumber,
          () => document.reference,
        );
      }
    }

    var created = 0;
    var updated = 0;
    var skipped = 0;
    var writesInBatch = 0;
    var batch = _db.batch();

    Future<void> commitBatch() async {
      if (writesInBatch == 0) {
        return;
      }

      await batch.commit();
      batch = _db.batch();
      writesInBatch = 0;
    }

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final normalizedNumber = _normalizeNumber(item.number);

      if (normalizedNumber.isEmpty) {
        skipped++;
        continue;
      }

      final existingReference = existingByNumber[normalizedNumber];
      final data = Map<String, dynamic>.from(item.toMap())
        ..['collectionId'] = normalizedCollectionId
        ..['sortOrder'] = index + 1
        ..['updatedAt'] = FieldValue.serverTimestamp();

      if (existingReference != null) {
        if (mode == CatalogItemImportMode.skipExisting) {
          skipped++;
          continue;
        }

        batch.set(existingReference, data, SetOptions(merge: true));
        updated++;
        writesInBatch++;
      } else {
        final newReference = itemsReference.doc();

        data['createdAt'] = FieldValue.serverTimestamp();
        batch.set(newReference, data);

        existingByNumber[normalizedNumber] = newReference;
        created++;
        writesInBatch++;
      }

      if (writesInBatch >= 400) {
        await commitBatch();
      }
    }

    await commitBatch();

    await _db.collection('catalogCollections').doc(normalizedCollectionId).set({
      'totalItems': existingSnapshot.docs.length + created,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return CatalogItemImportSummary(
      created: created,
      updated: updated,
      skipped: skipped,
    );
  }

  int _compareDocuments(
    QueryDocumentSnapshot<Map<String, dynamic>> first,
    QueryDocumentSnapshot<Map<String, dynamic>> second,
  ) {
    final firstData = first.data();
    final secondData = second.data();

    final firstSortOrder = (firstData['sortOrder'] as num?)?.toInt();
    final secondSortOrder = (secondData['sortOrder'] as num?)?.toInt();

    if (firstSortOrder != null && secondSortOrder != null) {
      final comparison = firstSortOrder.compareTo(secondSortOrder);
      if (comparison != 0) {
        return comparison;
      }
    } else if (firstSortOrder != null) {
      return -1;
    } else if (secondSortOrder != null) {
      return 1;
    }

    final firstNumber = firstData['number']?.toString() ?? '';
    final secondNumber = secondData['number']?.toString() ?? '';

    return _naturalCompare(firstNumber, secondNumber);
  }

  int _naturalCompare(String first, String second) {
    final firstParts = RegExp(r'\d+|\D+')
        .allMatches(first.toLowerCase())
        .map((match) => match.group(0)!)
        .toList(growable: false);

    final secondParts = RegExp(r'\d+|\D+')
        .allMatches(second.toLowerCase())
        .map((match) => match.group(0)!)
        .toList(growable: false);

    final commonLength = firstParts.length < secondParts.length
        ? firstParts.length
        : secondParts.length;

    for (var index = 0; index < commonLength; index++) {
      final firstPart = firstParts[index];
      final secondPart = secondParts[index];

      final firstNumber = int.tryParse(firstPart);
      final secondNumber = int.tryParse(secondPart);

      int comparison;

      if (firstNumber != null && secondNumber != null) {
        comparison = firstNumber.compareTo(secondNumber);
      } else {
        comparison = firstPart.compareTo(secondPart);
      }

      if (comparison != 0) {
        return comparison;
      }
    }

    return firstParts.length.compareTo(secondParts.length);
  }

  String _normalizeNumber(String value) {
    return value.trim().toLowerCase();
  }
}
