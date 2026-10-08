import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../utils/app_haptics.dart';

/// The small action at the end of a section header ("See all"). Its words
/// sit flush with the page gutter, like everything else on the page, while
/// the tap area stays a full 48px.
class MdSectionAction extends StatelessWidget {
  const MdSectionAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () {
          AppHaptics.selection();
          onPressed();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppTouch.minTarget,
            minHeight: AppTouch.minTarget,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: 1,
            child: Text(
              label,
              style: AppTypography.label.copyWith(color: AppColors.coralInk),
            ),
          ),
        ),
      ),
    );
  }
}
