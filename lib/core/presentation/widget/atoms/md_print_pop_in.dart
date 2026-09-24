import 'package:flutter/material.dart';
import '../../../../config/constant/app_motion.dart';

/// The just-taken photo pops out like a fresh print and settles at a small
/// tilt — a physical, photobooth moment. Static under reduced motion. See
/// design system §29-30, §49.
class PrintPopIn extends StatelessWidget {
  const PrintPopIn({super.key, required this.child});

  final Widget child;

  static const _restingTilt = -0.02;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.reveal,
      curve: AppMotion.emphasized,
      builder: (context, t, child) => Transform.rotate(
        angle: _restingTilt + (1 - t) * 0.08,
        child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
      ),
      child: child,
    );
  }
}
