import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// "Shot 2 of 3" / "Step 2 of 4" plus a segmented bar, so progress is
/// always both visible and spoken. Used by the photobooth and the Create
/// Quest flow. See design system §31.
class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.label,
    required this.current,
    required this.total,
    this.onDark = false,
  });

  /// e.g. "Shot" or "Step".
  final String label;

  /// Zero-based index of the current step.
  final int current;
  final int total;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final text = '$label ${current + 1} of $total';
    const done = AppColors.warmCoral;
    final todo = onDark ? AppColors.onCameraMuted : AppColors.softPeach;

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: onDark ? AppColors.onCamera : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < total; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: AppMotion.of(context, AppMotion.short),
                    curve: AppMotion.standard,
                    height: 4,
                    margin: EdgeInsets.only(
                      right: i == total - 1 ? 0 : AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: i <= current ? done : todo,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
