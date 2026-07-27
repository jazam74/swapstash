import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/features/dashboard/models/dashboard_action.dart';
import 'package:swapstash/features/dashboard/widgets/dashboard_action_tile.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';
import 'package:swapstash/shared/widgets/app_card.dart';

class DashboardActionsCard extends StatelessWidget {
  final List<DashboardAction> actions;

  const DashboardActionsCard({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final visibleActions = actions.take(5).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  localizations.dashboardTodayTasks,
                  style: AppTextStyles.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (visibleActions.isEmpty)
            const _NoActionsView()
          else
            Column(
              children: [
                for (var index = 0; index < visibleActions.length; index++) ...[
                  DashboardActionTile(action: visibleActions[index]),
                  if (index < visibleActions.length - 1)
                    const Divider(height: AppSpacing.sm),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _NoActionsView extends StatelessWidget {
  const _NoActionsView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.success),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.dashboardAllDone,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                localizations.dashboardNoOpenTasks,
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
