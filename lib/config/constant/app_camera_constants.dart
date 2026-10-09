/// Defaults for grabbing a burst of frames from the live camera stream
/// (boomerangs). Used by `CameraService`. See CLAUDE.md §47.
abstract final class AppCameraConstants {
  /// Most frames kept from one burst.
  static const burstMaxFrames = 20;

  /// Shortest gap between two kept frames.
  static const burstFrameSpacing = Duration(milliseconds: 90);

  /// A burst stops on its own after this long.
  static const burstMaxDuration = Duration(seconds: 2);

  /// How often a burst checks whether the shutter was let go between
  /// frames.
  static const burstReleasePollInterval = Duration(milliseconds: 50);
}
