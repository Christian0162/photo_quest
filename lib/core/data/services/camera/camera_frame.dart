import 'dart:typed_data';
import '../../../domain/camera/enum/camera_frame_format.dart';

/// One raw frame from the live camera stream, copied out of the plugin's
/// reused buffers so it can be processed later (e.g. into a boomerang).
/// Plain data — safe to send to a background isolate. See CLAUDE.md §7.
class CameraFrame {
  const CameraFrame({
    required this.width,
    required this.height,
    required this.format,
    required this.planes,
    required this.rotationDegrees,
  });

  final int width;
  final int height;

  /// How the pixels are laid out.
  final CameraFrameFormat format;
  final List<CameraFramePlane> planes;

  /// Clockwise rotation that turns the sensor image upright (portrait).
  final int rotationDegrees;
}

class CameraFramePlane {
  const CameraFramePlane({
    required this.bytes,
    required this.bytesPerRow,
    this.bytesPerPixel,
  });

  final Uint8List bytes;
  final int bytesPerRow;
  final int? bytesPerPixel;
}
