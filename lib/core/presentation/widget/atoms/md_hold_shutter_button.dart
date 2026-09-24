import 'package:flutter/material.dart';
import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../utils/app_haptics.dart';
import 'progress_ring_painter.dart';

/// The press-and-hold shutter for boomerangs and 360° clips: capturing
/// starts the moment it's pressed and finishes when it's let go (or the
/// ring fills). The ring shows how far along it is. Screen readers get a
/// plain tap that records hands-free to the full length. See design system
/// §29, §52-53.
class HoldShutterButton extends StatelessWidget {
  const HoldShutterButton({super.key, 
    required this.progress,
    required this.recording,
    required this.label,
    required this.onStart,
    required this.onEnd,
  });

  final double progress;
  final bool recording;
  final String label;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    const size = AppTouch.captureButton;

    return Semantics(
      button: true,
      label: recording
          ? 'Recording $label, ${(progress * 100).round()} percent'
          : 'Press and hold to record a $label',
      onTap: recording ? null : onStart,
      excludeSemantics: true,
      child: Listener(
        onPointerDown: (_) {
          if (recording) return;
          AppHaptics.shutter();
          onStart();
        },
        onPointerUp: (_) => onEnd(),
        onPointerCancel: (_) => onEnd(),
        child: AnimatedScale(
          scale: recording ? 1.12 : 1,
          duration: AppMotion.of(context, AppMotion.short),
          curve: AppMotion.standard,
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(size),
                  painter: ProgressRingPainter(progress: recording ? progress : 0),
                ),
                AnimatedContainer(
                  duration: AppMotion.of(context, AppMotion.short),
                  width: recording ? size * 0.36 : size * 0.72,
                  height: recording ? size * 0.36 : size * 0.72,
                  decoration: BoxDecoration(
                    color: AppColors.warmCoral,
                    borderRadius: BorderRadius.circular(
                      recording ? AppRadius.sm / 2 : size,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
