import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// The moment the app opens. Picks up from the native splash (coral plus the
/// vector logo): the prints grow and fan open, the name is written out in
/// cursive underneath, the promise fades in, and the whole page melts away
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
/// Best practice for launch screens: short, never blocks loading, any tap
/// skips it, and reduced motion shows it still. See
/// CLAUDE.md §2.5, §45, design system §48-50.
class MdLaunchReveal extends StatefulWidget {
  const MdLaunchReveal({super.key, required this.child});

  /// The app, built and loading beneath the reveal.
  final Widget child;

  /// Size of the prints artwork in logical px.
  static const artSize = 240.0;

  @override
  State<MdLaunchReveal> createState() => _MdLaunchRevealState();
}

class _MdLaunchRevealState extends State<MdLaunchReveal>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 4400);
  static const _reducedDuration = Duration(milliseconds: 1400);

  /// When the outro starts; a tap jumps straight here.
  static const _outroAt = 0.84;

  /// The longest slice the first real frame may advance the reveal. The app
  /// is built underneath while this starts, and a slow first frame must not
  /// make the animation leap ahead before anyone has seen it.
  static const _maxFrameStep = Duration(milliseconds: 50);

  /// 0..1 through the whole reveal.
  final _progress = ValueNotifier<double>(0);

  late final Ticker _ticker = createTicker(_onTick);
  Duration _total = _duration;
  Duration _lastElapsed = Duration.zero;
  bool _startupStepSpent = false;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_done || _ticker.isActive) return;
    // Reduced motion shows a still logo and name, then a plain fade — the
    // launch screen is the app's identity, so it is never skipped outright.
    if (AppMotion.reduced(context)) _total = _reducedDuration;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    var step = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    // Only the startup hitch is forgiven; later slow frames still count, so
    // the reveal never outlasts its real-time duration on a slow phone.
    if (!_startupStepSpent && step > Duration.zero) {
      _startupStepSpent = true;
      if (step > _maxFrameStep) step = _maxFrameStep;
    }
    final next = _progress.value + step.inMicroseconds / _total.inMicroseconds;
    if (next >= 1) {
      _ticker.stop();
      setState(() => _done = true);
    } else {
      _progress.value = next;
    }
  }

  void _skip() {
    if (_progress.value < _outroAt) _progress.value = _outroAt;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _progress.dispose();
    super.dispose();
  }

  /// [t] mapped through [begin]..[end] of the timeline, eased.
  double _phase(double begin, double end, [Curve curve = Curves.easeOut]) {
    final t = ((_progress.value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;

    final still = AppMotion.reduced(context);

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
                animation: _progress,
                builder: (context, _) {
                  final appear = still
                      ? 1.0
                      : _phase(0, 0.09, Curves.easeOutCubic);
                  final open = still
                      ? 1.0
                      : _phase(0.015, 0.13, Curves.easeOutBack);
                  final lift = still
                      ? 1.0
                      : _phase(0.03, 0.14, Curves.easeOutCubic);
                  final write = still
                      ? 1.0
                      : _phase(0.15, 0.6, Curves.easeInOutSine);
                  final promise = still
                      ? 1.0
                      : _phase(0.58, 0.7, Curves.easeOut);
                  // Seconds into the reveal; drives the endless sparkle pulse.
                  final clock = still
                      ? 0.0
                      : _progress.value * _duration.inMilliseconds / 1000;
                  // The light sweep crosses the prints once, left to right.
                  final shine = still
                      ? 2.0
                      : -1 + 2 * _phase(0.05, 0.21, Curves.easeInOut);
                  final outro = _phase(_outroAt, 1, Curves.easeInCubic);

                  return Opacity(
                    opacity: 1 - outro,
                    child: Transform.scale(
                      scale: still ? 1 : 1 + 0.06 * outro,
                      // Sits above the navigator, so it brings its own
                      // Material for text styling.
                      child: Material(
                        color: AppColors.warmCoral,
                        child: _Stage(
                          appear: appear,
                          open: open,
                          lift: lift,
                          write: write,
                          promise: promise,
                          clock: clock,
                          shine: shine,
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
    required this.appear,
    required this.open,
    required this.lift,
    required this.write,
    required this.promise,
    required this.clock,
    required this.shine,
  });

  final double appear;
  final double open;
  final double lift;

  /// 0..1 — how much of the name has been written, left to right.
  final double write;
  final double promise;
  final double clock;
  final double shine;

  /// How far the prints rise to make room for the name underneath.
  static const _rise = 56.0;

  /// The lowest visible edge of the fanned prints, below the art's centre.
  static const _artBottom = 74.0;

  /// Half the height of the name + promise block.
  static const _wordsHalfHeight = 40.0;

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
            // Starts at the native splash logo's 80% size, then grows.
            child: Transform.scale(
              scale: 0.8 + 0.2 * appear,
              child: SizedBox.square(
                dimension: MdLaunchReveal.artSize,
                child: _Prints(open: open, clock: clock, shine: shine),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
              0,
              _artBottom - rise + AppSpacing.lg + _wordsHalfHeight + 0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _WrittenName(progress: write),
                  const SizedBox(height: AppSpacing.xs),
                  Opacity(
                    opacity: promise,
                    child: Text(
                      'Do something together. Keep the memory.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.onCoral,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Photo Quest" in handwriting, revealed left to right with a soft leading
/// edge so it looks like it is being written by pen.
class _WrittenName extends StatelessWidget {
  const _WrittenName({required this.progress});

  final double progress;

  /// Width of the feathered leading edge, as a fraction of the text.
  static const _feather = 0.08;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      'Photo Quest',
      style: AppTypography.script.copyWith(
        fontSize: 44,
        height: 1.2,
        color: AppColors.onCoral,
      ),
    );
    // Nothing written yet: keep the space, draw nothing (a zero-width
    // gradient leaves stray specks of the last letters).
    if (progress <= 0) return Opacity(opacity: 0, child: text);

    final edge = progress * (1 + _feather);
    final solid = (edge - _feather).clamp(0.0, 0.997);
    final fadeEnd = edge.clamp(solid + 0.001, 0.999);
    return ClipRect(
      clipper: _WrittenClipper(edge),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          colors: const [
            Colors.white,
            Colors.white,
            Colors.transparent,
            Colors.transparent,
          ],
          stops: [0, solid, fadeEnd, 1],
        ).createShader(bounds),
        child: text,
      ),
    );
  }
}

/// Hard-clips the name to the part already written.
class _WrittenClipper extends CustomClipper<Rect> {
  const _WrittenClipper(this.edge);

  final double edge;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-24, -24, size.width * edge, size.height + 24);

  @override
  bool shouldReclip(_WrittenClipper oldClipper) => oldClipper.edge != edge;
}

/// The icon's three prints, drawn to the same geometry as the launch
/// image and app icon (`assets/icon/app_icon.png`). [open] fans the side
/// prints further out; [clock] (seconds) pulses the sparkles; [shine]
/// (-1..1) sweeps a band of light across the prints.
class _Prints extends StatelessWidget {
  const _Prints({required this.open, required this.clock, required this.shine});

  final double open;
  final double clock;
  final double shine;

  // Geometry as fractions of the art size, matching the icon.
  static const _printWidth = 0.34;
  static const _spread = 0.19;
  static const _sideDrop = 0.035;
  static const _tilt = 14 * math.pi / 180;

  /// 0..1 pulse, [offset] apart per sparkle so they never glint together.
  static double _pulse(double clock, double offset) =>
      0.5 + 0.5 * math.sin(2 * math.pi * (clock * 1.1 + offset));

  @override
  Widget build(BuildContext context) {
    const size = MdLaunchReveal.artSize;
    const w = size * _printWidth;
    final spread = size * _spread * (1 + 0.18 * open);
    final tilt = _tilt * (1 + 0.35 * open);
    const center = Offset(size / 2, size / 2 + size * 0.02);

    Widget at(Offset c, Widget child) =>
        Positioned(left: c.dx - w / 2, top: c.dy - w * 1.25 / 2, child: child);

    final prints = ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0x00FFFFFF), Color(0x59FFFFFF), Color(0x00FFFFFF)],
        stops: const [0.3, 0.5, 0.7],
        transform: _SlideGradient(shine),
      ).createShader(bounds),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
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
          ],
        ),
      ),
    );

    final big = _pulse(clock, 0);
    final small = _pulse(clock, 0.45);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        prints,
        _Sparkle(
          center: center + const Offset(size * 0.28, -size * 0.31),
          radius: size * 0.065 * (0.7 + 0.6 * big),
          color: AppColors.filmYellow,
          glow: 0.45 + 0.55 * big,
        ),
        _Sparkle(
          center: center + const Offset(-size * 0.30, -size * 0.27),
          radius: size * 0.035 * (0.7 + 0.8 * small),
          color: AppColors.warmCream,
          glow: 0.45 + 0.55 * small,
        ),
      ],
    );
  }
}

/// Slides a gradient horizontally by [percent] of the paint bounds' width.
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.percent);

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}

class _Print extends StatelessWidget {
  const _Print({required this.front});

  final bool front;

  @override
  Widget build(BuildContext context) {
    const w = MdLaunchReveal.artSize * _Prints._printWidth;
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
    this.glow = 1,
  });

  final Offset center;
  final double radius;
  final Color color;

  /// 0..1 brightness, for twinkling.
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - radius,
      top: center.dy - radius,
      child: Opacity(
        opacity: glow.clamp(0.0, 1.0),
        child: CustomPaint(
          size: Size.square(radius * 2),
          painter: _SparklePainter(color),
        ),
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
