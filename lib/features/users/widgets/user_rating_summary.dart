import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade_rating_summary.dart';
import 'package:swapstash/core/services/trade_rating_service.dart';

class UserRatingSummary extends StatelessWidget {
  final String userId;

  const UserRatingSummary({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ratingService = TradeRatingService();

    return StreamBuilder<TradeRatingSummary>(
      stream: ratingService.watchRatingSummary(userId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _RatingSummaryContent(
            value: '—',
            label: 'Ocena ni na voljo',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _RatingSummaryContent(
            value: '...',
            label: 'Nalagam ocene',
          );
        }

        final summary = snapshot.data ?? const TradeRatingSummary.empty();

        if (summary.count <= 0) {
          return const _RatingSummaryContent(value: '—', label: 'Brez ocen');
        }

        final label = summary.count == 1 ? '1 ocena' : '${summary.count} ocen';

        return _RatingSummaryContent(
          value: summary.average.toStringAsFixed(1),
          label: label,
        );
      },
    );
  }
}

class _RatingSummaryContent extends StatelessWidget {
  final String value;
  final String label;

  const _RatingSummaryContent({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.star_rounded),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
