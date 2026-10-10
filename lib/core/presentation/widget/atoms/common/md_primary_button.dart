import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../utils/app_haptics.dart';
import 'md_pressable_scale.dart';

/// The app's primary call-to-action. Large, warm, one per screen. It sits
/// on a charcoal "lip" like a physical booth button: pressing sinks it into
/// the lip with a haptic tap, and it springs back on release. Shows an
/// inline spinner (and ignores taps) while [loading].
class MdPrimaryButton extends StatefulWidget {
  const MdPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.flat = false,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  /// Overrides the label colour (charcoal on coral by default).
  final Color? foregroundColor;

  /// Drops the charcoal lip (and the press-down motion) for a plain button.
  final bool flat;

  static const _lip = 4.0;

  @override
  State<MdPrimaryButton> createState() => _MdPrimaryButtonState();
}

class _MdPrimaryButtonState extends State<MdPrimaryButton> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final sunk =
        !widget.flat && _pressed && enabled && !AppMotion.reduced(context);

    final button = FilledButton(
      style: widget.foregroundColor == null
          ? null
          : FilledButton.styleFrom(foregroundColor: widget.foregroundColor),
      onPressed: enabled
          ? () {
              AppHaptics.tap();
              widget.onPressed!();
            }
          : null,
      child: _ButtonContent(
        label: widget.label,
        icon: widget.icon,
        loading: widget.loading,
        spinnerColor: widget.foregroundColor ?? AppColors.onCoral,
      ),
    );

    final lipped = Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedContainer(
        duration: AppMotion.micro,
        curve: sunk ? AppMotion.standard : AppMotion.spring,
        // A transform, not a margin: the spring curve overshoots, and a
        // margin that dips below zero fails Container's assertion.
        transform: Matrix4.translationValues(
          0,
          sunk ? MdPrimaryButton._lip : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.base),
          boxShadow: widget.flat
              ? null
              : [
                  BoxShadow(
                    color: enabled ? AppColors.warmCharcoal : AppColors.line,
                    offset: Offset(0, sunk ? 0 : MdPrimaryButton._lip),
                  ),
                ],
        ),
        child: button,
      ),
    );

    final padded = Padding(
      padding: EdgeInsets.only(bottom: widget.flat ? 0 : MdPrimaryButton._lip),
      child: lipped,
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: padded)
        : padded;
  }
}

/// The quieter companion to [MdPrimaryButton]: Retake, Decline, Back, Cancel.
class MdSecondaryButton extends StatelessWidget {
  const MdSecondaryButton({
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

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              AppHaptics.selection();
              onPressed!();
            },
      style: onDark
          ? OutlinedButton.styleFrom(
              foregroundColor: AppColors.onCamera,
              backgroundColor: AppColors.cameraScrim,
              side: const BorderSide(color: AppColors.onCameraMuted),
            )
          : OutlinedButton.styleFrom(backgroundColor: AppColors.paper),
      child: _ButtonContent(label: label, icon: icon),
    );

    return MdPressableScale(
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
