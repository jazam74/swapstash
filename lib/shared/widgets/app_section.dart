import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';

class AppSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final Widget? trailing;
  final double spacing;

  const AppSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.spacing = AppSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(child: Text(title, style: AppTextStyles.title)),
            if (trailing != null) ...[trailing!],
          ],
        ),
        SizedBox(height: spacing),
        child,
      ],
    );
  }
}
