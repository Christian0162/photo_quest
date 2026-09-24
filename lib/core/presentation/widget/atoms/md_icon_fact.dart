import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// A small muted icon + word fact: "The two of us", "4 photos".
class MdIconFact extends StatelessWidget {
  const MdIconFact({
    super.key,
    required this.icon,
    required this.label,
    this.style,
  });

  final IconData icon;
  final String label;

  /// Defaults to a muted [AppTypography.label].
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSizes.sm, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style:
              style ?? AppTypography.label.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
