import 'package:cloud_firestore/cloud_firestore.dart';

class UserItem {
  final String itemId;
  final int quantity;
  final Timestamp updatedAt;

  bool get owned => quantity > 0;

  bool get hasDuplicates => quantity > 1;

  int get duplicateCount =>
      quantity > 1 ? quantity - 1 : 0;

  const UserItem({
    required this.itemId,
    required this.quantity,
    required this.updatedAt,
  });

  factory UserItem.fromMap(
    String itemId,
    Map<String, dynamic> map,
  ) {
    final quantity =
        (map['quantity'] as num?)?.toInt() ?? 0;

    return UserItem(
      itemId: itemId,
      quantity: quantity,
      updatedAt:
          map['updatedAt'] as Timestamp? ??
          Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'updatedAt': updatedAt,
    };
  }

  UserItem copyWith({
    String? itemId,
    int? quantity,
    Timestamp? updatedAt,
  }) {
    return UserItem(
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}