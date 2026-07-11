import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final int itemNumber;
  final int quantity;
  final bool isSaving;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const ItemCard({
    super.key,
    required this.itemNumber,
    required this.quantity,
    required this.isSaving,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final String status;

    if (quantity == 0) {
      status = 'Manjka';
    } else if (quantity == 1) {
      status = 'Imam';
    } else {
      status = 'Viški: ${quantity - 1}';
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
                  '#$itemNumber',
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
                  visualDensity: VisualDensity.compact,
                  onPressed:
                      quantity == 0 || isSaving ? null : onDecrease,
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
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                IconButton.filled(
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