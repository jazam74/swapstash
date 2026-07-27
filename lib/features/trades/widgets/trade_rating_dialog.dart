import 'package:flutter/material.dart';
import 'package:swapstash/core/services/trade_rating_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.tradeRateUser),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.tradeRatingQuestion,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var value = 1; value <= 5; value++)
                  IconButton(
                    tooltip: localizations.tradeStarsOutOfFive(value),
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
              decoration: InputDecoration(
                labelText: localizations.tradeOptionalComment,
                hintText: localizations.tradeCommentHint,
                border: const OutlineInputBorder(),
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
          child: Text(localizations.cancel),
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
          label: Text(localizations.tradeSubmitRating),
        ),
      ],
    );
  }
}
