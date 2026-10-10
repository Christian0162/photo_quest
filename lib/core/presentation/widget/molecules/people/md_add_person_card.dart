import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../molecules/common/md_app_card.dart';

class MdAddPersonCard extends StatelessWidget {
  const MdAddPersonCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      onTap: onTap,
      color: AppColors.sunken,
      elevated: false,
      radius: AppRadius.base,
      semanticLabel: 'Add someone. Partner, family, friends or pets.',
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.paper,
            foregroundColor: AppColors.textPrimary,
            child: Icon(Icons.add_rounded),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add someone', style: AppTypography.heading3),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Partner, family, friends — or pets.',
                  style: AppTypography.bodyMuted,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
