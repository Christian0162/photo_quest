import 'package:flutter/material.dart';

import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';

/// Eases its child up and in once, when first shown. Give sibling sections
/// increasing [order]s for a short stagger that guides the eye down the
/// screen. Shown instantly under reduced motion. See design system §48-50.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.order = 0});

  final Widget child;

  /// Position in the stagger; each step waits a little longer.
  final int order;

  /// Cascades a page's content in, top first. The first child is the
  /// page's hero photo and stays put, so it never fights a hero flight.
  /// Spacers count too, which keeps the rhythm even.
  static List<Widget> staggered(List<Widget> children) => [
    for (final (index, child) in children.indexed)
      index == 0 ? child : FadeSlideIn(order: (index + 1) ~/ 2, child: child),
  ];

  /// Delay between staggered items, capped so long lists never feel slow.
  static const _step = Duration(milliseconds: 60);
  static const _maxOrder = 6;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final delay =
        FadeSlideIn._step * widget.order.clamp(0, FadeSlideIn._maxOrder);
    final total = delay + AppMotion.medium;
    _controller = AnimationController(vsync: this, duration: total);
    // One controller, no timers: the delay is the start of the interval.
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: AppMotion.standard,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _progress.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _progress.value) * AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}
