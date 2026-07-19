class TradeItem {
  final String collectionId;

  /// Dejanski ID dokumenta kataloškega predmeta (npr. "0004").
  /// Pri starejših menjavah je lahko prazen.
  final String itemId;

  /// Prikazna številka/oznaka predmeta (npr. "004", "LE1", "ARG-10").
  final String itemNumber;

  final int quantity;

  const TradeItem({
    required this.collectionId,
    this.itemId = '',
    required this.itemNumber,
    required this.quantity,
  });

  factory TradeItem.fromMap(Map<String, dynamic> map) {
    return TradeItem(
      collectionId: map['collectionId'] as String? ?? '',
      itemId: map['itemId'] as String? ?? '',
      // Združljivost s starejšimi Firestore zapisi, kjer je bil itemNumber int.
      itemNumber: map['itemNumber']?.toString() ?? '',
      quantity: map['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'itemId': itemId,
      'itemNumber': itemNumber,
      'quantity': quantity,
    };
  }

  bool get hasItemId => itemId.trim().isNotEmpty;

  TradeItem copyWith({
    String? collectionId,
    String? itemId,
    String? itemNumber,
    int? quantity,
  }) {
    return TradeItem(
      collectionId: collectionId ?? this.collectionId,
      itemId: itemId ?? this.itemId,
      itemNumber: itemNumber ?? this.itemNumber,
      quantity: quantity ?? this.quantity,
    );
  }
}
