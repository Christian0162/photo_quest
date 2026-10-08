import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Fills the screen with the camera preview (cropping the edges) instead of
/// letterboxing it, so the camera feels immersive.
class MdCameraCoverPreview extends StatelessWidget {
  const MdCameraCoverPreview({super.key, required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return CameraPreview(controller);

    // The plugin reports a landscape size; the camera screens are portrait.
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
