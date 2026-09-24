import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// The moment the app opens. Picks up exactly where the native splash
/// leaves off — coral, with the icon's fanned prints — then the prints
/// fan open, the name and promise rise in, and the whole page melts away
/// into the app, which has been loading underneath the whole time.
///
/// ```text
///        ✦                 ✦
///     ╱▭╲ ┌──┐ ╱▭╲      ╱▭╲  ┌──┐  ╱▭╲
///         │♥ │     →        │♥ │         →   (app)
///         └──┘              └──┘
///                        Photo Quest
///               Do something together. Keep the memory.
/// ```
///
/// Best practice for launch screens: under two seconds, never blocks
/// loading, any tap skips it, and reduced motion skips it entirely. See
/// CLAUDE.md §2.5, §45, design system §48-50.
class LaunchReveal extends StatefulWidget {
  const LaunchReveal({super.key, required this.child});

  /// The app, built and loading beneath the reveal.
  final Widget child;

  /// Size of the prints artwork — the same 240 logical px as the native
  /// launch image, so the hand-off is seamless.
  static const artSize = 240.0;

  @override
  State<LaunchReveal> createState() => _LaunchRevealState();
}

class _LaunchRevealState extends State<LaunchReveal>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1800);

  /// When the outro starts; a tap jumps straight here.
  static const _outroAt = 0.78;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  )..addStatusListener(_onStatus);

  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_done || _controller.isAnimating) return;
    if (AppMotion.reduced(context)) {
      _done = true;
    } else {
      _controller.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status.isCompleted) setState(() => _done = true);
  }

  void _skip() {
    if (_controller.value < _outroAt) {
      _controller.forward(from: _outroAt);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// [t] mapped through [begin]..[end] of the timeline, eased.
  double _phase(double begin, double end, [Curve curve = Curves.easeOut]) {
    final t = ((_controller.value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _skip,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final open = _phase(0.05, 0.45, Curves.easeOutBack);
                  final lift = _phase(0.1, 0.5, Curves.easeOutCubic);
                  final words = _phase(0.3, 0.62, Curves.easeOutCubic);
                  final twinkle = math.sin(math.pi * _phase(0.2, 0.6));
                  final outro = _phase(_outroAt, 1, Curves.easeInCubic);

                  return Opacity(
                    opacity: 1 - outro,
                    child: Transform.scale(
                      scale: 1 + 0.06 * outro,
                      // Sits above the navigator, so it brings its own
                      // Material for text styling.
                      child: Material(
                        color: AppColors.warmCoral,
                        child: _Stage(
                          open: open,
                          lift: lift,
                          words: words,
                          twinkle: twinkle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The prints (centred, like the native splash) and the words below them.
class _Stage extends StatelessWidget {
  const _Stage({
    required this.open,
    required this.lift,
    required this.words,
    required this.twinkle,
  });

  final double open;
  final double lift;
  final double words;
  final double twinkle;

  /// How far the prints rise to make room for the name underneath.
  static const _rise = 56.0;

  /// The lowest visible edge of the fanned prints, below the art's centre.
  static const _artBottom = 74.0;

  /// Half the height of the name + promise block.
  static const _wordsHalfHeight = 36.0;

  @override
  Widget build(BuildContext context) {
    final rise = _rise * lift;

    return Semantics(
      label: 'Photo Quest',
      container: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -rise),
            child: SizedBox.square(
              dimension: LaunchReveal.artSize,
              child: _Prints(open: open, twinkle: twinkle),
            ),
          ),
          Transform.translate(
            offset: Offset(
              0,
              _artBottom -
                  rise +
                  AppSpacing.lg +
                  _wordsHalfHeight +
                  12 * (1 - words),
            ),
            child: Opacity(
              opacity: words,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Photo Quest',
                      style: AppTypography.display.copyWith(
                        color: AppColors.onCoral,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Do something together. Keep the memory.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.onCoral,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The icon's three prints, drawn to the same geometry as the launch
/// image and app icon (`assets/icon/app_icon.png`). [open] fans the side
/// prints further out; [twinkle] makes the sparkles glint.
class _Prints extends StatelessWidget {
  const _Prints({required this.open, required this.twinkle});

  final double open;
  final double twinkle;

  // Geometry as fractions of the art size, matching the icon.
  static const _printWidth = 0.34;
  static const _spread = 0.19;
  static const _sideDrop = 0.035;
  static const _tilt = 14 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    const size = LaunchReveal.artSize;
    const w = size * _printWidth;
    final spread = size * _spread * (1 + 0.18 * open);
    final tilt = _tilt * (1 + 0.35 * open);
    const center = Offset(size / 2, size / 2 + size * 0.02);

    Widget at(Offset c, Widget child) =>
        Positioned(left: c.dx - w / 2, top: c.dy - w * 1.25 / 2, child: child);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        at(
          center + Offset(-spread, size * _sideDrop),
          Transform.rotate(angle: -tilt, child: const _Print(front: false)),
        ),
        at(
          center + Offset(spread, size * _sideDrop),
          Transform.rotate(angle: tilt, child: const _Print(front: false)),
        ),
        at(center - Offset(0, 6 * open), const _Print(front: true)),
        _Sparkle(
          center: center + const Offset(size * 0.28, -size * 0.31),
          radius: size * 0.065 * (1 + 0.3 * twinkle),
          color: AppColors.filmYellow,
        ),
        _Sparkle(
          center: center + const Offset(-size * 0.30, -size * 0.27),
          radius: size * 0.035 * (1 + 0.5 * twinkle),
          color: AppColors.warmCream,
        ),
      ],
    );
  }
}

class _Print extends StatelessWidget {
  const _Print({required this.front});

  final bool front;

  @override
  Widget build(BuildContext context) {
    const w = LaunchReveal.artSize * _Prints._printWidth;
    return Container(
      width: w,
      height: w * 1.25,
      padding: const EdgeInsets.all(w * 0.07),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(w * 0.09),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40252323),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: front ? AppColors.warmCharcoal : AppColors.softPeach,
          borderRadius: BorderRadius.circular(w * 0.06),
        ),
        child: front
            ? const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  size: w * 0.5,
                  color: AppColors.warmCoral,
                ),
              )
            : null,
      ),
    );
  }
}

/// A four-point star, like the icon's.
class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.center,
    required this.radius,
    required this.color,
  });

  final Offset center;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - radius,
      top: center.dy - radius,
      child: CustomPaint(
        size: Size.square(radius * 2),
        painter: _SparklePainter(color),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final inner = r * 0.28;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = math.pi / 4 * i - math.pi / 2;
      final radius = i.isEven ? r : inner;
      final point = Offset(
        r + radius * math.cos(angle),
        r + radius * math.sin(angle),
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}
