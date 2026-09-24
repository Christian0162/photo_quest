import 'package:flutter/material.dart';

import '../../../../config/constant/app_motion.dart';

/// Scales its child down slightly while pressed so key actions feel
/// physical, like a photobooth button. Skipped under reduced motion. See
/// design system §29, §48-50.
class MdPressableScale extends StatefulWidget {
  const MdPressableScale({
    super.key,
    required this.child,
    required this.enabled,
    this.scale = 0.96,
  });

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<MdPressableScale> createState() => _MdPressableScaleState();
}

class _MdPressableScaleState extends State<MdPressableScale> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduced(context)) return widget.child;

    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppMotion.micro,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
