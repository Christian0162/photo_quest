import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';

/// "Open memory ›" at the foot of a memory card. The whole card is
/// tappable; this just says so. Decorative for screen readers.
class MdOpenMemoryLink extends StatelessWidget {
  const MdOpenMemoryLink({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? AppColors.filmYellow : AppColors.coralInk;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Open memory',
            style: AppTypography.label.copyWith(color: color),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: AppIconSizes.md,
            color: color,
          ),
        ],
      ),
    );
  }
}
