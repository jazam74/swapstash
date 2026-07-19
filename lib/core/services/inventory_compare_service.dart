import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/inventory_comparison.dart';
import 'package:swapstash/core/services/catalog_item_service.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/core/services/user_item_service.dart';

class InventoryCompareService {
  final CatalogItemService _catalogItemService;
  final UserItemService _userItemService;
  final TradeService _tradeService;

  InventoryCompareService({
    CatalogItemService? catalogItemService,
    UserItemService? userItemService,
    TradeService? tradeService,
  }) : _catalogItemService = catalogItemService ?? CatalogItemService(),
       _userItemService = userItemService ?? UserItemService(),
       _tradeService = tradeService ?? TradeService();

  Future<InventoryComparison> compare({
    required String collectionId,
    required String currentUserId,
    required String otherUserId,
  }) async {
    final catalogCollectionId = collectionId.trim();
    final myUserId = currentUserId.trim();
    final candidateUserId = otherUserId.trim();

    if (catalogCollectionId.isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    if (myUserId.isEmpty) {
      throw ArgumentError('ID trenutnega uporabnika ne sme biti prazen.');
    }

    if (candidateUserId.isEmpty) {
      throw ArgumentError('ID drugega uporabnika ne sme biti prazen.');
    }

    if (myUserId == candidateUserId) {
      return const InventoryComparison(canOffer: [], needs: []);
    }

    final results = await Future.wait([
      _catalogItemService.getItems(catalogCollectionId),
      _userItemService.getItemsMap(
        userId: myUserId,
        collectionId: catalogCollectionId,
      ),
      _userItemService.getItemsMap(
        userId: candidateUserId,
        collectionId: catalogCollectionId,
      ),
      _tradeService.getActiveReservations(userId: myUserId),
      _tradeService.getActiveReservations(userId: candidateUserId),
    ]);

    final catalogItems = results[0] as List<CatalogItem>;
    final myItems = results[1] as Map<String, dynamic>;
    final otherItems = results[2] as Map<String, dynamic>;
    final myReservations = results[3] as TradeReservations;
    final otherReservations = results[4] as TradeReservations;

    final List<CatalogItem> canOffer = [];
    final List<CatalogItem> needs = [];

    int myAvailableSurplus(CatalogItem item) {
      final quantity = (myItems[item.id]?.quantity ?? 0) as int;
      final reservedOutgoing = myReservations.outgoingQuantity(
        collectionId: catalogCollectionId,
        itemNumber: item.number,
      );

      // En izvod ostane za lastno zbirko.
      final surplus = quantity - 1 - reservedOutgoing;
      return surplus > 0 ? surplus : 0;
    }

    int otherAvailableSurplus(CatalogItem item) {
      final quantity = (otherItems[item.id]?.quantity ?? 0) as int;
      final reservedOutgoing = otherReservations.outgoingQuantity(
        collectionId: catalogCollectionId,
        itemNumber: item.number,
      );

      final surplus = quantity - 1 - reservedOutgoing;
      return surplus > 0 ? surplus : 0;
    }

    bool iStillNeed(CatalogItem item) {
      final quantity = (myItems[item.id]?.quantity ?? 0) as int;

      if (quantity > 0) {
        return false;
      }

      // Če predmet že pričakujem iz sprejete menjave,
      // ga ne iščemo ponovno pri drugem uporabniku.
      return myReservations.incomingQuantity(
            collectionId: catalogCollectionId,
            itemNumber: item.number,
          ) ==
          0;
    }

    bool otherStillNeeds(CatalogItem item) {
      final quantity = (otherItems[item.id]?.quantity ?? 0) as int;

      if (quantity > 0) {
        return false;
      }

      return otherReservations.incomingQuantity(
            collectionId: catalogCollectionId,
            itemNumber: item.number,
          ) ==
          0;
    }

    for (final catalogItem in catalogItems) {
      if (myAvailableSurplus(catalogItem) > 0 && otherStillNeeds(catalogItem)) {
        canOffer.add(catalogItem);
      }

      if (iStillNeed(catalogItem) && otherAvailableSurplus(catalogItem) > 0) {
        needs.add(catalogItem);
      }
    }

    // Prioriteta: največ dejansko razpoložljivih viškov po rezervacijah.
    canOffer.sort((a, b) {
      final bySurplus = myAvailableSurplus(b).compareTo(myAvailableSurplus(a));

      if (bySurplus != 0) {
        return bySurplus;
      }

      return a.number.compareTo(b.number);
    });

    needs.sort((a, b) {
      final bySurplus = otherAvailableSurplus(
        b,
      ).compareTo(otherAvailableSurplus(a));

      if (bySurplus != 0) {
        return bySurplus;
      }

      return a.number.compareTo(b.number);
    });

    return InventoryComparison(canOffer: canOffer, needs: needs);
  }
}
