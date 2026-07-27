import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:swapstash/core/models/trade_candidate.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/collection_members_service.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/core/services/inventory_compare_service.dart';
import 'package:swapstash/core/services/block_service.dart';

class TradeFinderService {
  final FirestoreService _firestoreService = FirestoreService();
  final CollectionMembersService _collectionMembersService =
      CollectionMembersService();
  final InventoryCompareService _inventoryCompareService =
      InventoryCompareService();
  final BlockService _blockService = BlockService();

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

    final allowedUserIds = await _blockService.filterAllowedUserIds(
      members.map((member) => member.uid),
    );
    final allowedMembers = members
        .where((member) => allowedUserIds.contains(member.uid))
        .toList(growable: false);

    debugPrint(
      'Samodejno iskanje menjav: zbirka=$collectionId, '
      'ustrezni uporabniki=${allowedMembers.length}',
    );

    final List<TradeCandidate> candidates = [];

    for (final member in allowedMembers) {
      final comparison = await _inventoryCompareService.compare(
        collectionId: collectionId,
        currentUserId: profile.uid,
        otherUserId: member.uid,
      );

      debugPrint(
        'Primerjava z ${member.displayName} (${member.uid}): '
        'ponudim=${comparison.canOffer.map((item) => item.number).join(',')}; '
        'potrebujem=${comparison.needs.map((item) => item.number).join(',')}',
      );

      if (!comparison.hasPossibleTrade) {
        continue;
      }

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
