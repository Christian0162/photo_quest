import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import 'pressable_scale.dart';

/// The app's primary call-to-action. Large, warm, one per screen. Shows an
/// inline spinner (and ignores taps) while [loading]. See CLAUDE.md §64,
/// design system §46, §58.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final button = FilledButton(
      onPressed: enabled ? onPressed : null,
      child: _ButtonContent(
        label: label,
        icon: icon,
        loading: loading,
        spinnerColor: AppColors.onCoral,
      ),
    );

    return PressableScale(
      enabled: enabled,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// The quieter companion to [PrimaryButton]: Retake, Decline, Back, Cancel.
/// See design system §46.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.onDark = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  /// For use over the camera preview.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: onDark
          ? OutlinedButton.styleFrom(
              foregroundColor: AppColors.onCamera,
              backgroundColor: AppColors.cameraScrim,
              side: const BorderSide(color: AppColors.onCameraMuted),
            )
          : OutlinedButton.styleFrom(backgroundColor: AppColors.paper),
      child: _ButtonContent(label: label, icon: icon),
    );

    return PressableScale(
      enabled: onPressed != null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.icon,
    this.loading = false,
    this.spinnerColor,
  });

  final String label;
  final IconData? icon;
  final bool loading;
  final Color? spinnerColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SizedBox.square(
              dimension: AppIconSizes.md,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: spinnerColor,
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Icon(icon, size: AppIconSizes.md),
          ),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
