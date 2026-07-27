import 'package:swapstash/core/models/catalog_collection.dart';
import 'package:swapstash/core/models/catalog_item.dart';

class ManualTradeItemOption {
  final CatalogCollection collection;
  final CatalogItem item;
  final int availableQuantity;

  const ManualTradeItemOption({
    required this.collection,
    required this.item,
    required this.availableQuantity,
  });

  String get key => '${collection.id}::${item.id}';
}

class ManualTradeCollectionOptions {
  final CatalogCollection collection;

  /// Smiselni predlogi: moji viški, ki jih drugi uporabnik še nima.
  final List<ManualTradeItemOption> currentUserCanOffer;

  /// Smiselni predlogi: njegovi viški, ki jih trenutni uporabnik še nima.
  final List<ManualTradeItemOption> otherUserCanOffer;

  /// Vsi dejansko razpoložljivi viški trenutnega uporabnika.
  final List<ManualTradeItemOption> allCurrentUserCanOffer;

  /// Vsi dejansko razpoložljivi viški drugega uporabnika.
  final List<ManualTradeItemOption> allOtherUserCanOffer;

  const ManualTradeCollectionOptions({
    required this.collection,
    required this.currentUserCanOffer,
    required this.otherUserCanOffer,
    required this.allCurrentUserCanOffer,
    required this.allOtherUserCanOffer,
  });

  bool get hasSuggestedTrade =>
      currentUserCanOffer.isNotEmpty && otherUserCanOffer.isNotEmpty;

  bool get hasAllSurplusTrade =>
      allCurrentUserCanOffer.isNotEmpty && allOtherUserCanOffer.isNotEmpty;

  bool get hasAnyItems =>
      allCurrentUserCanOffer.isNotEmpty || allOtherUserCanOffer.isNotEmpty;
}

class ManualTradeData {
  final List<ManualTradeCollectionOptions> collections;
  final int commonCollectionCount;

  const ManualTradeData({
    required this.collections,
    required this.commonCollectionCount,
  });

  bool get hasCommonCollections => commonCollectionCount > 0;

  bool get hasOfferItems =>
      collections.any((entry) => entry.allCurrentUserCanOffer.isNotEmpty);

  bool get hasRequestItems =>
      collections.any((entry) => entry.allOtherUserCanOffer.isNotEmpty);

  Iterable<ManualTradeItemOption> get allOfferItems sync* {
    for (final entry in collections) {
      yield* entry.allCurrentUserCanOffer;
    }
  }

  Iterable<ManualTradeItemOption> get allRequestItems sync* {
    for (final entry in collections) {
      yield* entry.allOtherUserCanOffer;
    }
  }
}
