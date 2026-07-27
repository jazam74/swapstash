import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/models/trade_rating.dart';
import 'package:swapstash/core/services/trade_rating_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class TradeRatingSection extends StatefulWidget {
  final Trade trade;

  const TradeRatingSection({super.key, required this.trade});

  @override
  State<TradeRatingSection> createState() => _TradeRatingSectionState();
}

class _TradeRatingSectionState extends State<TradeRatingSection> {
  final TradeRatingService _ratingService = TradeRatingService();
  final TextEditingController _commentController = TextEditingController();

  int _selectedStars = 0;
  bool _isSubmitting = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _startEditing(TradeRating rating) {
    setState(() {
      _selectedStars = rating.stars;
      _commentController.text = rating.comment;
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _selectedStars = 0;
      _commentController.clear();
      _isEditing = false;
    });
  }

  Future<void> _save(TradeRating? existingRating) async {
    final localizations = AppLocalizations.of(context)!;

    if (_isSubmitting) {
      return;
    }

    if (_selectedStars < 1 || _selectedStars > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.tradeRatingSelectStars)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updated = await _ratingService.saveRating(
        trade: widget.trade,
        stars: _selectedStars,
        comment: _commentController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedStars = 0;
        _commentController.clear();
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated
                ? localizations.tradeRatingUpdatedSuccessfully
                : localizations.tradeRatingSubmittedSuccessfully,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.tradeRatingSubmitError(error.toString())),
        ),
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
    final localizations = AppLocalizations.of(context)!;

    return StreamBuilder<TradeRating?>(
      stream: _ratingService.watchMyRatingForTrade(trade: widget.trade),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _RatingCard(
            child: Row(
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 10),
                Expanded(child: Text(localizations.tradeRatingUnavailable)),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _RatingCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final existingRating = snapshot.data;

        if (existingRating != null && !_isEditing) {
          return _buildSavedRating(context, localizations, existingRating);
        }

        return _buildForm(context, localizations, existingRating);
      },
    );
  }

  Widget _buildSavedRating(
    BuildContext context,
    AppLocalizations localizations,
    TradeRating rating,
  ) {
    return _RatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.tradeRatingYourRating,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ReadOnlyStars(stars: rating.stars),
          if (rating.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(rating.comment.trim()),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _startEditing(rating),
              icon: const Icon(Icons.edit_outlined),
              label: Text(localizations.tradeRatingEdit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations localizations,
    TradeRating? existingRating,
  ) {
    final isUpdate = existingRating != null;

    return _RatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.tradeRatingTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(localizations.tradeRatingQuestion),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final value = index + 1;
              final selected = value <= _selectedStars;

              return IconButton(
                tooltip: '$value',
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _selectedStars = value;
                        });
                      },
                iconSize: 34,
                icon: Icon(
                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            enabled: !_isSubmitting,
            maxLength: TradeRatingService.maximumCommentLength,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: localizations.tradeRatingCommentHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isUpdate) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : _cancelEditing,
                    child: Text(localizations.cancel),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: isUpdate ? 2 : 1,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : () => _save(existingRating),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.star_rounded),
                  label: Text(
                    _isSubmitting
                        ? (isUpdate
                              ? localizations.tradeRatingUpdating
                              : localizations.tradeSubmittingRating)
                        : (isUpdate
                              ? localizations.tradeRatingSaveChanges
                              : localizations.tradeSubmitRating),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final Widget child;

  const _RatingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _ReadOnlyStars extends StatelessWidget {
  final int stars;

  const _ReadOnlyStars({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < stars ? Icons.star_rounded : Icons.star_border_rounded,
          size: 24,
        ),
      ),
    );
  }
}
