import '../../memories/entities/photo.dart';

/// How a shot is captured. Chosen in the booth, and remembered from shot to
/// shot until changed.
enum CaptureMode {
  photo('Photo', PhotoKind.photo),

  gif('GIF', PhotoKind.gif),

  boomerang('Boomerang', PhotoKind.boomerang),

  orbit('360°', PhotoKind.video);

  const CaptureMode(this.label, this.kind);

  final String label;

  final String kind;

  bool get supportsLooks => this != orbit;

  /// Boomerang and 360° record while the shutter is held down; photo and
  /// GIF use a countdown.
  bool get isHold => this == boomerang || this == orbit;
}
