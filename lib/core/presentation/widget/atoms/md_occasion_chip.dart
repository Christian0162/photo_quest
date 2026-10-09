import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// A small tag on a memory: "Anniversary", "Birthday", "For Us", "3 of
/// us". Icon plus word, so it never relies on the icon alone.
class MdOccasionChip extends StatelessWidget {
  const MdOccasionChip({
    super.key,
    required this.label,
    required this.icon,
    this.color = AppColors.softPeach,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.ms,
        vertical: AppSpacing.xs + AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.sm, color: AppColors.coralInk),
          const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              style: AppTypography.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
