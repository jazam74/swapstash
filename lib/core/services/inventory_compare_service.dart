import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/inventory_comparison.dart';
import 'package:swapstash/core/models/user_item.dart';
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
      _tradeService.getActiveReservations(
        userId: myUserId,
        collectionIds: [catalogCollectionId],
      ),
      _tradeService.getActiveReservations(
        userId: candidateUserId,
        collectionIds: [catalogCollectionId],
      ),
    ]);

    final catalogItems = results[0] as List<CatalogItem>;
    final myItems = results[1] as Map<String, UserItem>;
    final otherItems = results[2] as Map<String, UserItem>;
    final myReservations = results[3] as TradeReservations;
    final otherReservations = results[4] as TradeReservations;

    final List<CatalogItem> canOffer = [];
    final List<CatalogItem> needs = [];

    String normalizeItemIdentity(String value) {
      final normalized = value.trim().toLowerCase();
      final numericValue = int.tryParse(normalized);

      return numericValue?.toString() ?? normalized;
    }

    int storedQuantity(Map<String, UserItem> inventory, CatalogItem item) {
      final directMatch =
          inventory[item.id] ??
          inventory[item.number] ??
          inventory[item.id.trim()] ??
          inventory[item.number.trim()];

      if (directMatch != null) {
        return directMatch.quantity;
      }

      final identities = {
        normalizeItemIdentity(item.id),
        normalizeItemIdentity(item.number),
      };

      for (final entry in inventory.entries) {
        final documentIdentity = normalizeItemIdentity(entry.key);
        final storedIdentity = normalizeItemIdentity(entry.value.itemId);

        if (identities.contains(documentIdentity) ||
            identities.contains(storedIdentity)) {
          return entry.value.quantity;
        }
      }

      return 0;
    }

    int myAvailableSurplus(CatalogItem item) {
      final quantity = storedQuantity(myItems, item);
      final reservedOutgoing = myReservations.outgoingQuantity(
        collectionId: catalogCollectionId,
        itemNumber: item.number,
      );

      // En izvod ostane za lastno zbirko.
      final surplus = quantity - 1 - reservedOutgoing;
      return surplus > 0 ? surplus : 0;
    }

    int otherAvailableSurplus(CatalogItem item) {
      final quantity = storedQuantity(otherItems, item);
      final reservedOutgoing = otherReservations.outgoingQuantity(
        collectionId: catalogCollectionId,
        itemNumber: item.number,
      );

      final surplus = quantity - 1 - reservedOutgoing;
      return surplus > 0 ? surplus : 0;
    }

    bool iStillNeed(CatalogItem item) {
      final quantity = storedQuantity(myItems, item);

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
      final quantity = storedQuantity(otherItems, item);

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
