import '../../memories/entities/photo.dart';

/// How a shot is captured. Chosen in the booth, and remembered from shot to
/// shot until changed.
enum CaptureMode {
  photo('Photo', PhotoKind.photo),

  /// A few flashes, a new pose each time — the classic GIF booth.
  gif('GIF', PhotoKind.gif),

  /// A quick burst played forward and back.
  boomerang('Boomerang', PhotoKind.boomerang),

  /// A short clip filmed while walking around the group.
  orbit('360°', PhotoKind.video);

  const CaptureMode(this.label, this.kind);

  final String label;

  /// The [PhotoKind] this mode produces.
  final String kind;

  /// Looks are baked into photos and animations; clips stay natural.
  bool get supportsLooks => this != orbit;

  /// Boomerang and 360° record while the shutter is held down; photo and
  /// GIF use a countdown.
  bool get isHold => this == boomerang || this == orbit;
}
