import 'package:flutter/material.dart';

class CatalogProgress extends StatelessWidget {
  final int ownedCount;
  final int totalCount;

  const CatalogProgress({
    super.key,
    required this.ownedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalCount == 0 ? 0.0 : ownedCount / totalCount;

    final percent = (progress * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Napredek zbirke',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius:
                  BorderRadius.circular(8),
            ),
            const SizedBox(height: 12),
            Text(
              '$ownedCount / $totalCount ($percent%)',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}