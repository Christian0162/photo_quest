import 'package:flutter/material.dart';

import '../../../../../config/constant/app_motion.dart';

/// Squishes its child while pressed and springs it back on release, so
/// key actions feel physical, like a photobooth button. Skipped under
/// reduced motion.
class MdPressableScale extends StatefulWidget {
  const MdPressableScale({
    super.key,
    required this.child,
    required this.enabled,
    this.scale = 0.94,
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
        // Squishes in fast, then springs back past rest on release.
        duration: _pressed ? AppMotion.micro : AppMotion.short * 1.6,
        curve: _pressed ? AppMotion.standard : AppMotion.spring,
        child: widget.child,
      ),
    );
  }
}
