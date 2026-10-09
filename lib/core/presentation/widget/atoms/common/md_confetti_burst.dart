import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';

/// A one-shot burst of film-coloured confetti from [origin], played once
/// when it first appears and then gone. Put it in a [Stack] above the
/// moment being celebrated. It never takes taps and draws nothing under
/// reduced motion. Reserved for reward moments.
class MdConfettiBurst extends StatefulWidget {
  const MdConfettiBurst({
    super.key,
    this.origin = const Alignment(0, -0.2),
    this.pieces = 44,
    this.delay = Duration.zero,
  });

  final Alignment origin;
  final int pieces;
  final Duration delay;

  @override
  State<MdConfettiBurst> createState() => _MdConfettiBurstState();
}

class _MdConfettiBurstState extends State<MdConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const _flight = Duration(milliseconds: 1700);
  static const _colors = [
    AppColors.warmCoral,
    AppColors.filmYellow,
    AppColors.softPeach,
    AppColors.softGreen,
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + _flight,
  );
  late final List<_Piece> _pieces = _scatter();
  bool _started = false;

  List<_Piece> _scatter() {
    final random = math.Random(7);
    return [
      for (var i = 0; i < widget.pieces; i++)
        _Piece(
          angle: -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 1.5,
          speed: 220 + random.nextDouble() * 360,
          spin: (random.nextDouble() - 0.5) * 14,
          size: 6 + random.nextDouble() * 6,
          color: _colors[i % _colors.length],
          round: i % 5 == 0,
        ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || AppMotion.reduced(context)) return;
    _started = true;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final elapsed = _controller.duration! * _controller.value;
            final t =
                ((elapsed - widget.delay).inMicroseconds /
                        _flight.inMicroseconds)
                    .clamp(0.0, 1.0);
            if (t == 0 || t == 1) return const SizedBox.expand();
            return CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(_pieces, widget.origin, t),
            );
          },
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.color,
    required this.round,
  });

  final double angle;
  final double speed;
  final double spin;
  final double size;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.origin, this.t);

  final List<_Piece> pieces;
  final Alignment origin;
  final double t;

  static const _gravity = 900.0;

  @override
  void paint(Canvas canvas, Size size) {
    final start = origin.alongSize(size);
    // Fast out of the gate, then drifting down: drag on the throw, gravity
    // on the fall.
    final seconds = t * 1.7;
    final thrown = 1 - math.pow(1 - t, 3).toDouble();
    final fall = 0.5 * _gravity * seconds * seconds * 0.35;
    final paint = Paint();

    for (final piece in pieces) {
      final x = start.dx + math.cos(piece.angle) * piece.speed * thrown * 0.9;
      final y =
          start.dy + math.sin(piece.angle) * piece.speed * thrown * 0.9 + fall;
      paint.color = piece.color.withValues(alpha: (1 - t * t).clamp(0, 1));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.spin * t);
      if (piece.round) {
        canvas.drawCircle(Offset.zero, piece.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: piece.size,
              height: piece.size * 1.8,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
