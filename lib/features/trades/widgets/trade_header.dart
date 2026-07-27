import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/features/trades/models/trade_display_status.dart';
import 'package:swapstash/features/trades/widgets/trade_status_badge.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class TradeHeader extends StatelessWidget {
  final TradeDisplayStatus status;
  final String directionLabel;

  const TradeHeader({
    super.key,
    required this.status,
    required this.directionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(status.icon, color: status.color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  directionLabel,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TradeStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(status.title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(status.subtitle, style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: status.progress,
              minHeight: 7,
              backgroundColor: Colors.white,
              color: status.color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppLocalizations.of(
              context,
            )!.tradeCompletedSteps(status.completedSteps, 4),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
