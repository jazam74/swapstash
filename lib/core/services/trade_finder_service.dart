import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/trade_candidate.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/collection_members_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/core/services/inventory_compare_service.dart';

class TradeFinderService {
  final FirestoreService _firestoreService = FirestoreService();
  final CollectionMembersService _collectionMembersService =
      CollectionMembersService();
  final InventoryCompareService _inventoryCompareService =
      InventoryCompareService();

  Future<List<TradeCandidate>> findTrades({
    required String collectionId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not logged in.');

    final UserProfile? profile = await _firestoreService.getUserProfile(
      currentUser.uid,
    );
    if (profile == null) throw Exception('Profile not found.');

    final members = await _collectionMembersService.getEligibleMembers(
      collectionId: collectionId,
      currentProfile: profile,
    );

    final List<TradeCandidate> candidates = [];

    for (final member in members) {
      final comparison = await _inventoryCompareService.compare(
        collectionId: collectionId,
        currentUserId: profile.uid,
        otherUserId: member.uid,
      );

      if (!comparison.hasPossibleTrade) continue;

      candidates.add(TradeCandidate(member: member, comparison: comparison));
    }

    candidates.sort((a, b) {
      final trades = b.possibleTrades.compareTo(a.possibleTrades);
      if (trades != 0) return trades;

      final duplicates = b.duplicateCount.compareTo(a.duplicateCount);
      if (duplicates != 0) return duplicates;

      return a.member.displayName.toLowerCase().compareTo(
        b.member.displayName.toLowerCase(),
      );
    });

    return candidates;
  }
}
