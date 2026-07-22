class TradeRatingSummary {
  final double average;
  final int count;

  const TradeRatingSummary({required this.average, required this.count});

  const TradeRatingSummary.empty() : average = 0, count = 0;

  String get displayValue {
    if (count <= 0) {
      return 'Brez ocen';
    }

    final suffix = count == 1 ? 'ocena' : 'ocen';

    return '${average.toStringAsFixed(1)} / 5 ($count $suffix)';
  }
}
