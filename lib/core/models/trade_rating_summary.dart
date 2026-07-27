class TradeRatingSummary {
  final double average;
  final int count;

  const TradeRatingSummary({required this.average, required this.count});

  const TradeRatingSummary.empty() : average = 0, count = 0;

  bool get hasRatings => count > 0;
}
