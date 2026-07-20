import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_radius.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/shared/widgets/app_card.dart';

class AppLoadingCard extends StatelessWidget {
  final int lines;

  const AppLoadingCard({super.key, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingBar(widthFactor: 0.48, height: 18),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < lines; index++) ...[
            _LoadingBar(widthFactor: index == lines - 1 ? 0.62 : 1, height: 12),
            if (index < lines - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  final double widthFactor;
  final double height;

  const _LoadingBar({required this.widthFactor, required this.height});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}
