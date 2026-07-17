import 'package:swapstash/core/models/catalog_item.dart';
import 'package:swapstash/core/models/inventory_comparison.dart';
import 'package:swapstash/core/services/catalog_item_service.dart';
import 'package:swapstash/core/services/user_item_service.dart';

class InventoryCompareService {
  final CatalogItemService _catalogItemService;
  final UserItemService _userItemService;

  InventoryCompareService({
    CatalogItemService? catalogItemService,
    UserItemService? userItemService,
  }) : _catalogItemService = catalogItemService ?? CatalogItemService(),
       _userItemService = userItemService ?? UserItemService();

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

    final catalogItemsFuture = _catalogItemService.getItems(
      catalogCollectionId,
    );

    final myItemsFuture = _userItemService.getItemsMap(
      userId: myUserId,
      collectionId: catalogCollectionId,
    );

    final otherItemsFuture = _userItemService.getItemsMap(
      userId: candidateUserId,
      collectionId: catalogCollectionId,
    );

    final List<CatalogItem> catalogItems = await catalogItemsFuture;

    final myItems = await myItemsFuture;
    final otherItems = await otherItemsFuture;

    final List<CatalogItem> canOffer = [];
    final List<CatalogItem> needs = [];

    for (final catalogItem in catalogItems) {
      final myQuantity = myItems[catalogItem.id]?.quantity ?? 0;

      final otherQuantity = otherItems[catalogItem.id]?.quantity ?? 0;

      // Jaz imam višek, drugi uporabnik pa predmeta nima.
      if (myQuantity > 1 && otherQuantity == 0) {
        canOffer.add(catalogItem);
      }

      // Drugi uporabnik ima višek, jaz pa predmeta nimam.
      if (myQuantity == 0 && otherQuantity > 1) {
        needs.add(catalogItem);
      }
    }

    return InventoryComparison(canOffer: canOffer, needs: needs);
  }
}
