import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

enum StatusTone { waiting, positive, neutral }

/// A small icon + word status ("Waiting", "Joined"). Always carries text
/// and an icon so status never depends on color alone. See CLAUDE.md §65,
/// design system §39.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.icon,
    this.tone = StatusTone.neutral,
  });

  final String label;
  final IconData icon;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      StatusTone.waiting => (AppColors.filmYellow, AppColors.textPrimary),
      StatusTone.positive => (AppColors.successSurface, AppColors.successInk),
      StatusTone.neutral => (AppColors.sunken, AppColors.textPrimary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.sm, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          // Shrinks with an ellipsis instead of overflowing in tight rows or
          // at large text sizes.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
