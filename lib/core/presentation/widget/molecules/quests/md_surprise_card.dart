import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../utils/app_haptics.dart';
import '../common/md_app_card.dart';

/// "Can't decide?" as a yellow card with a dice that really rolls: it
/// tumbles, ticks under your thumb, and only then hands over the surprise.
/// The wait is the fun part. Under reduced motion it answers straight away.
class MdSurpriseCard extends StatefulWidget {
  const MdSurpriseCard({super.key, required this.onRoll});

  final VoidCallback onRoll;

  @override
  State<MdSurpriseCard> createState() => _MdSurpriseCardState();
}

class _MdSurpriseCardState extends State<MdSurpriseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _roll = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _turns = CurvedAnimation(
    parent: _roll,
    curve: Curves.easeOutCubic,
  );
  int _lastTick = 0;

  @override
  void dispose() {
    _roll.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    if (_roll.isAnimating) return;
    if (AppMotion.reduced(context)) {
      widget.onRoll();
      return;
    }
    _lastTick = 0;
    _roll.addListener(_tick);
    await _roll.forward(from: 0);
    _roll.removeListener(_tick);
    if (!mounted) return;
    AppHaptics.success();
    widget.onRoll();
  }

  /// Six ticks as the dice slows down.
  void _tick() {
    final step = (_turns.value * 6).floor();
    if (step != _lastTick) {
      _lastTick = step;
      AppHaptics.tick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      color: AppColors.filmYellow,
      radius: AppRadius.xl,
      onTap: _tap,
      semanticLabel: "Can't decide? Surprise me",
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _turns,
            builder: (context, child) => Transform.rotate(
              angle: _turns.value * 3 * math.pi,
              child: Transform.scale(
                scale: 1 + 0.25 * math.sin(_turns.value * math.pi),
                child: child,
              ),
            ),
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.paper,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.casino_rounded, size: AppIconSizes.xl),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Can't decide? Surprise me",
                  style: AppTypography.heading3,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'We will pick one for you.',
                  style: AppTypography.bodyMuted.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded),
        ],
      ),
    );
  }
}
