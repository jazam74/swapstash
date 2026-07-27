import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade_rating_summary.dart';
import 'package:swapstash/core/services/trade_rating_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class UserRatingSummary extends StatelessWidget {
  final String userId;
  final TextStyle? style;

  const UserRatingSummary({super.key, required this.userId, this.style});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return StreamBuilder<TradeRatingSummary>(
      stream: TradeRatingService().watchRatingSummary(userId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(localizations.ratingUnavailable, style: style);
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final summary = snapshot.data ?? const TradeRatingSummary.empty();

        if (!summary.hasRatings) {
          return Text(localizations.ratingNone, style: style);
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 18),
            const SizedBox(width: 4),
            Text(summary.average.toStringAsFixed(1), style: style),
            const SizedBox(width: 5),
            Text(
              '(${localizations.ratingCount(summary.count)})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
