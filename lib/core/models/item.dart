class Item {
  final int number;
  final int quantity;

  const Item({
    required this.number,
    required this.quantity,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      number: map['number'] as int? ?? 0,
      quantity: map['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'quantity': quantity,
    };
  }

  bool get isOwned => quantity > 0;

  bool get isMissing => quantity == 0;

  bool get hasDuplicates => quantity > 1;

  int get duplicateCount =>
      quantity > 1 ? quantity - 1 : 0;

  Item copyWith({
    int? number,
    int? quantity,
  }) {
    return Item(
      number: number ?? this.number,
      quantity: quantity ?? this.quantity,
    );
  }
}