import 'package:flutter/material.dart';

class ItemStatistics extends StatelessWidget {
  final int ownedCount;
  final int duplicateCount;
  final int missingCount;
  final int totalItems;

  const ItemStatistics({
    super.key,
    required this.ownedCount,
    required this.duplicateCount,
    required this.missingCount,
    required this.totalItems,
  });

  Widget _summaryCard({
    required String label,
    required int value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        totalItems == 0 ? 0.0 : ownedCount / totalItems;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              _summaryCard(
                label: 'Zbranih',
                value: ownedCount,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              _summaryCard(
                label: 'Viški',
                value: duplicateCount,
                icon: Icons.swap_horiz,
              ),
              const SizedBox(width: 8),
              _summaryCard(
                label: 'Manjka',
                value: missingCount,
                icon: Icons.remove_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 6),
          Text(
            '$ownedCount od $totalItems zbranih predmetov',
          ),
        ],
      ),
    );
  }
}