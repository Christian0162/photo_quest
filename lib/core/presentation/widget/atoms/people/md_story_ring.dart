import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';

/// A gradient ring around an avatar, like an unseen story: it says "there's
/// something here waiting for you". While [active] the ring turns slowly
/// (still under reduced motion); otherwise it is a quiet hairline. The ring
/// is a second cue next to the label under it, never the only one.
class MdStoryRing extends StatefulWidget {
  const MdStoryRing({
    super.key,
    required this.size,
    required this.child,
    this.active = true,
  });

  final double size;
  final Widget child;
  final bool active;

  static const _ring = 3.0;
  static const _gap = 3.0;

  static double innerSize(double size) => size - 2 * (_ring + _gap);

  @override
  State<MdStoryRing> createState() => _MdStoryRingState();
}

class _MdStoryRingState extends State<MdStoryRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  @override
  void didUpdateWidget(MdStoryRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  void _syncSpin() {
    if (widget.active && !AppMotion.reduced(context)) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const inset = MdStoryRing._ring + MdStoryRing._gap;

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _spin,
            builder: (context, _) => Transform.rotate(
              angle: _spin.value * 2 * math.pi,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.active
                      ? const SweepGradient(
                          colors: [
                            AppColors.warmCoral,
                            AppColors.filmYellow,
                            AppColors.warmCoral,
                          ],
                        )
                      : null,
                  color: widget.active ? null : AppColors.line,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(MdStoryRing._ring),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: SizedBox.expand(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(inset),
            child: ClipOval(child: widget.child),
          ),
        ],
      ),
    );
  }
}
