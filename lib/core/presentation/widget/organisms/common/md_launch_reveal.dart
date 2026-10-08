import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_photoquest_logo.dart';

class MdLaunchReveal extends StatefulWidget {
  const MdLaunchReveal({super.key, required this.child});

  final Widget child;

  /// Size of the prints artwork — the same 240 logical px as the native
  /// launch image, so the hand-off is seamless.
  static const artSize = 240.0;

  @override
  State<MdLaunchReveal> createState() => _MdLaunchRevealState();
}

class _MdLaunchRevealState extends State<MdLaunchReveal>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1800);

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

  static const _rise = 56.0;

  static const _artBottom = 74.0;

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
              dimension: MdLaunchReveal.artSize,
              child: MdPhotoQuestLogo(
                size: MdLaunchReveal.artSize,
                open: open,
                twinkle: twinkle,
                semanticLabel: null,
              ),
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
