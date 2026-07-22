import 'package:cloud_firestore/cloud_firestore.dart';

class TradeRating {
  final String id;
  final String tradeId;
  final String reviewerId;
  final String reviewedUserId;
  final int stars;
  final String comment;
  final Timestamp createdAt;

  const TradeRating({
    required this.id,
    required this.tradeId,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  factory TradeRating.fromMap(String id, Map<String, dynamic> map) {
    return TradeRating(
      id: id,
      tradeId: map['tradeId']?.toString() ?? '',
      reviewerId: map['reviewerId']?.toString() ?? '',
      reviewedUserId: map['reviewedUserId']?.toString() ?? '',
      stars: (map['stars'] as num?)?.toInt() ?? 0,
      comment: map['comment']?.toString() ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tradeId': tradeId,
      'reviewerId': reviewerId,
      'reviewedUserId': reviewedUserId,
      'stars': stars,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
