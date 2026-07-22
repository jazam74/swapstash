import 'package:flutter/material.dart';
import 'package:swapstash/core/services/trade_rating_service.dart';

class TradeRatingDialogResult {
  final int stars;
  final String comment;

  const TradeRatingDialogResult({required this.stars, required this.comment});
}

class TradeRatingDialog extends StatefulWidget {
  const TradeRatingDialog({super.key});

  static Future<TradeRatingDialogResult?> show(BuildContext context) {
    return showDialog<TradeRatingDialogResult>(
      context: context,
      builder: (_) => const TradeRatingDialog(),
    );
  }

  @override
  State<TradeRatingDialog> createState() => _TradeRatingDialogState();
}

class _TradeRatingDialogState extends State<TradeRatingDialog> {
  final TextEditingController _commentController = TextEditingController();

  int _stars = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Oceni uporabnika'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kako si zadovoljen z opravljeno menjavo?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var value = 1; value <= 5; value++)
                  IconButton(
                    tooltip: '$value od 5',
                    onPressed: () {
                      setState(() {
                        _stars = value;
                      });
                    },
                    icon: Icon(
                      value <= _stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 34,
                    ),
                  ),
              ],
            ),
            Text('$_stars / 5', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLength: TradeRatingService.maximumCommentLength,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Komentar (neobvezno)',
                hintText: 'Npr. hiter dogovor in odlično ohranjene kartice.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Prekliči'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(
              TradeRatingDialogResult(
                stars: _stars,
                comment: _commentController.text.trim(),
              ),
            );
          },
          icon: const Icon(Icons.star_rounded),
          label: const Text('Oddaj oceno'),
        ),
      ],
    );
  }
}
