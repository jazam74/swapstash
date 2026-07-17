import 'package:swapstash/core/models/collection_member.dart';
import 'package:swapstash/core/models/inventory_comparison.dart';

class TradeCandidate {
  final CollectionMember member;

  final InventoryComparison comparison;

  const TradeCandidate({
    required this.member,
    required this.comparison,
  });

  int get possibleTrades => comparison.possibleTrades;

  bool get hasPossibleTrade => comparison.hasPossibleTrade;

  int get ownedCount => member.ownedCount;

  int get duplicateCount => member.duplicateCount;

  double get matchScore {
    final total =
        comparison.canOffer.length +
        comparison.needs.length;

    if (total == 0) {
      return 0;
    }

    return possibleTrades / total;
  }
}