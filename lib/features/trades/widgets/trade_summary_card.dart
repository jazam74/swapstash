import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';
import 'package:swapstash/shared/widgets/app_card.dart';

class TradeSummaryCard extends StatelessWidget {
  final Trade trade;
  final String currentUserId;
  final String otherUserLabel;

  const TradeSummaryCard({
    super.key,
    required this.trade,
    required this.currentUserId,
    required this.otherUserLabel,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final isSender = trade.senderId == currentUserId;
    final outgoingItems = isSender ? trade.offeredItems : trade.requestedItems;
    final incomingItems = isSender ? trade.requestedItems : trade.offeredItems;

    final outgoingCount = outgoingItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final incomingCount = incomingItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final date = materialLocalizations.formatMediumDate(trade.createdAt);
    final time = materialLocalizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(trade.createdAt),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_outlined),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  localizations.tradeSummaryTitle,
                  style: AppTextStyles.subtitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(localizations.tradeWith, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(otherUserLabel, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text('$date, $time', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  icon: Icons.upload_rounded,
                  label: localizations.tradeYouGive,
                  value: outgoingCount,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryValue(
                  icon: Icons.download_rounded,
                  label: localizations.tradeYouReceive,
                  value: incomingCount,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _SummaryValue({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            localizations.tradeCardsCount(value),
            style: AppTextStyles.title,
          ),
        ],
      ),
    );
  }
}
