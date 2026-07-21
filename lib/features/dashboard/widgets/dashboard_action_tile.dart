import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/features/dashboard/models/dashboard_action.dart';

class DashboardActionTile extends StatelessWidget {
  final DashboardAction action;

  const DashboardActionTile({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Icon(action.icon, color: action.color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title, style: AppTextStyles.subtitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      action.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (action.onTap != null) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
