import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String number;
  final int quantity;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.number,
    required this.quantity,
    this.onTap,
  });

  bool get _owned => quantity > 0;

  bool get _hasDuplicates => quantity > 1;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _owned
        ? Colors.green.shade50
        : Theme.of(context).colorScheme.surfaceContainerLow;

    final foregroundColor = _owned
        ? Colors.green.shade800
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      elevation: 1,
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                _owned
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: foregroundColor,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                _hasDuplicates
                    ? '×$quantity'
                    : _owned
                        ? 'Imam'
                        : 'Nimam',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}