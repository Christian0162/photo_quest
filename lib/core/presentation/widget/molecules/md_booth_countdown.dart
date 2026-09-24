import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../atoms/md_progress_ring_painter.dart';

/// The 3-2-1: a big number inside a ring that drains each second, with the
/// shot's instruction kept underneath so nobody forgets what to do. Tapping
/// anywhere cancels. See CLAUDE.md §34-35, design system §28.
class MdBoothCountdown extends StatelessWidget {
  const MdBoothCountdown({
    super.key,
    required this.value,
    required this.instruction,
    required this.onCancel,
  });

  final int value;
  final String instruction;
  final VoidCallback onCancel;

  static const _size = 200.0;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return Semantics(
      button: true,
      label: '$value. Tap to stop the countdown',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onCancel,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              SizedBox.square(
                dimension: _size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Keyed per beat so the ring restarts each second.
                    TweenAnimationBuilder<double>(
                      key: ValueKey(value),
                      tween: Tween(begin: 1, end: reduced ? 1 : 0),
                      duration: const Duration(seconds: 1),
                      builder: (context, t, _) => CustomPaint(
                        size: const Size.square(_size),
                        painter: MdProgressRingPainter(progress: t),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: AppMotion.of(context, AppMotion.short),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: Tween(begin: 1.4, end: 1.0).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: Text(
                        '$value',
                        key: ValueKey(value),
                        style: AppTypography.countdown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.onCamera,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Text(
                'Not ready? Tap anywhere to stop',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onCameraMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
