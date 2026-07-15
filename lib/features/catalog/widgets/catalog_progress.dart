import 'package:flutter/material.dart';
import 'package:swapstash/core/models/collection_stats.dart';

class CatalogProgress extends StatelessWidget {
  final CollectionStats stats;
  final int totalCount;

  const CatalogProgress({
    super.key,
    required this.stats,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = stats.progress(totalCount);
    final percent = (progress * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Napredek zbirke',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 12),
            Text(
              '${stats.owned} / $totalCount ($percent%)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _StatRow(
              icon: Icons.check_circle,
              label: 'Imam',
              value: stats.owned.toString(),
              color: Colors.green,
            ),
            _StatRow(
              icon: Icons.cancel,
              label: 'Manjka',
              value: stats.missing(totalCount).toString(),
              color: Colors.red,
            ),
            _StatRow(
              icon: Icons.swap_horiz,
              label: 'Viški',
              value: stats.duplicates.toString(),
              color: Colors.orange,
            ),
            _StatRow(
              icon: Icons.inventory_2,
              label: 'Skupaj kosov',
              value: stats.totalQuantity.toString(),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}