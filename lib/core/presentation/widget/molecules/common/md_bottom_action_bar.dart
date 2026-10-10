import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';

/// Pins a screen's primary action to the bottom so it's always one thumb
/// away, above the home indicator.
class MdBottomActionBar extends StatelessWidget {
  const MdBottomActionBar({super.key, required this.child, this.sheet = false});

  final Widget child;

  /// Draws the bar as a rounded sheet rising over a coloured page, instead of
  /// a flat bar with a hairline on top.
  final bool sheet;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: sheet
            ? null
            : const Border(top: BorderSide(color: AppColors.line)),
        borderRadius: sheet
            ? const BorderRadius.vertical(top: Radius.circular(AppRadius.base))
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            sheet ? AppSpacing.lg : AppSpacing.ms,
            AppSpacing.gutter,
            AppSpacing.md,
          ),
          child: child,
        ),
      ),
    );
  }
}
