import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';

/// A soft circle for header actions (settings, add). Paper by default;
/// pass coral colors when it is the page's main action.
class MdRoundIconButton extends StatelessWidget {
  const MdRoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor = AppColors.paper,
    this.foregroundColor = AppColors.textPrimary,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
      ),
      child: IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          minimumSize: const Size.square(AppTouch.minTarget),
        ),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}
