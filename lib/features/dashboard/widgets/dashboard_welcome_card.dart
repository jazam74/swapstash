import 'package:flutter/material.dart';
import 'package:swapstash/core/theme/app_colors.dart';
import 'package:swapstash/core/theme/app_spacing.dart';
import 'package:swapstash/core/theme/app_text_styles.dart';
import 'package:swapstash/shared/widgets/app_card.dart';

class DashboardWelcomeCard extends StatelessWidget {
  const DashboardWelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.primary,
      borderColor: AppColors.primary,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(Icons.waving_hand_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dobrodošel!',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pregled tvojih zbirk in aktivnosti.',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
