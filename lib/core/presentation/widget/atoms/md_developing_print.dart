import 'package:flutter/material.dart';
import '../../../../config/constant/app_colors.dart';

/// An instant print developing: starts washed-out and grey, ends in full
/// color. [progress] runs 0 → 1.
class DevelopingPrint extends StatelessWidget {
  const DevelopingPrint({super.key, required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (progress >= 1) return child;

    final s = progress; // saturation, 0 = greyscale
    final wash = (1 - progress) * 0.55; // white haze on top
    const r = 0.2126, g = 0.7152, b = 0.0722;
    final matrix = <double>[
      r + (1 - r) * s, g - g * s, b - b * s, 0, 0, //
      r - r * s, g + (1 - g) * s, b - b * s, 0, 0, //
      r - r * s, g - g * s, b + (1 - b) * s, 0, 0, //
      0, 0, 0, 1, 0,
    ];

    return Stack(
      children: [
        ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child),
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: AppColors.warmCream.withValues(alpha: wash),
            ),
          ),
        ),
      ],
    );
  }
}
