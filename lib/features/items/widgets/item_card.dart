import 'package:flutter/material.dart';
import 'package:swapstash/core/models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final bool isSaving;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const ItemCard({
    super.key,
    required this.item,
    required this.isSaving,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final String status;

    if (item.isMissing) {
      status = 'Manjka';
    } else if (item.hasDuplicates) {
      status = 'Viški: ${item.duplicateCount}';
    } else {
      status = 'Imam';
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '#${item.number}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    status,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Zmanjšaj količino',
                  visualDensity: VisualDensity.compact,
                  onPressed:
                      item.isMissing || isSaving ? null : onDecrease,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 34,
                  child: Center(
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Povečaj količino',
                  visualDensity: VisualDensity.compact,
                  onPressed: isSaving ? null : onIncrease,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}