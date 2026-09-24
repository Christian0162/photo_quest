import 'package:flutter/material.dart';
import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../atoms/progress_ring_painter.dart';

/// Making the GIF or boomerang: a ring filling up with the percentage in
/// the middle, so it's clear how long to wait.
class ProcessingProgress extends StatelessWidget {
  const ProcessingProgress({super.key, required this.progress, required this.message});

  final double progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    const size = AppTouch.captureButton;

    return Semantics(
      liveRegion: true,
      label: '$message $percent percent',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: AppMotion.of(context, AppMotion.short),
                    builder: (context, value, _) => CustomPaint(
                      size: const Size.square(size),
                      painter: ProgressRingPainter(progress: value),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.onCamera,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.onCamera),
            ),
          ],
        ),
      ),
    );
  }
}
