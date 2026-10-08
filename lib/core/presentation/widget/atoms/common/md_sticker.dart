import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';

/// A short label stuck on the page like a die-cut sticker: a paper edge, a
/// slight tilt, and a wobbly pop when it lands. It replaces small caps
/// kickers so the screen feels handmade. Give neighbouring stickers
/// different [tilt]s and [delay]s. The pop is skipped under reduced motion.
class MdSticker extends StatelessWidget {
  const MdSticker({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.filmYellow,
    this.tilt = -0.05,
    this.delay = Duration.zero,
    this.sway = false,
  });

  final String label;
  final IconData? icon;
  final Color color;

  final double tilt;

  final Duration delay;

  /// Keeps rocking gently on its tilt after it lands.
  final bool sway;

  @override
  Widget build(BuildContext context) {
    final sticker = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.paper, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.ms,
          vertical: AppSpacing.xs + AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppIconSizes.sm, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                style: AppTypography.heading3.copyWith(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    if (AppMotion.reduced(context)) {
      return Transform.rotate(angle: tilt, child: sticker);
    }
    return _PopIn(tilt: tilt, delay: delay, sway: sway, child: sticker);
  }
}

class _PopIn extends StatefulWidget {
  const _PopIn({
    required this.tilt,
    required this.delay,
    required this.sway,
    required this.child,
  });

  final double tilt;
  final Duration delay;
  final bool sway;
  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pop;
  AnimationController? _sway;

  @override
  void initState() {
    super.initState();
    // The delay is the start of one interval, so there is no timer to leak.
    final total = widget.delay + AppMotion.pop;
    _controller = AnimationController(vsync: this, duration: total)
      ..forward().whenComplete(_startSway);
    _pop = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        widget.delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: AppMotion.spring,
      ),
    );
  }

  void _startSway() {
    if (!mounted || !widget.sway || AppMotion.reduced(context)) return;
    // Out of phase with its neighbours, so they rock like a row of stickers.
    _sway = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 1600 + widget.delay.inMilliseconds % 500,
      ),
    )..repeat(reverse: true);
    setState(() {});
  }

  @override
  void dispose() {
    _sway?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sway = _sway;
    return AnimatedBuilder(
      animation: Listenable.merge([_pop, ?sway]),
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: (_pop.value * 4).clamp(0, 1),
        child: Transform.rotate(
          // Lands from a wilder angle and settles on its tilt, then rocks.
          angle:
              widget.tilt * (1 + (1 - _pop.value) * 3) +
              (sway == null
                  ? 0
                  : (Curves.easeInOut.transform(sway.value) - 0.5) * 0.07),
          child: Transform.scale(scale: _pop.value.clamp(0, 1.4), child: child),
        ),
      ),
    );
  }
}
