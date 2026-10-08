import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Fills the screen with the preview (cropping the edges) instead of
/// letterboxing it, so the booth feels immersive.
class MdCoverCameraPreview extends StatelessWidget {
  const MdCoverCameraPreview({super.key, required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return CameraPreview(controller);

    // The plugin reports a landscape size; the booth is portrait.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}
