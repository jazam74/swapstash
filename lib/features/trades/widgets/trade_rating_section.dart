import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_rating.dart';
import 'package:swapstash/core/services/trade_rating_service.dart';
import 'package:swapstash/features/trades/widgets/trade_rating_dialog.dart';

class TradeRatingSection extends StatefulWidget {
  final Trade trade;

  const TradeRatingSection({super.key, required this.trade});

  @override
  State<TradeRatingSection> createState() => _TradeRatingSectionState();
}

class _TradeRatingSectionState extends State<TradeRatingSection> {
  final TradeRatingService _ratingService = TradeRatingService();

  bool _isSubmitting = false;

  Future<void> _rateUser() async {
    if (_isSubmitting) {
      return;
    }

    final result = await TradeRatingDialog.show(context);

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _ratingService.submitRating(
        trade: widget.trade,
        stars: result.stars,
        comment: result.comment,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocena je bila uspešno oddana.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocene ni bilo mogoče oddati: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TradeRating?>(
      stream: _ratingService.watchMyRatingForTrade(trade: widget.trade),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          final colorScheme = Theme.of(context).colorScheme;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, color: colorScheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ocenjevanje trenutno ni na voljo. '
                    'Preveri, ali so nova Firestore pravila objavljena.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final rating = snapshot.data;

        if (rating != null) {
          return _SubmittedRatingView(rating: rating);
        }

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _rateUser,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.star_outline_rounded),
            label: Text(
              _isSubmitting ? 'Oddajam oceno ...' : 'Oceni uporabnika',
            ),
          ),
        );
      },
    );
  }
}

class _SubmittedRatingView extends StatelessWidget {
  final TradeRating rating;

  const _SubmittedRatingView({required this.rating});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var value = 1; value <= 5; value++)
                Icon(
                  value <= rating.stars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 20,
                  color: colorScheme.tertiary,
                ),
              const SizedBox(width: 8),
              Text(
                '${rating.stars} / 5',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Icon(Icons.check_circle, size: 18, color: colorScheme.primary),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ocena je oddana.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (rating.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              rating.comment.trim(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
