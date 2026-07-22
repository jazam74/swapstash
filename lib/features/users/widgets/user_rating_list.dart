import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade_rating.dart';
import 'package:swapstash/core/services/trade_rating_service.dart';

class UserRatingList extends StatelessWidget {
  final String userId;

  const UserRatingList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ratingService = TradeRatingService();

    return StreamBuilder<List<TradeRating>>(
      stream: ratingService.watchRatingsForUser(userId: userId, limit: 20),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _RatingStateCard(
            icon: Icons.error_outline_rounded,
            text: 'Komentarjev ocen ni bilo mogoče naložiti.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final ratings = (snapshot.data ?? const <TradeRating>[])
            .where((rating) => rating.comment.trim().isNotEmpty)
            .toList(growable: false);

        if (ratings.isEmpty) {
          return const _RatingStateCard(
            icon: Icons.rate_review_outlined,
            text: 'Ta zbiratelj še nima javnih komentarjev.',
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zadnji komentarji',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < ratings.length; index++) ...[
                  _RatingComment(rating: ratings[index]),
                  if (index < ratings.length - 1) const Divider(height: 24),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RatingComment extends StatelessWidget {
  final TradeRating rating;

  const _RatingComment({required this.rating});

  @override
  Widget build(BuildContext context) {
    final date = rating.createdAt.toDate().toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var value = 1; value <= 5; value++)
              Icon(
                value <= rating.stars
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 18,
              ),
            const Spacer(),
            Text(
              '${date.day}. ${date.month}. ${date.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(rating.comment.trim()),
      ],
    );
  }
}

class _RatingStateCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RatingStateCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
