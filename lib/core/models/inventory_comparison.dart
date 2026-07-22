import 'package:swapstash/core/models/catalog_item.dart';

class InventoryComparison {
  final List<CatalogItem> canOffer;

  final List<CatalogItem> needs;

  const InventoryComparison({required this.canOffer, required this.needs});

  int get possibleTrades {
    return canOffer.length < needs.length ? canOffer.length : needs.length;
  }

  bool get hasPossibleTrade => possibleTrades > 0;
}
