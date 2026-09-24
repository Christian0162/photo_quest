import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Turns whatever is inside a [KeepsakeSnapshot] into a PNG — how a
/// designed keepsake becomes a real, shareable image that looks exactly
/// like the screen. See CLAUDE.md §36.
class KeepsakeSnapshotController {
  final _key = GlobalKey();

  /// Width of the saved image, in pixels. Enough to print or share.
  static const outputWidth = 1080.0;

  /// Renders the current frame, or null if nothing is on screen yet.
  Future<Uint8List?> toPng() async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || boundary.size.isEmpty) return null;
    final image = await boundary.toImage(
      pixelRatio: outputWidth / boundary.size.width,
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}

/// Marks the keepsake to capture with [controller].
class KeepsakeSnapshot extends StatelessWidget {
  const KeepsakeSnapshot({
    super.key,
    required this.controller,
    required this.child,
  });

  final KeepsakeSnapshotController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: controller._key, child: child);
  }
}
