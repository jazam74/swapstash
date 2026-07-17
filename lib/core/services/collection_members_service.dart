import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/core/models/collection_member.dart';
import 'package:swapstash/core/models/user_profile.dart';

class CollectionMembersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _membersCollection(
    String collectionId,
  ) {
    final id = collectionId.trim();

    if (id.isEmpty) {
      throw ArgumentError('ID zbirke ne sme biti prazen.');
    }

    return _db.collection('collectionMembers').doc(id).collection('users');
  }

  Future<void> upsertMember({
    required String collectionId,
    required CollectionMember member,
  }) async {
    await _membersCollection(
      collectionId,
    ).doc(member.uid).set(member.toMap(), SetOptions(merge: true));
  }

  Future<void> syncMember({
    required String collectionId,
    required UserProfile profile,
    required int ownedCount,
    required int duplicateCount,
  }) async {
    if (ownedCount < 0) {
      throw ArgumentError('Število predmetov ne sme biti negativno.');
    }

    if (duplicateCount < 0) {
      throw ArgumentError('Število viškov ne sme biti negativno.');
    }

    // Zasebnega profila ne hranimo v javnem iskalnem indeksu.
    if (!profile.isPublic) {
      await removeMember(collectionId: collectionId, uid: profile.uid);

      return;
    }

    final member = CollectionMember(
      uid: profile.uid,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      country: profile.country,
      city: profile.city,
      isPublic: true,
      allowInternationalTrades: profile.allowInternationalTrades,
      ownedCount: ownedCount,
      duplicateCount: duplicateCount,
      lastUpdated: Timestamp.now(),
    );

    await upsertMember(collectionId: collectionId, member: member);
  }

  Future<void> removeMember({
    required String collectionId,
    required String uid,
  }) async {
    final userId = uid.trim();

    if (userId.isEmpty) {
      throw ArgumentError('ID uporabnika ne sme biti prazen.');
    }

    await _membersCollection(collectionId).doc(userId).delete();
  }

  Stream<List<CollectionMember>> watchMembers({required String collectionId}) {
    return _membersCollection(collectionId)
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => CollectionMember.fromMap({
                  ...document.data(),
                  'uid': document.id,
                }),
              )
              .toList(),
        );
  }

  Future<List<CollectionMember>> getEligibleMembers({
    required String collectionId,
    required UserProfile currentProfile,
  }) async {
    final snapshot = await _membersCollection(
      collectionId,
    ).where('isPublic', isEqualTo: true).get();

    final members = snapshot.docs
        .map(
          (document) => CollectionMember.fromMap({
            ...document.data(),
            'uid': document.id,
          }),
        )
        .where((member) {
          if (member.uid == currentProfile.uid) {
            return false;
          }

          final sameCountry =
              member.country.trim().toUpperCase() ==
              currentProfile.country.trim().toUpperCase();

          final internationalAllowed =
              currentProfile.allowInternationalTrades &&
              member.allowInternationalTrades;

          return sameCountry || internationalAllowed;
        })
        .toList();

    members.sort((a, b) {
      final duplicateComparison = b.duplicateCount.compareTo(a.duplicateCount);

      if (duplicateComparison != 0) {
        return duplicateComparison;
      }

      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return members;
  }
}
