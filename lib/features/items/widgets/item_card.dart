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
    final Color backgroundColor;
    final Color foregroundColor;
    final IconData statusIcon;
    final String status;

    if (item.isMissing) {
      backgroundColor = Colors.red.shade50;
      foregroundColor = Colors.red.shade700;
      statusIcon = Icons.remove_circle_outline;
      status = 'Manjka';
    } else if (item.hasDuplicates) {
      backgroundColor = Colors.orange.shade50;
      foregroundColor = Colors.orange.shade800;
      statusIcon = Icons.swap_horiz;
      status = 'Viški: ${item.duplicateCount}';
    } else {
      backgroundColor = Colors.green.shade50;
      foregroundColor = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline;
      status = 'Imam';
    }

    final imagePath = 'assets/items/${item.number}.jpg';

    return Card(
      margin: EdgeInsets.zero,
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.55),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 42,
                          color: foregroundColor.withValues(
                            alpha: 0.65,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  statusIcon,
                  size: 20,
                  color: foregroundColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '#${item.number}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: foregroundColor,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    status,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
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
                  width: 36,
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
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: foregroundColor,
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