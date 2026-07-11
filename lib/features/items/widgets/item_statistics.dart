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
    required BuildContext context,
    required String label,
    required int value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
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
    final progress = totalItems <= 0
        ? 0.0
        : (ownedCount / totalItems).clamp(0.0, 1.0);

    final progressPercent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.insights_outlined,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Napredek zbirke',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '$progressPercent %',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$ownedCount od $totalItems zbranih predmetov',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _summaryCard(
                context: context,
                label: 'Zbranih',
                value: ownedCount,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              _summaryCard(
                context: context,
                label: 'Viški',
                value: duplicateCount,
                icon: Icons.swap_horiz,
              ),
              const SizedBox(width: 8),
              _summaryCard(
                context: context,
                label: 'Manjka',
                value: missingCount,
                icon: Icons.remove_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}