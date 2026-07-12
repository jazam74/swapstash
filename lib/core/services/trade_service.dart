import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_item.dart';

class TradeService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>>
      get _tradesReference {
    return _db.collection('trades');
  }

  Future<String> createTrade({
    required String receiverId,
    required List<TradeItem> offeredItems,
    required List<TradeItem> requestedItems,
  }) async {
    final trimmedReceiverId = receiverId.trim();
    final senderId = currentUserId;

    if (trimmedReceiverId.isEmpty) {
      throw ArgumentError(
        'Prejemnik menjave ni določen.',
      );
    }

    if (trimmedReceiverId == senderId) {
      throw ArgumentError(
        'Menjave ne moreš poslati samemu sebi.',
      );
    }

    if (offeredItems.isEmpty) {
      throw ArgumentError(
        'Dodati moraš vsaj en ponujen predmet.',
      );
    }

    if (requestedItems.isEmpty) {
      throw ArgumentError(
        'Dodati moraš vsaj en želen predmet.',
      );
    }

    _validateItems(offeredItems);
    _validateItems(requestedItems);

    final document = _tradesReference.doc();

    await document.set({
      'senderId': senderId,
      'receiverId': trimmedReceiverId,
      'offeredItems': offeredItems
          .map((item) => item.toMap())
          .toList(),
      'requestedItems': requestedItems
          .map((item) => item.toMap())
          .toList(),
      'status': TradeStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Stream<List<Trade>> watchIncomingTrades() {
    return _tradesReference
        .where(
          'receiverId',
          isEqualTo: currentUserId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(_tradesFromSnapshot);
  }

  Stream<List<Trade>> watchOutgoingTrades() {
    return _tradesReference
        .where(
          'senderId',
          isEqualTo: currentUserId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(_tradesFromSnapshot);
  }

  Future<void> acceptTrade({
    required String tradeId,
  }) {
    return _updateIncomingTradeStatus(
      tradeId: tradeId,
      status: TradeStatus.accepted,
    );
  }

  Future<void> rejectTrade({
    required String tradeId,
  }) {
    return _updateIncomingTradeStatus(
      tradeId: tradeId,
      status: TradeStatus.rejected,
    );
  }

  Future<void> completeTrade({
    required String tradeId,
  }) async {
    final document = _tradesReference.doc(tradeId);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw Exception('Menjava ne obstaja.');
    }

    final trade = Trade.fromMap(
      snapshot.id,
      snapshot.data()!,
    );

    final userId = currentUserId;

    if (trade.senderId != userId &&
        trade.receiverId != userId) {
      throw Exception(
        'Za to menjavo nimaš dovoljenja.',
      );
    }

    if (trade.status != TradeStatus.accepted) {
      throw Exception(
        'Zaključiti je mogoče samo sprejeto menjavo.',
      );
    }

    await document.update({
      'status': TradeStatus.completed.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelTrade({
    required String tradeId,
  }) async {
    final document = _tradesReference.doc(tradeId);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw Exception('Menjava ne obstaja.');
    }

    final trade = Trade.fromMap(
      snapshot.id,
      snapshot.data()!,
    );

    if (trade.senderId != currentUserId) {
      throw Exception(
        'Prekličeš lahko samo svojo poslano menjavo.',
      );
    }

    if (trade.status != TradeStatus.pending) {
      throw Exception(
        'Prekličeš lahko samo čakajočo menjavo.',
      );
    }

    await document.update({
      'status': TradeStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateIncomingTradeStatus({
    required String tradeId,
    required TradeStatus status,
  }) async {
    final document = _tradesReference.doc(tradeId);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw Exception('Menjava ne obstaja.');
    }

    final trade = Trade.fromMap(
      snapshot.id,
      snapshot.data()!,
    );

    if (trade.receiverId != currentUserId) {
      throw Exception(
        'Za to menjavo nimaš dovoljenja.',
      );
    }

    if (trade.status != TradeStatus.pending) {
      throw Exception(
        'Na to menjavo je bilo že odgovorjeno.',
      );
    }

    await document.update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  List<Trade> _tradesFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(
          (document) => Trade.fromMap(
            document.id,
            document.data(),
          ),
        )
        .toList();
  }

  void _validateItems(
    List<TradeItem> items,
  ) {
    for (final item in items) {
      if (item.collectionId.trim().isEmpty) {
        throw ArgumentError(
          'Vsak predmet mora imeti ID zbirke.',
        );
      }

      if (item.itemNumber <= 0) {
        throw ArgumentError(
          'Številka predmeta mora biti večja od 0.',
        );
      }

      if (item.quantity <= 0) {
        throw ArgumentError(
          'Količina predmeta mora biti večja od 0.',
        );
      }
    }
  }
}