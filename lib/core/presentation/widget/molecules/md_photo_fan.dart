import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../atoms/md_local_photo.dart';

/// Up to three photos fanned out like a hand of prints: the first stands
/// upright on top, the next two tilt out behind it. They deal out once when
/// first shown (instantly under reduced motion). Tapping a print calls
/// [onOpen] with its index, so each one can be viewed full screen.
///
/// ```text
///      ┌───┐┌─────┐┌───┐
///     ╱ 2 ╱ │  1  │ ╲ 3 ╲
///    └───┘  │     │  └───┘
///           └─────┘
/// ```
///
/// See CLAUDE.md §2.5 (nostalgic, physical), design system §33-35.
class MdPhotoFan extends StatelessWidget {
  const MdPhotoFan({
    super.key,
    required this.paths,
    required this.onOpen,
    this.front,
  });

  /// Photo file paths, front print first. Only the first three are shown.
  final List<String?> paths;
  final ValueChanged<int> onOpen;

  /// Wraps the front print — e.g. in a hero so it can fly into the detail.
  final Widget Function(Widget print)? front;

  static const _tilt = 0.2; // radians, ~11°
  static const _printRatio = 5 / 4;

  /// The fan's height for a given [width], so lists can reserve space.
  static double heightFor(double width) {
    final printWidth = _printWidth(width);
    return printWidth * _printRatio + printWidth * 0.3;
  }

  static double _printWidth(double width) => math.min(width * 0.46, 200);

  @override
  Widget build(BuildContext context) {
    final shown = paths.isEmpty ? <String?>[null] : paths.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final printWidth = _printWidth(width);
        final spread = math.min(width * 0.25, printWidth * 0.62);

        Widget print(int index) => _Print(
          path: shown[index],
          width: printWidth,
          label: 'View photo ${index + 1} of ${paths.length}',
          onTap: paths.isEmpty ? null : () => onOpen(index),
        );

        // Full width, so the fan is centred on the card, not left-aligned.
        return SizedBox(
          width: width,
          height: heightFor(width),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppMotion.of(context, AppMotion.reveal),
            curve: AppMotion.emphasized,
            builder: (context, t, _) {
              Widget side(int index, double direction) => Transform.translate(
                offset: Offset(direction * spread * t, printWidth * 0.1 * t),
                child: Transform.rotate(
                  angle: direction * _tilt * t,
                  child: print(index),
                ),
              );

              return Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  if (shown.length > 1) side(1, -1),
                  if (shown.length > 2) side(2, 1),
                  front?.call(print(0)) ?? print(0),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// One print: the photo inside a white border with soft lift.
class _Print extends StatelessWidget {
  const _Print({
    required this.path,
    required this.width,
    required this.label,
    required this.onTap,
  });

  final String? path;
  final double width;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final print = Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.xs + AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.print,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AspectRatio(
          aspectRatio: 1 / MdPhotoFan._printRatio,
          child: MdLocalPhoto(path: path),
        ),
      ),
    );

    if (onTap == null) return ExcludeSemantics(child: print);
    // Its own node, so it's a separate action from the card around it.
    return Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, child: print),
    );
  }
}
