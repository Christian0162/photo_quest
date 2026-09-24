import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../utils/app_haptics.dart';

/// "Photo · GIF · Boomerang · 360°" — picks how the next shot is captured.
/// Tap-only (no swipe, so it never fights the system back gesture), 48px
/// tall targets, and the chosen mode is bold with a dot, never color alone.
/// Sits over the camera. See design system §24, §52.
class CaptureModeSwitch<T> extends StatelessWidget {
  const CaptureModeSwitch({
    super.key,
    required this.modes,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> modes;
  final T selected;
  final String Function(T mode) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.short);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final mode in modes)
          Semantics(
            button: true,
            selected: mode == selected,
            label: '${labelOf(mode)} mode',
            excludeSemantics: true,
            child: InkResponse(
              radius: AppTouch.minTarget,
              onTap: mode == selected
                  ? null
                  : () {
                      AppHaptics.selection();
                      onChanged(mode);
                    },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppTouch.minTarget,
                  minWidth: AppTouch.minTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.ms,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: duration,
                        style: AppTypography.label.copyWith(
                          color: mode == selected
                              ? AppColors.onCamera
                              : AppColors.onCameraMuted,
                          fontWeight: mode == selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        child: Text(labelOf(mode)),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AnimatedOpacity(
                        duration: duration,
                        opacity: mode == selected ? 1 : 0,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.warmCoral,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox.square(dimension: 6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
