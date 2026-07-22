import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_rating.dart';
import 'package:swapstash/core/models/trade_rating_summary.dart';

class TradeRatingService {
  static const int maximumCommentLength = 300;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  TradeRatingService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Uporabnik ni prijavljen.');
    }

    return user.uid;
  }

  Stream<TradeRating?> watchMyRatingForTrade({required Trade trade}) {
    final reviewerId = _currentUserId;
    final reviewedUserId = _resolveReviewedUserId(
      trade: trade,
      reviewerId: reviewerId,
    );

    return _ratingReference(
      tradeId: trade.id,
      reviewerId: reviewerId,
      reviewedUserId: reviewedUserId,
    ).snapshots().map((document) {
      final data = document.data();

      if (!document.exists || data == null) {
        return null;
      }

      return TradeRating.fromMap(document.id, data);
    });
  }

  Stream<TradeRatingSummary> watchRatingSummary({required String userId}) {
    final id = userId.trim();

    if (id.isEmpty) {
      return Stream<TradeRatingSummary>.value(const TradeRatingSummary.empty());
    }

    return _db
        .collection('users')
        .doc(id)
        .collection('ratings')
        .snapshots()
        .map((snapshot) {
          var totalStars = 0;
          var ratingCount = 0;

          for (final document in snapshot.docs) {
            final rating = TradeRating.fromMap(document.id, document.data());

            if (rating.stars < 1 || rating.stars > 5) {
              continue;
            }

            totalStars += rating.stars;
            ratingCount++;
          }

          if (ratingCount == 0) {
            return const TradeRatingSummary.empty();
          }

          return TradeRatingSummary(
            average: totalStars / ratingCount,
            count: ratingCount,
          );
        });
  }

  Future<void> submitRating({
    required Trade trade,
    required int stars,
    String comment = '',
  }) async {
    if (stars < 1 || stars > 5) {
      throw ArgumentError('Ocena mora biti med 1 in 5.');
    }

    final normalizedComment = comment.trim();

    if (normalizedComment.length > maximumCommentLength) {
      throw ArgumentError(
        'Komentar ima lahko največ $maximumCommentLength znakov.',
      );
    }

    final reviewerId = _currentUserId;
    final tradeReference = _db.collection('trades').doc(trade.id);

    await _db.runTransaction((transaction) async {
      final tradeDocument = await transaction.get(tradeReference);
      final tradeData = tradeDocument.data();

      if (!tradeDocument.exists || tradeData == null) {
        throw StateError('Menjava ne obstaja.');
      }

      final currentTrade = Trade.fromMap(tradeDocument.id, tradeData);

      if (currentTrade.status != TradeStatus.completed) {
        throw StateError('Oceniti je mogoče samo zaključeno menjavo.');
      }

      final reviewedUserId = _resolveReviewedUserId(
        trade: currentTrade,
        reviewerId: reviewerId,
      );

      final ratingReference = _ratingReference(
        tradeId: currentTrade.id,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
      );

      final ratingDocument = await transaction.get(ratingReference);

      if (ratingDocument.exists) {
        throw StateError('To menjavo si že ocenil.');
      }

      final rating = TradeRating(
        id: ratingReference.id,
        tradeId: currentTrade.id,
        reviewerId: reviewerId,
        reviewedUserId: reviewedUserId,
        stars: stars,
        comment: normalizedComment,
        createdAt: Timestamp.now(),
      );

      transaction.set(ratingReference, rating.toMap());
    });
  }

  String _resolveReviewedUserId({
    required Trade trade,
    required String reviewerId,
  }) {
    if (trade.senderId == reviewerId) {
      if (trade.receiverId.trim().isEmpty) {
        throw StateError('Drugi uporabnik ni določen.');
      }

      return trade.receiverId;
    }

    if (trade.receiverId == reviewerId) {
      if (trade.senderId.trim().isEmpty) {
        throw StateError('Drugi uporabnik ni določen.');
      }

      return trade.senderId;
    }

    throw StateError('Ocenjuje lahko samo udeleženec menjave.');
  }

  DocumentReference<Map<String, dynamic>> _ratingReference({
    required String tradeId,
    required String reviewerId,
    required String reviewedUserId,
  }) {
    final ratingId = '${tradeId}_$reviewerId';

    return _db
        .collection('users')
        .doc(reviewedUserId)
        .collection('ratings')
        .doc(ratingId);
  }
}
