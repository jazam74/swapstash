class TradeItem {
  final String collectionId;
  final int itemNumber;
  final int quantity;

  const TradeItem({
    required this.collectionId,
    required this.itemNumber,
    required this.quantity,
  });

  factory TradeItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return TradeItem(
      collectionId: map['collectionId'] as String? ?? '',
      itemNumber: map['itemNumber'] as int? ?? 0,
      quantity: map['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'itemNumber': itemNumber,
      'quantity': quantity,
    };
  }

  TradeItem copyWith({
    String? collectionId,
    int? itemNumber,
    int? quantity,
  }) {
    return TradeItem(
      collectionId: collectionId ?? this.collectionId,
      itemNumber: itemNumber ?? this.itemNumber,
      quantity: quantity ?? this.quantity,
    );
  }
}