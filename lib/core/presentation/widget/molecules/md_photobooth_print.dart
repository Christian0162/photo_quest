import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// A photo laid out as an aesthetic photobooth print: a 3 × 2 grid of
/// frames on soft beige paper, muted film color, little hand-drawn doodles,
/// a vertical "PHOTOBOOTH" stamp, a handwritten note and the date. Each
/// frame is a different crop of [image], so a single example photo reads
/// like a burst from the booth. See CLAUDE.md §2.4, §36.
class MdPhotoboothPrint extends StatelessWidget {
  const MdPhotoboothPrint({
    super.key,
    required this.image,
    required this.note,
    required this.date,
    this.focus = Alignment.center,
    this.semanticLabel,
  });

  final ImageProvider image;

  /// Handwritten on the print, e.g. "Just the two of you".
  final String note;
  final DateTime date;

  /// Where the people are in the photo; every crop stays around them.
  final Alignment focus;
  final String? semanticLabel;

  /// Each frame's crop: nudge from [focus], zoom, and its doodle.
  static const _frames = [
    (-0.30, -0.15, 1.45, _Doodle.heart, Alignment.topLeft),
    (0.30, -0.25, 1.70, _Doodle.hearts, Alignment.topRight),
    (0.00, 0.00, 1.10, _Doodle.sparkle, Alignment.topLeft),
    (-0.20, 0.10, 1.90, _Doodle.heart, Alignment.topRight),
    (0.30, 0.15, 1.30, _Doodle.heart, Alignment.topLeft),
    (0.00, -0.10, 1.00, _Doodle.sparkle, Alignment.topRight),
  ];

  static const _columns = 3;
  static const _gap = 5.0;

  @override
  Widget build(BuildContext context) {
    // The stamp, note and date are printed *on* the picture, so they scale
    // with the print rather than the system text size (the print is an
    // image to screen readers, labelled by [semanticLabel]).
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: MediaQuery.withNoTextScaling(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.printPaper,
            borderRadius: BorderRadius.circular(AppRadius.sm / 2),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.ms,
              AppSpacing.ms,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                const _Rail(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _grid()),
                      SizedBox(
                        height: 26,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 56,
                              height: 18,
                              child: CustomPaint(painter: _SquigglePainter()),
                            ),
                            Expanded(
                              child: Text(
                                note,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.script.copyWith(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              DateFormat('MM / dd / yyyy').format(date),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.inkBrown,
                                fontSize: 8,
                                letterSpacing: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid() {
    final rows = (_frames.length / _columns).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++) ...[
          if (r > 0) const SizedBox(height: _gap),
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < _columns; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Expanded(child: _frame(_frames[r * _columns + c])),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _frame((double, double, double, _Doodle, Alignment) spec) {
    final (dx, dy, zoom, doodle, corner) = spec;
    final pivot = Alignment(
      (focus.x + dx).clamp(-1.0, 1.0),
      (focus.y + dy).clamp(-1.0, 1.0),
    );

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(_boothTone),
            child: Transform.scale(
              scale: zoom,
              alignment: pivot,
              child: Image(
                image: image,
                fit: BoxFit.cover,
                alignment: pivot,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Align(
            alignment: corner,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: SizedBox.square(
                dimension: 14,
                child: CustomPaint(painter: _DoodlePainter(doodle)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Soft booth light: a little desaturated, lifted shadows, warm paper
  /// tone — so any photo sits calmly on the print.
  static const _boothTone = <double>[
    0.74, 0.17, 0.02, 0, 22, //
    0.05, 0.86, 0.02, 0, 18, //
    0.05, 0.17, 0.71, 0, 14, //
    0, 0, 0, 1, 0,
  ];
}

/// The left margin: a little camera, "PHOTOBOOTH" running down, and a rule.
class _Rail extends StatelessWidget {
  const _Rail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      child: Column(
        children: [
          const Icon(
            Icons.photo_camera_outlined,
            size: 12,
            color: AppColors.inkBrown,
          ),
          const SizedBox(height: AppSpacing.xs),
          RotatedBox(
            quarterTurns: 1,
            child: Text(
              'PHOTOBOOTH',
              style: AppTypography.caption.copyWith(
                color: AppColors.inkBrown,
                fontSize: 7,
                letterSpacing: 2.2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Expanded(
            child: VerticalDivider(
              width: 1,
              thickness: 0.8,
              color: AppColors.inkBrown,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

enum _Doodle { heart, hearts, sparkle }

Path _heartPath(Rect r) {
  final w = r.width, h = r.height, x = r.left, y = r.top;
  return Path()
    ..moveTo(x + w * 0.5, y + h * 0.9)
    ..cubicTo(
      x + w * 0.1,
      y + h * 0.62,
      x - w * 0.02,
      y + h * 0.3,
      x + w * 0.22,
      y + h * 0.16,
    )
    ..cubicTo(
      x + w * 0.38,
      y + h * 0.06,
      x + w * 0.5,
      y + h * 0.2,
      x + w * 0.5,
      y + h * 0.32,
    )
    ..cubicTo(
      x + w * 0.5,
      y + h * 0.2,
      x + w * 0.62,
      y + h * 0.06,
      x + w * 0.78,
      y + h * 0.16,
    )
    ..cubicTo(
      x + w * 1.02,
      y + h * 0.3,
      x + w * 0.9,
      y + h * 0.62,
      x + w * 0.5,
      y + h * 0.9,
    );
}

/// White pen doodles drawn on a frame, like the ones people add in a booth.
class _DoodlePainter extends CustomPainter {
  const _DoodlePainter(this.doodle);

  final _Doodle doodle;

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = AppColors.onCamera.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width, h = size.height;

    switch (doodle) {
      case _Doodle.heart:
        canvas.drawPath(_heartPath(Offset.zero & size), pen);
      case _Doodle.hearts:
        canvas.drawPath(
          _heartPath(Rect.fromLTWH(0, h * 0.35, w * 0.6, h * 0.6)),
          pen,
        );
        canvas.drawPath(
          _heartPath(Rect.fromLTWH(w * 0.45, 0, w * 0.5, h * 0.5)),
          pen,
        );
      case _Doodle.sparkle:
        final c = Offset(w * 0.2, h * 0.85);
        for (final end in [
          Offset(w * 0.15, h * 0.15),
          Offset(w * 0.6, h * 0.35),
          Offset(w * 0.85, h * 0.8),
        ]) {
          canvas.drawLine(c + (end - c) * 0.35, end, pen);
        }
    }
  }

  @override
  bool shouldRepaint(_DoodlePainter old) => old.doodle != doodle;
}

/// Two little hearts and a trailing pen line, bottom-left of the print.
class _SquigglePainter extends CustomPainter {
  const _SquigglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = AppColors.inkBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final h = size.height;

    canvas.drawPath(_heartPath(Rect.fromLTWH(0, 0, h * 0.7, h * 0.7)), pen);
    canvas.drawPath(
      _heartPath(Rect.fromLTWH(h * 0.45, h * 0.3, h * 0.6, h * 0.6)),
      pen,
    );
    final line = Path()..moveTo(h * 0.8, h * 0.85);
    for (var x = h * 0.8; x < size.width; x += 10) {
      line.quadraticBezierTo(x + 5, h * 0.7, x + 10, h * 0.85);
    }
    canvas.drawPath(line, pen);
  }

  @override
  bool shouldRepaint(_SquigglePainter old) => false;
}
