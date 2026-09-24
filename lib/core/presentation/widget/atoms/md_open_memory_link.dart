import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// "Open memory ›" at the foot of a memory card. The whole card is
/// tappable; this just says so. Decorative for screen readers.
class OpenMemoryLink extends StatelessWidget {
  const OpenMemoryLink({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Open memory',
            style: AppTypography.label.copyWith(color: AppColors.coralInk),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: AppIconSizes.md,
            color: AppColors.coralInk,
          ),
        ],
      ),
    );
  }
}
