import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/constant/app_motion.dart';
import '../../atoms/common/md_photoquest_logo.dart';

class MdAnimatedPhotoQuestLogo extends StatefulWidget {
  const MdAnimatedPhotoQuestLogo({
    super.key,
    this.size = 120,
    this.playing = true,
    this.loop = false,
    this.duration = const Duration(milliseconds: 1400),
  });

  final double size;

  final bool playing;

  final bool loop;

  final Duration duration;

  @override
  State<MdAnimatedPhotoQuestLogo> createState() =>
      _MdAnimatedPhotoQuestLogoState();
}

class _MdAnimatedPhotoQuestLogoState extends State<MdAnimatedPhotoQuestLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AppMotion.reduced(context);
    if (reduced != _reduced) {
      _reduced = reduced;
      _sync();
    }
  }

  @override
  void didUpdateWidget(MdAnimatedPhotoQuestLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing || oldWidget.loop != widget.loop) {
      _sync();
    }
  }

  void _sync() {
    if (_reduced == true || !widget.playing) {
      _controller.stop();
      // Resting logo: fully developed, no motion.
      _controller.value = 1;
      return;
    }
    if (widget.loop) {
      _controller.repeat();
    } else if (!_controller.isAnimating && _controller.value < 1) {
      _controller.forward();
    } else if (_controller.value == 1 && !_controller.isAnimating) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double _phase(
    double t,
    double begin,
    double end, [
    Curve curve = Curves.easeOut,
  ]) => curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final resting = _reduced == true || !widget.playing;
        final t = _controller.value;
        // A loop returns to the start of the cycle, so the heart un-develops
        // in the last tenth.
        final reset = widget.loop && !resting ? _phase(t, 0.9, 1) : 0.0;

        return MdPhotoQuestLogo(
          size: widget.size,
          // Fans open, then eases shut again: the end frame is the resting logo.
          open: resting
              ? 0
              : _phase(t, 0.05, 0.4, Curves.easeOutBack) *
                    (1 - _phase(t, 0.7, 1, Curves.easeInOut)),
          develop: resting ? 1 : _phase(t, 0.3, 0.65) * (1 - reset),
          twinkle: resting ? 0 : math.sin(math.pi * _phase(t, 0.55, 0.95)),
        );
      },
    );
  }
}
