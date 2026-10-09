import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';

/// The Photo Quest mark: three fanned photobooth prints, a heart on the front
/// one, and two sparkles — the same artwork as the app icon
/// (`assets/icon/app_icon.png`) and the native launch image. Drawn in code so
/// it stays crisp at every size and can be animated without frame assets.
///
/// This is the still version. [open], [develop] and [twinkle] are the three
/// animatable moments (see `MdAnimatedPhotoQuestLogo`); the defaults are the
/// finished, resting logo. Meant for the coral brand surface.
class MdPhotoQuestLogo extends StatelessWidget {
  const MdPhotoQuestLogo({
    super.key,
    this.size = 240,
    this.open = 0,
    this.develop = 1,
    this.twinkle = 0,
    this.semanticLabel = 'Photo Quest',
  });

  final double size;

  final double open;

  final double develop;

  final double twinkle;

  final String? semanticLabel;

  // Geometry as fractions of the art size, matching the icon.
  static const _printWidth = 0.34;
  static const _spread = 0.19;
  static const _sideDrop = 0.035;
  static const _tilt = 14 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final w = size * _printWidth;
    final spread = size * _spread * (1 + 0.18 * open);
    final tilt = _tilt * (1 + 0.35 * open);
    final center = Offset(size / 2, size / 2 + size * 0.02);

    Widget at(Offset c, Widget child) =>
        Positioned(left: c.dx - w / 2, top: c.dy - w * 1.25 / 2, child: child);

    final art = SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          at(
            center + Offset(-spread, size * _sideDrop),
            Transform.rotate(
              angle: -tilt,
              child: _Print(width: w, develop: 0, front: false),
            ),
          ),
          at(
            center + Offset(spread, size * _sideDrop),
            Transform.rotate(
              angle: tilt,
              child: _Print(width: w, develop: 0, front: false),
            ),
          ),
          at(
            center - Offset(0, size * 0.025 * open),
            _Print(width: w, develop: develop, front: true),
          ),
          _Sparkle(
            center: center + Offset(size * 0.28, -size * 0.31),
            radius: size * 0.065 * (1 + 0.3 * twinkle),
            color: AppColors.filmYellow,
          ),
          _Sparkle(
            center: center + Offset(-size * 0.30, -size * 0.27),
            radius: size * 0.035 * (1 + 0.5 * twinkle),
            color: AppColors.warmCream,
          ),
        ],
      ),
    );

    if (semanticLabel == null) return ExcludeSemantics(child: art);
    return Semantics(label: semanticLabel, image: true, child: art);
  }
}

class _Print extends StatelessWidget {
  const _Print({
    required this.width,
    required this.develop,
    required this.front,
  });

  final double width;
  final double develop;
  final bool front;

  @override
  Widget build(BuildContext context) {
    final w = width;
    return Container(
      width: w,
      height: w * 1.25,
      padding: EdgeInsets.all(w * 0.07),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(w * 0.09),
        boxShadow: [
          BoxShadow(
            color: AppColors.logoShadow,
            blurRadius: w * 0.17,
            offset: Offset(0, w * 0.07),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: front ? AppColors.warmCharcoal : AppColors.softPeach,
          borderRadius: BorderRadius.circular(w * 0.06),
        ),
        child: front
            ? Center(
                child: Opacity(
                  opacity: develop.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * develop,
                    child: Icon(
                      Icons.favorite_rounded,
                      size: w * 0.5,
                      color: AppColors.warmCoral,
                    ),
                  ),
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
