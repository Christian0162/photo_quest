import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';

/// A round, translucent control that stays legible over any camera frame
/// (close, flip camera). Always 48px and always labeled. See design system
/// §24, §52.
class CameraIconButton extends StatelessWidget {
  const CameraIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.cameraScrim,
        foregroundColor: AppColors.onCamera,
        disabledForegroundColor: AppColors.onCameraMuted,
        fixedSize: const Size.square(AppTouch.minTarget),
      ),
    );
  }
}
