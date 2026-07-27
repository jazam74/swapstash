import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade_rating.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/core/services/trade_rating_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class UserRatingList extends StatelessWidget {
  final String userId;
  final int limit;
  final bool showTitle;

  const UserRatingList({
    super.key,
    required this.userId,
    this.limit = 10,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<TradeRating>>(
          stream: TradeRatingService().watchRatings(
            userId: userId,
            limit: limit,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _MessageRow(
                icon: Icons.error_outline,
                message: localizations.ratingCommentsLoadError,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _MessageRow(
                icon: Icons.hourglass_top,
                message: localizations.ratingLoading,
                loading: true,
              );
            }

            final ratings = snapshot.data ?? const <TradeRating>[];

            if (ratings.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTitle) ...[
                    Text(
                      localizations.ratingReviewsTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _MessageRow(
                    icon: Icons.star_outline,
                    message: localizations.ratingNoReviews,
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle) ...[
                  Text(
                    localizations.ratingReviewsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                for (var index = 0; index < ratings.length; index++) ...[
                  _RatingEntry(rating: ratings[index]),
                  if (index < ratings.length - 1) const Divider(height: 24),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RatingEntry extends StatelessWidget {
  final TradeRating rating;

  const _RatingEntry({required this.rating});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final date = MaterialLocalizations.of(
      context,
    ).formatShortDate(rating.createdAt.toDate());

    return FutureBuilder<UserProfile?>(
      future: FirestoreService().getUserProfile(rating.reviewerId),
      builder: (context, snapshot) {
        final displayName = snapshot.data?.displayName.trim();
        final reviewer = displayName == null || displayName.isEmpty
            ? localizations.unknownUser
            : displayName;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person_outline, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    reviewer,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < rating.stars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 20,
                ),
              ),
            ),
            if (rating.comment.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(rating.comment.trim()),
            ],
          ],
        );
      },
    );
  }
}

class _MessageRow extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool loading;

  const _MessageRow({
    required this.icon,
    required this.message,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (loading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(icon),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    );
  }
}
