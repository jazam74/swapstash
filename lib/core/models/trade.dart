import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/core/models/trade_item.dart';

enum TradeStatus {
  pending,
  countered,
  accepted,
  rejected,
  completed,
  cancelled,
}

class Trade {
  final String id;
  final String senderId;
  final String receiverId;
  final List<TradeItem> offeredItems;
  final List<TradeItem> requestedItems;
  final TradeStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String lastProposedBy;
  final String awaitingUserId;
  final bool senderShipped;
  final bool senderReceived;
  final bool receiverShipped;
  final bool receiverReceived;
  final DateTime? senderShippedAt;
  final DateTime? senderReceivedAt;
  final DateTime? receiverShippedAt;
  final DateTime? receiverReceivedAt;

  const Trade({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.offeredItems,
    required this.requestedItems,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.lastProposedBy,
    required this.awaitingUserId,
    this.senderShipped = false,
    this.senderReceived = false,
    this.receiverShipped = false,
    this.receiverReceived = false,
    this.senderShippedAt,
    this.senderReceivedAt,
    this.receiverShippedAt,
    this.receiverReceivedAt,
  });

  factory Trade.fromMap(String id, Map<String, dynamic> map) {
    final senderId = map['senderId'] as String? ?? '';
    final receiverId = map['receiverId'] as String? ?? '';
    final status = TradeStatus.values.firstWhere(
      (value) => value.name == map['status'],
      orElse: () => TradeStatus.pending,
    );

    return Trade(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      offeredItems: _tradeItemsFromData(map['offeredItems']),
      requestedItems: _tradeItemsFromData(map['requestedItems']),
      status: status,
      createdAt: _dateTimeFromData(map['createdAt']) ?? DateTime.now(),
      updatedAt: _dateTimeFromData(map['updatedAt']),
      lastProposedBy: map['lastProposedBy'] as String? ?? senderId,
      awaitingUserId:
          map['awaitingUserId'] as String? ??
          (status == TradeStatus.pending ? receiverId : ''),
      senderShipped: map['senderShipped'] as bool? ?? false,
      senderReceived: map['senderReceived'] as bool? ?? false,
      receiverShipped: map['receiverShipped'] as bool? ?? false,
      receiverReceived: map['receiverReceived'] as bool? ?? false,
      senderShippedAt: _dateTimeFromData(map['senderShippedAt']),
      senderReceivedAt: _dateTimeFromData(map['senderReceivedAt']),
      receiverShippedAt: _dateTimeFromData(map['receiverShippedAt']),
      receiverReceivedAt: _dateTimeFromData(map['receiverReceivedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'offeredItems': offeredItems.map((item) => item.toMap()).toList(),
      'requestedItems': requestedItems.map((item) => item.toMap()).toList(),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'lastProposedBy': lastProposedBy,
      'awaitingUserId': awaitingUserId,
      'senderShipped': senderShipped,
      'senderReceived': senderReceived,
      'receiverShipped': receiverShipped,
      'receiverReceived': receiverReceived,
      'senderShippedAt': senderShippedAt == null
          ? null
          : Timestamp.fromDate(senderShippedAt!),
      'senderReceivedAt': senderReceivedAt == null
          ? null
          : Timestamp.fromDate(senderReceivedAt!),
      'receiverShippedAt': receiverShippedAt == null
          ? null
          : Timestamp.fromDate(receiverShippedAt!),
      'receiverReceivedAt': receiverReceivedAt == null
          ? null
          : Timestamp.fromDate(receiverReceivedAt!),
    };
  }

  bool get isAwaitingResponse =>
      status == TradeStatus.pending || status == TradeStatus.countered;

  bool get allShippingStepsCompleted =>
      senderShipped && senderReceived && receiverShipped && receiverReceived;

  static List<TradeItem> _tradeItemsFromData(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => TradeItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static DateTime? _dateTimeFromData(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
