import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../config/constant/app_colors.dart';

class ProgressRingPainter extends CustomPainter {
  const ProgressRingPainter({required this.progress});

  /// 1 = full ring, 0 = empty.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.onCameraMuted.withValues(alpha: 0.35),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.warmCoral,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter old) => old.progress != progress;
}
