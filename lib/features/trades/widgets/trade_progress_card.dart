import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';

class TradeProgressCard extends StatelessWidget {
  final Trade trade;
  final String currentUserId;

  const TradeProgressCard({
    super.key,
    required this.trade,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = trade.senderId == currentUserId;

    final myHandedOver = isSender ? trade.senderShipped : trade.receiverShipped;
    final otherHandedOver = isSender
        ? trade.receiverShipped
        : trade.senderShipped;
    final myReceived = isSender ? trade.senderReceived : trade.receiverReceived;
    final otherReceived = isSender
        ? trade.receiverReceived
        : trade.senderReceived;

    final steps = <_ProgressStep>[
      const _ProgressStep(
        label: 'Menjava dogovorjena',
        icon: Icons.handshake_outlined,
        done: true,
      ),
      _ProgressStep(
        label: 'Predal sem kartice',
        icon: Icons.how_to_reg_outlined,
        done: myHandedOver,
      ),
      _ProgressStep(
        label: 'Druga stran je predala kartice',
        icon: Icons.swap_horiz,
        done: otherHandedOver,
      ),
      _ProgressStep(
        label: 'Prejel sem kartice',
        icon: Icons.inventory_2_outlined,
        done: myReceived,
      ),
      _ProgressStep(
        label: 'Druga stran je prejela kartice',
        icon: Icons.done_all,
        done: otherReceived,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Potek menjave', style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < steps.length; index++) ...[
            _ProgressRow(step: steps[index]),
            if (index < steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 11),
                child: Container(
                  width: 2,
                  height: 14,
                  color: steps[index].done
                      ? AppColors.success.withValues(alpha: 0.45)
                      : AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final _ProgressStep step;

  const _ProgressRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final color = step.done ? AppColors.success : AppColors.disabled;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: step.done
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.chipBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            step.done ? Icons.check : step.icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            step.label,
            style: AppTextStyles.body.copyWith(
              color: step.done
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: step.done ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressStep {
  final String label;
  final IconData icon;
  final bool done;

  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.done,
  });
}
