import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapstash/core/models/trade_item.dart';

enum TradeStatus {
  pending,
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

  const Trade({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.offeredItems,
    required this.requestedItems,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Trade.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Trade(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      offeredItems: _tradeItemsFromData(
        map['offeredItems'],
      ),
      requestedItems: _tradeItemsFromData(
        map['requestedItems'],
      ),
      status: TradeStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => TradeStatus.pending,
      ),
      createdAt: _dateTimeFromData(
            map['createdAt'],
          ) ??
          DateTime.now(),
      updatedAt: _dateTimeFromData(
        map['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'offeredItems': offeredItems
          .map((item) => item.toMap())
          .toList(),
      'requestedItems': requestedItems
          .map((item) => item.toMap())
          .toList(),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null
          ? null
          : Timestamp.fromDate(updatedAt!),
    };
  }

  Trade copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    List<TradeItem>? offeredItems,
    List<TradeItem>? requestedItems,
    TradeStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trade(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      offeredItems: offeredItems ?? this.offeredItems,
      requestedItems:
          requestedItems ?? this.requestedItems,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<TradeItem> _tradeItemsFromData(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => TradeItem.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static DateTime? _dateTimeFromData(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}