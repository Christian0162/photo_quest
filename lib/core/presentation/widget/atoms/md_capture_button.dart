import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../utils/app_haptics.dart';
import 'md_pressable_scale.dart';

/// The photobooth shutter: a big white ring around a coral button that
/// sinks when pressed, so taking the photo feels physical. See design
/// system §29, §52.
class MdCaptureButton extends StatelessWidget {
  const MdCaptureButton({
    super.key,
    required this.onPressed,
    this.semanticLabel = 'Take the photo',
  });

  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    const size = AppTouch.captureButton;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: MdPressableScale(
        enabled: onPressed != null,
        scale: 0.9,
        child: GestureDetector(
          onTap: onPressed == null
              ? null
              : () {
                  AppHaptics.tap();
                  onPressed!();
                },
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(AppSpacing.xs + AppSpacing.xxs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.onCamera, width: 4),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onPressed != null
                    ? AppColors.warmCoral
                    : AppColors.onCameraMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
