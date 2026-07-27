import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_item.dart';
import 'package:swapstash/core/services/user_item_service.dart';
import 'package:swapstash/core/services/block_service.dart';

enum TradeInventorySide { sender, receiver }

class TradeInventoryUnavailableException implements Exception {
  final TradeInventorySide side;
  final String itemNumber;
  final int requestedQuantity;
  final int availableQuantity;

  const TradeInventoryUnavailableException({
    required this.side,
    required this.itemNumber,
    required this.requestedQuantity,
    required this.availableQuantity,
  });

  @override
  String toString() {
    return 'trade_inventory_unavailable:'
        '${side.name}:$itemNumber:$requestedQuantity:$availableQuantity';
  }
}

class TradeCatalogItemUnavailableException implements Exception {
  final String itemNumber;

  const TradeCatalogItemUnavailableException(this.itemNumber);

  @override
  String toString() {
    return 'trade_catalog_item_unavailable:$itemNumber';
  }
}

class TradeReservations {
  final Map<String, int> outgoingByItem;
  final Map<String, int> incomingByItem;

  const TradeReservations({
    required this.outgoingByItem,
    required this.incomingByItem,
  });

  int outgoingQuantity({
    required String collectionId,
    required String itemNumber,
  }) {
    return outgoingByItem[_key(collectionId, itemNumber)] ?? 0;
  }

  int incomingQuantity({
    required String collectionId,
    required String itemNumber,
  }) {
    return incomingByItem[_key(collectionId, itemNumber)] ?? 0;
  }

  static String _key(String collectionId, String itemNumber) {
    return '${collectionId.trim()}::${itemNumber.trim().toLowerCase()}';
  }
}

class TradeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserItemService _userItemService = UserItemService();
  final BlockService _blockService = BlockService();

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _tradesReference {
    return _db.collection('trades');
  }

  Future<String> createTrade({
    required String receiverId,
    required List<TradeItem> offeredItems,
    required List<TradeItem> requestedItems,
  }) async {
    final receiver = receiverId.trim();
    final sender = currentUserId;

    if (receiver.isEmpty) {
      throw ArgumentError('Prejemnik menjave ni določen.');
    }

    if (receiver == sender) {
      throw ArgumentError('Menjave ne moreš poslati samemu sebi.');
    }

    await _blockService.ensureInteractionAllowed(otherUserId: receiver);

    if (offeredItems.isEmpty || requestedItems.isEmpty) {
      throw ArgumentError('Menjava mora vsebovati predmete na obeh straneh.');
    }

    _validateItems(offeredItems);
    _validateItems(requestedItems);

    final canonicalItemIds = await _resolveCanonicalItemIds([
      ...offeredItems,
      ...requestedItems,
    ]);

    final normalizedOfferedItems = _mergeTradeItems(
      _withCanonicalItemIds(offeredItems, canonicalItemIds),
    );
    final normalizedRequestedItems = _mergeTradeItems(
      _withCanonicalItemIds(requestedItems, canonicalItemIds),
    );

    await _validateAvailableSurplus(
      userId: sender,
      items: normalizedOfferedItems,
      side: TradeInventorySide.sender,
    );
    await _validateAvailableSurplus(
      userId: receiver,
      items: normalizedRequestedItems,
      side: TradeInventorySide.receiver,
    );

    final document = _tradesReference.doc();

    await document.set({
      'senderId': sender,
      'receiverId': receiver,
      'offeredItems': normalizedOfferedItems
          .map((item) => item.toMap())
          .toList(),
      'requestedItems': normalizedRequestedItems
          .map((item) => item.toMap())
          .toList(),
      'status': TradeStatus.pending.name,
      'lastProposedBy': sender,
      'awaitingUserId': receiver,
      'senderShipped': false,
      'senderReceived': false,
      'receiverShipped': false,
      'receiverReceived': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Stream<List<Trade>> watchIncomingTrades() {
    return _tradesReference
        .where('receiverId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_tradesFromSnapshot);
  }

  Stream<List<Trade>> watchOutgoingTrades() {
    return _tradesReference
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_tradesFromSnapshot);
  }

  Stream<int> watchActiveTradeCount() {
    final uid = _auth.currentUser?.uid.trim() ?? '';

    if (uid.isEmpty) {
      return Stream<int>.value(0);
    }

    late final StreamController<int> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? senderSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    receiverSubscription;

    var senderActiveIds = <String>{};
    var receiverActiveIds = <String>{};

    void emitCount() {
      if (controller.isClosed) {
        return;
      }

      controller.add({...senderActiveIds, ...receiverActiveIds}.length);
    }

    Set<String> activeIds(QuerySnapshot<Map<String, dynamic>> snapshot) {
      const activeStatuses = {'pending', 'countered', 'accepted'};

      return snapshot.docs
          .where(
            (document) =>
                activeStatuses.contains(document.data()['status']?.toString()),
          )
          .map((document) => document.id)
          .toSet();
    }

    controller = StreamController<int>(
      onListen: () {
        controller.add(0);

        senderSubscription = _tradesReference
            .where('senderId', isEqualTo: uid)
            .snapshots()
            .listen((snapshot) {
              senderActiveIds = activeIds(snapshot);
              emitCount();
            }, onError: controller.addError);

        receiverSubscription = _tradesReference
            .where('receiverId', isEqualTo: uid)
            .snapshots()
            .listen((snapshot) {
              receiverActiveIds = activeIds(snapshot);
              emitCount();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await senderSubscription?.cancel();
        await receiverSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Stream<int> watchCompletedTradeCount({required String userId}) {
    final uid = userId.trim();

    if (uid.isEmpty) {
      return Stream<int>.value(0);
    }

    late final StreamController<int> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? senderSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    receiverSubscription;

    var senderCompletedIds = <String>{};
    var receiverCompletedIds = <String>{};

    void emitCount() {
      if (controller.isClosed) {
        return;
      }

      controller.add({...senderCompletedIds, ...receiverCompletedIds}.length);
    }

    Set<String> completedIds(QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .where(
            (document) =>
                document.data()['status'] == TradeStatus.completed.name,
          )
          .map((document) => document.id)
          .toSet();
    }

    controller = StreamController<int>(
      onListen: () {
        controller.add(0);

        senderSubscription = _tradesReference
            .where('senderId', isEqualTo: uid)
            .snapshots()
            .listen((snapshot) {
              senderCompletedIds = completedIds(snapshot);
              emitCount();
            }, onError: controller.addError);

        receiverSubscription = _tradesReference
            .where('receiverId', isEqualTo: uid)
            .snapshots()
            .listen((snapshot) {
              receiverCompletedIds = completedIds(snapshot);
              emitCount();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await senderSubscription?.cancel();
        await receiverSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Future<TradeReservations> getActiveReservations({
    required String userId,
  }) async {
    final uid = userId.trim();

    if (uid.isEmpty) {
      throw ArgumentError('ID uporabnika ne sme biti prazen.');
    }

    final results = await Future.wait([
      _tradesReference.where('senderId', isEqualTo: uid).get(),
      _tradesReference.where('receiverId', isEqualTo: uid).get(),
    ]);

    final senderTrades = results[0].docs
        .map((document) => Trade.fromMap(document.id, document.data()))
        .toList(growable: false);

    final receiverTrades = results[1].docs
        .map((document) => Trade.fromMap(document.id, document.data()))
        .toList(growable: false);

    final acceptedTrades = <Trade>[
      ...senderTrades.where((trade) => trade.status == TradeStatus.accepted),
      ...receiverTrades.where((trade) => trade.status == TradeStatus.accepted),
    ];

    // Po izbrisu starega uporabniškega računa lahko zgodovinski dokument
    // sprejete menjave ostane v Firestore. Takšna menjava se ne more več
    // zaključiti in zato ne sme za vedno rezervirati kartic.
    final counterpartIds = acceptedTrades
        .map((trade) => _counterpartIdFor(trade: trade, userId: uid))
        .where((id) => id.isNotEmpty)
        .toSet();

    final counterpartSnapshots = await Future.wait(
      counterpartIds.map((id) => _db.collection('users').doc(id).get()),
    );

    final existingCounterpartIds = counterpartSnapshots
        .where((snapshot) => snapshot.exists)
        .map((snapshot) => snapshot.id)
        .toSet();

    bool canReserve(Trade trade) {
      final counterpartId = _counterpartIdFor(trade: trade, userId: uid);
      final counterpartExists = existingCounterpartIds.contains(counterpartId);

      if (!counterpartExists) {
        debugPrint(
          'Prezrta osirotela sprejeta menjava ${trade.id}: '
          'uporabnik $counterpartId ne obstaja več.',
        );
      }

      return counterpartExists;
    }

    final outgoing = <String, int>{};
    final incoming = <String, int>{};

    for (final trade in senderTrades) {
      if (trade.status != TradeStatus.accepted || !canReserve(trade)) {
        continue;
      }

      if (!trade.senderShipped) {
        _addItems(outgoing, trade.offeredItems);
      }

      if (!trade.senderReceived) {
        _addItems(incoming, trade.requestedItems);
      }
    }

    for (final trade in receiverTrades) {
      if (trade.status != TradeStatus.accepted || !canReserve(trade)) {
        continue;
      }

      if (!trade.receiverShipped) {
        _addItems(outgoing, trade.requestedItems);
      }

      if (!trade.receiverReceived) {
        _addItems(incoming, trade.offeredItems);
      }
    }

    return TradeReservations(
      outgoingByItem: outgoing,
      incomingByItem: incoming,
    );
  }

  Future<void> acceptTrade({required String tradeId}) async {
    await _respondToActiveOffer(
      tradeId: tradeId,
      newStatus: TradeStatus.accepted,
    );
  }

  Future<void> rejectTrade({required String tradeId}) async {
    await _respondToActiveOffer(
      tradeId: tradeId,
      newStatus: TradeStatus.rejected,
    );
  }

  Future<void> counterTrade({
    required String tradeId,
    required List<TradeItem> offeredItems,
    required List<TradeItem> requestedItems,
  }) async {
    if (offeredItems.isEmpty || requestedItems.isEmpty) {
      throw ArgumentError(
        'Protiponudba mora vsebovati predmete na obeh straneh.',
      );
    }

    _validateItems(offeredItems);
    _validateItems(requestedItems);

    final document = _tradesReference.doc(tradeId);

    final previewSnapshot = await document.get();
    final previewData = previewSnapshot.data();

    if (!previewSnapshot.exists || previewData == null) {
      throw Exception('Menjava ne obstaja.');
    }

    final previewTrade = Trade.fromMap(previewSnapshot.id, previewData);
    final previewUserId = currentUserId;
    final previewOtherUserId = previewTrade.senderId == previewUserId
        ? previewTrade.receiverId
        : previewTrade.senderId;

    await _blockService.ensureInteractionAllowed(
      otherUserId: previewOtherUserId,
    );

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Menjava ne obstaja.');
      }

      final trade = Trade.fromMap(snapshot.id, snapshot.data()!);
      final userId = currentUserId;

      _validateActiveResponder(trade, userId);

      final nextUserId = userId == trade.senderId
          ? trade.receiverId
          : trade.senderId;

      transaction.update(document, {
        'offeredItems': offeredItems.map((item) => item.toMap()).toList(),
        'requestedItems': requestedItems.map((item) => item.toMap()).toList(),
        'status': TradeStatus.countered.name,
        'lastProposedBy': userId,
        'awaitingUserId': nextUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelTrade({required String tradeId}) async {
    final document = _tradesReference.doc(tradeId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Menjava ne obstaja.');
      }

      final trade = Trade.fromMap(snapshot.id, snapshot.data()!);

      if (!trade.isAwaitingResponse) {
        throw Exception('Prekličeš lahko samo aktivno ponudbo.');
      }

      if (trade.lastProposedBy != currentUserId) {
        throw Exception(
          'Prekličeš lahko samo ponudbo, ki si jo nazadnje poslal.',
        );
      }

      transaction.update(document, {
        'status': TradeStatus.cancelled.name,
        'awaitingUserId': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> markShipped({required String tradeId}) async {
    final uid = currentUserId;
    final tradeRef = _tradesReference.doc(tradeId);
    final touchedCollections = <String>{};

    final previewSnapshot = await tradeRef.get();

    if (!previewSnapshot.exists || previewSnapshot.data() == null) {
      throw Exception('Menjava ne obstaja.');
    }

    final previewTrade = Trade.fromMap(
      previewSnapshot.id,
      previewSnapshot.data()!,
    );

    final canonicalItemIds = await _resolveCanonicalItemIds([
      ...previewTrade.offeredItems,
      ...previewTrade.requestedItems,
    ]);

    await _db.runTransaction((transaction) async {
      final tradeSnapshot = await transaction.get(tradeRef);

      if (!tradeSnapshot.exists || tradeSnapshot.data() == null) {
        throw Exception('Menjava ne obstaja.');
      }

      final trade = Trade.fromMap(tradeSnapshot.id, tradeSnapshot.data()!);

      if (trade.status != TradeStatus.accepted) {
        throw Exception('Poslati je mogoče samo sprejeto menjavo.');
      }

      final isSender = trade.senderId == uid;
      final isReceiver = trade.receiverId == uid;

      if (!isSender && !isReceiver) {
        throw Exception('Za to menjavo nimaš dovoljenja.');
      }

      // Idempotent guard: ponoven klik ne sme še enkrat odšteti inventarja.
      if ((isSender && trade.senderShipped) ||
          (isReceiver && trade.receiverShipped)) {
        return;
      }

      final outgoingItems = _withCanonicalItemIds(
        isSender ? trade.offeredItems : trade.requestedItems,
        canonicalItemIds,
      );

      for (final item in outgoingItems) {
        if (!item.hasItemId) {
          throw Exception(
            'Menjava vsebuje stare podatke brez itemId. '
            'Te menjave ni mogoče samodejno knjižiti.',
          );
        }
      }

      // POMEMBNO: v Firestore transakciji moramo najprej opraviti VSE reads.
      final itemSnapshots =
          <TradeItem, DocumentSnapshot<Map<String, dynamic>>>{};

      for (final item in outgoingItems) {
        final itemRef = _userItemReference(
          userId: uid,
          collectionId: item.collectionId,
          itemId: item.itemId,
        );

        itemSnapshots[item] = await transaction.get(itemRef);
      }

      // Šele po vseh reads izvedemo writes.
      for (final item in outgoingItems) {
        final itemRef = _userItemReference(
          userId: uid,
          collectionId: item.collectionId,
          itemId: item.itemId,
        );

        final itemSnapshot = itemSnapshots[item]!;
        final currentQuantity =
            (itemSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;

        if (currentQuantity < item.quantity) {
          throw Exception(
            'Predmeta ${item.itemNumber} nimaš več v zadostni količini.',
          );
        }

        final newQuantity = currentQuantity - item.quantity;

        if (newQuantity <= 0) {
          transaction.delete(itemRef);
        } else {
          transaction.set(itemRef, {
            'itemId': item.itemId,
            'quantity': newQuantity,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        touchedCollections.add(item.collectionId);
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isSender) {
        updates['senderShipped'] = true;
        updates['senderShippedAt'] = FieldValue.serverTimestamp();
      } else {
        updates['receiverShipped'] = true;
        updates['receiverShippedAt'] = FieldValue.serverTimestamp();
      }

      transaction.update(tradeRef, updates);
    });

    await _syncCollections(touchedCollections);
  }

  Future<void> markReceived({required String tradeId}) async {
    final uid = currentUserId;
    final tradeRef = _tradesReference.doc(tradeId);
    final touchedCollections = <String>{};

    final previewSnapshot = await tradeRef.get();

    if (!previewSnapshot.exists || previewSnapshot.data() == null) {
      throw Exception('Menjava ne obstaja.');
    }

    final previewTrade = Trade.fromMap(
      previewSnapshot.id,
      previewSnapshot.data()!,
    );

    final canonicalItemIds = await _resolveCanonicalItemIds([
      ...previewTrade.offeredItems,
      ...previewTrade.requestedItems,
    ]);

    await _db.runTransaction((transaction) async {
      final tradeSnapshot = await transaction.get(tradeRef);

      if (!tradeSnapshot.exists || tradeSnapshot.data() == null) {
        throw Exception('Menjava ne obstaja.');
      }

      final trade = Trade.fromMap(tradeSnapshot.id, tradeSnapshot.data()!);

      if (trade.status != TradeStatus.accepted) {
        throw Exception('Prejem je mogoče potrditi samo pri sprejeti menjavi.');
      }

      final isSender = trade.senderId == uid;
      final isReceiver = trade.receiverId == uid;

      if (!isSender && !isReceiver) {
        throw Exception('Za to menjavo nimaš dovoljenja.');
      }

      // Idempotent guard: ponoven klik ne sme še enkrat prišteti inventarja.
      if ((isSender && trade.senderReceived) ||
          (isReceiver && trade.receiverReceived)) {
        return;
      }

      final incomingItems = _withCanonicalItemIds(
        isSender ? trade.requestedItems : trade.offeredItems,
        canonicalItemIds,
      );

      for (final item in incomingItems) {
        if (!item.hasItemId) {
          throw Exception(
            'Menjava vsebuje stare podatke brez itemId. '
            'Te menjave ni mogoče samodejno knjižiti.',
          );
        }
      }

      // Najprej VSE reads.
      final itemSnapshots =
          <TradeItem, DocumentSnapshot<Map<String, dynamic>>>{};

      for (final item in incomingItems) {
        final itemRef = _userItemReference(
          userId: uid,
          collectionId: item.collectionId,
          itemId: item.itemId,
        );

        itemSnapshots[item] = await transaction.get(itemRef);
      }

      // Nato VSE writes.
      for (final item in incomingItems) {
        final itemRef = _userItemReference(
          userId: uid,
          collectionId: item.collectionId,
          itemId: item.itemId,
        );

        final itemSnapshot = itemSnapshots[item]!;
        final currentQuantity =
            (itemSnapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
        final newQuantity = currentQuantity + item.quantity;

        transaction.set(itemRef, {
          'itemId': item.itemId,
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        touchedCollections.add(item.collectionId);
      }

      final senderReceived = isSender ? true : trade.senderReceived;
      final receiverReceived = isReceiver ? true : trade.receiverReceived;

      final shouldComplete =
          trade.senderShipped &&
          trade.receiverShipped &&
          senderReceived &&
          receiverReceived;

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isSender) {
        updates['senderReceived'] = true;
        updates['senderReceivedAt'] = FieldValue.serverTimestamp();
      } else {
        updates['receiverReceived'] = true;
        updates['receiverReceivedAt'] = FieldValue.serverTimestamp();
      }

      if (shouldComplete) {
        updates['status'] = TradeStatus.completed.name;
      }

      transaction.update(tradeRef, updates);
    });

    await _syncCollections(touchedCollections);
  }

  Future<void> completeTrade({required String tradeId}) async {
    throw UnsupportedError(
      'Menjava se zdaj zaključi samodejno, ko oba uporabnika '
      'označita poslano in prejeto.',
    );
  }

  Future<void> _respondToActiveOffer({
    required String tradeId,
    required TradeStatus newStatus,
  }) async {
    final document = _tradesReference.doc(tradeId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Menjava ne obstaja.');
      }

      final trade = Trade.fromMap(snapshot.id, snapshot.data()!);
      _validateActiveResponder(trade, currentUserId);

      transaction.update(document, {
        'status': newStatus.name,
        'awaitingUserId': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  void _validateActiveResponder(Trade trade, String userId) {
    if (!trade.isAwaitingResponse) {
      throw Exception('Na to ponudbo je bilo že odgovorjeno.');
    }

    final expectedUserId = trade.awaitingUserId.isNotEmpty
        ? trade.awaitingUserId
        : trade.receiverId;

    if (expectedUserId != userId) {
      throw Exception('Trenutno nisi na potezi za to menjavo.');
    }
  }

  Future<void> _validateAvailableSurplus({
    required String userId,
    required List<TradeItem> items,
    required TradeInventorySide side,
  }) async {
    final reservations = await getActiveReservations(userId: userId);
    final itemsByCollection = <String, List<TradeItem>>{};

    for (final item in items) {
      itemsByCollection
          .putIfAbsent(item.collectionId, () => <TradeItem>[])
          .add(item);
    }

    for (final entry in itemsByCollection.entries) {
      final inventory = await _userItemService.getItemsMap(
        userId: userId,
        collectionId: entry.key,
      );

      for (final item in entry.value) {
        final storedQuantity =
            inventory[item.itemId]?.quantity ??
            inventory[item.itemNumber]?.quantity ??
            0;

        final reservedQuantity = reservations.outgoingQuantity(
          collectionId: item.collectionId,
          itemNumber: item.itemNumber,
        );

        final availableQuantity = storedQuantity - 1 - reservedQuantity;
        final safeAvailableQuantity = availableQuantity > 0
            ? availableQuantity
            : 0;

        if (safeAvailableQuantity < item.quantity) {
          throw TradeInventoryUnavailableException(
            side: side,
            itemNumber: item.itemNumber,
            requestedQuantity: item.quantity,
            availableQuantity: safeAvailableQuantity,
          );
        }
      }
    }
  }

  List<TradeItem> _mergeTradeItems(List<TradeItem> items) {
    final merged = <String, TradeItem>{};

    for (final item in items) {
      final key = '${item.collectionId.trim()}::${item.itemId.trim()}';
      final existing = merged[key];

      if (existing == null) {
        merged[key] = item;
      } else {
        merged[key] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
        );
      }
    }

    return merged.values.toList(growable: false);
  }

  Future<Map<String, String>> _resolveCanonicalItemIds(
    List<TradeItem> items,
  ) async {
    final itemsByCollection = <String, List<TradeItem>>{};

    for (final item in items) {
      final collectionId = item.collectionId.trim();

      if (collectionId.isEmpty) {
        continue;
      }

      itemsByCollection
          .putIfAbsent(collectionId, () => <TradeItem>[])
          .add(item);
    }

    final result = <String, String>{};

    for (final entry in itemsByCollection.entries) {
      final collectionId = entry.key;
      final catalogSnapshot = await _db
          .collection('catalogCollections')
          .doc(collectionId)
          .collection('items')
          .get();

      final validIds = <String>{};
      final idByNumber = <String, String>{};

      for (final document in catalogSnapshot.docs) {
        validIds.add(document.id);

        final number = document.data()['number']?.toString() ?? '';
        final normalizedNumber = number.trim().toLowerCase();

        if (normalizedNumber.isNotEmpty) {
          idByNumber.putIfAbsent(normalizedNumber, () => document.id);
        }
      }

      for (final item in entry.value) {
        final storedItemId = item.itemId.trim();
        String? canonicalId;

        if (storedItemId.isNotEmpty && validIds.contains(storedItemId)) {
          canonicalId = storedItemId;
        } else {
          canonicalId = idByNumber[item.itemNumber.trim().toLowerCase()];
        }

        if (canonicalId == null || canonicalId.isEmpty) {
          throw TradeCatalogItemUnavailableException(item.itemNumber);
        }

        result[_canonicalItemKey(item)] = canonicalId;
      }
    }

    return result;
  }

  List<TradeItem> _withCanonicalItemIds(
    List<TradeItem> items,
    Map<String, String> canonicalItemIds,
  ) {
    return items
        .map((item) {
          final canonicalId = canonicalItemIds[_canonicalItemKey(item)];

          if (canonicalId == null || canonicalId.isEmpty) {
            throw TradeCatalogItemUnavailableException(item.itemNumber);
          }

          return item.copyWith(itemId: canonicalId);
        })
        .toList(growable: false);
  }

  String _canonicalItemKey(TradeItem item) {
    return '${item.collectionId.trim()}::'
        '${item.itemNumber.trim().toLowerCase()}';
  }

  DocumentReference<Map<String, dynamic>> _userItemReference({
    required String userId,
    required String collectionId,
    required String itemId,
  }) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('collections')
        .doc(collectionId)
        .collection('items')
        .doc(itemId);
  }

  Future<void> _syncCollections(Set<String> collectionIds) async {
    for (final collectionId in collectionIds) {
      await _userItemService.syncCollectionMember(collectionId: collectionId);
    }
  }

  String _counterpartIdFor({required Trade trade, required String userId}) {
    if (trade.senderId == userId) {
      return trade.receiverId.trim();
    }

    if (trade.receiverId == userId) {
      return trade.senderId.trim();
    }

    return '';
  }

  void _addItems(Map<String, int> target, List<TradeItem> items) {
    for (final item in items) {
      // Stare testne menjave so nastale še pred uvedbo itemId.
      // Takih zapisov ne uporabljamo kot aktivne rezervacije,
      // ker jih ni mogoče zanesljivo povezati z inventarjem.
      if (!item.hasItemId) {
        continue;
      }

      final key = TradeReservations._key(item.collectionId, item.itemNumber);

      target[key] = (target[key] ?? 0) + item.quantity;
    }
  }

  List<Trade> _tradesFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((document) => Trade.fromMap(document.id, document.data()))
        .toList();
  }

  void _validateItems(List<TradeItem> items) {
    for (final item in items) {
      if (item.collectionId.trim().isEmpty) {
        throw ArgumentError('Vsak predmet mora imeti ID zbirke.');
      }

      if (item.itemNumber.trim().isEmpty) {
        throw ArgumentError('Vsak predmet mora imeti številko oziroma oznako.');
      }

      if (item.quantity <= 0) {
        throw ArgumentError('Količina predmeta mora biti večja od 0.');
      }
    }
  }
}
