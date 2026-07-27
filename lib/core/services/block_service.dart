import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/blocked_user.dart';

class BlockRelationship {
  final bool iBlockedThem;
  final bool theyBlockedMe;

  const BlockRelationship({
    required this.iBlockedThem,
    required this.theyBlockedMe,
  });

  const BlockRelationship.none() : iBlockedThem = false, theyBlockedMe = false;

  bool get isBlocked => iBlockedThem || theyBlockedMe;

  bool get canUnblock => iBlockedThem;
}

class UserInteractionBlockedException implements Exception {
  final BlockRelationship relationship;

  const UserInteractionBlockedException(this.relationship);

  @override
  String toString() => relationship.iBlockedThem
      ? 'interaction_blocked_by_current_user'
      : 'interaction_blocked_by_other_user';
}

class BlockService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  BlockService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('user_not_signed_in');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _blockedUsersReference(
    String ownerId,
  ) {
    return _db.collection('users').doc(ownerId).collection('blockedUsers');
  }

  DocumentReference<Map<String, dynamic>> _blockReference({
    required String ownerId,
    required String blockedUserId,
  }) {
    return _blockedUsersReference(ownerId).doc(blockedUserId);
  }

  Future<BlockRelationship> getRelationship({
    required String otherUserId,
  }) async {
    final currentId = currentUserId;
    final otherId = otherUserId.trim();

    if (otherId.isEmpty || otherId == currentId) {
      return const BlockRelationship.none();
    }

    final results = await Future.wait([
      _blockReference(ownerId: currentId, blockedUserId: otherId).get(),
      _blockReference(ownerId: otherId, blockedUserId: currentId).get(),
    ]);

    return BlockRelationship(
      iBlockedThem: results[0].exists,
      theyBlockedMe: results[1].exists,
    );
  }

  Stream<BlockRelationship> watchRelationship({required String otherUserId}) {
    final currentId = currentUserId;
    final otherId = otherUserId.trim();

    if (otherId.isEmpty || otherId == currentId) {
      return Stream<BlockRelationship>.value(const BlockRelationship.none());
    }

    late final StreamController<BlockRelationship> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    currentSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    otherSubscription;

    var iBlockedThem = false;
    var theyBlockedMe = false;
    var currentLoaded = false;
    var otherLoaded = false;

    void emit() {
      if (controller.isClosed || !currentLoaded || !otherLoaded) {
        return;
      }

      controller.add(
        BlockRelationship(
          iBlockedThem: iBlockedThem,
          theyBlockedMe: theyBlockedMe,
        ),
      );
    }

    controller = StreamController<BlockRelationship>(
      onListen: () {
        currentSubscription =
            _blockReference(
              ownerId: currentId,
              blockedUserId: otherId,
            ).snapshots().listen((snapshot) {
              iBlockedThem = snapshot.exists;
              currentLoaded = true;
              emit();
            }, onError: controller.addError);

        otherSubscription =
            _blockReference(
              ownerId: otherId,
              blockedUserId: currentId,
            ).snapshots().listen((snapshot) {
              theyBlockedMe = snapshot.exists;
              otherLoaded = true;
              emit();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await currentSubscription?.cancel();
        await otherSubscription?.cancel();
      },
    );

    return controller.stream.distinct(
      (first, second) =>
          first.iBlockedThem == second.iBlockedThem &&
          first.theyBlockedMe == second.theyBlockedMe,
    );
  }

  Future<void> blockUser({required String userId}) async {
    final currentId = currentUserId;
    final blockedId = userId.trim();

    if (blockedId.isEmpty) {
      throw ArgumentError('blocked_user_missing');
    }

    if (blockedId == currentId) {
      throw ArgumentError('cannot_block_self');
    }

    await _blockReference(ownerId: currentId, blockedUserId: blockedId).set({
      'blockedUserId': blockedId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> unblockUser({required String userId}) async {
    final blockedId = userId.trim();

    if (blockedId.isEmpty) {
      return;
    }

    await _blockReference(
      ownerId: currentUserId,
      blockedUserId: blockedId,
    ).delete();
  }

  Stream<List<BlockedUser>> watchBlockedUsers() {
    return _blockedUsersReference(currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => BlockedUser.fromMap(document.id, document.data()),
              )
              .toList(growable: false),
        );
  }

  Future<void> ensureInteractionAllowed({required String otherUserId}) async {
    final relationship = await getRelationship(otherUserId: otherUserId);

    if (relationship.isBlocked) {
      throw UserInteractionBlockedException(relationship);
    }
  }

  Future<Set<String>> filterAllowedUserIds(Iterable<String> userIds) async {
    final currentId = currentUserId;
    final normalizedIds = userIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty && id != currentId)
        .toSet();

    if (normalizedIds.isEmpty) {
      return <String>{};
    }

    final ownBlocksSnapshot = await _blockedUsersReference(currentId).get();
    final ownBlockedIds = ownBlocksSnapshot.docs
        .map((document) => document.id)
        .toSet();

    final candidateIds = normalizedIds
        .where((id) => !ownBlockedIds.contains(id))
        .toList(growable: false);

    final reverseBlocks = await Future.wait(
      candidateIds.map(
        (candidateId) => _blockReference(
          ownerId: candidateId,
          blockedUserId: currentId,
        ).get(),
      ),
    );

    final allowedIds = <String>{};

    for (var index = 0; index < candidateIds.length; index++) {
      if (!reverseBlocks[index].exists) {
        allowedIds.add(candidateIds[index]);
      }
    }

    return allowedIds;
  }
}
