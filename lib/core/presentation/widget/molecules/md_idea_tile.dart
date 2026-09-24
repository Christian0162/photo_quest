import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import 'md_app_card.dart';

/// A half-width "other ways in" card: an icon badge, a title and one line.
class MdIdeaTile extends StatelessWidget {
  const MdIdeaTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      color: color,
      radius: AppRadius.xl,
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color == AppColors.paper
                  ? AppColors.sunken
                  : AppColors.paper,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppIconSizes.md),
          ),
          const SizedBox(height: AppSpacing.ms),
          Text(title, style: AppTypography.heading3),
          const SizedBox(height: AppSpacing.xxs),
          Text(subtitle, style: AppTypography.caption),
        ],
      ),
    );
  }
}
