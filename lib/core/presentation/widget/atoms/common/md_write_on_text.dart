import 'package:flutter/material.dart';

/// Text that appears as if written by hand: a soft edge sweeps left to right
/// across it. [progress] runs 0 (nothing written) to 1 (fully written) and is
/// driven by the caller, so it can share a parent's animation controller.
class MdWriteOnText extends StatelessWidget {
  const MdWriteOnText(
    this.text, {
    super.key,
    required this.progress,
    required this.style,
  });

  final String text;
  final double progress;
  final TextStyle style;

  /// Width of the soft leading edge, as a fraction of the text width.
  static const _edge = 0.12;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    final front = p * (1 + _edge);

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: const [Colors.white, Colors.transparent],
        stops: [(front - _edge).clamp(0.0, 1.0), front.clamp(0.0, 1.0)],
      ).createShader(bounds),
      child: Text(text, style: style),
    );
  }
}
