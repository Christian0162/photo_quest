/// Defaults for grabbing a burst of frames from the live camera stream
/// (boomerangs). Used by `CameraService`.
abstract final class AppCameraConstants {
  static const burstMaxFrames = 16;

  static const burstFrameSpacing = Duration(milliseconds: 90);

  static const burstMaxDuration = Duration(seconds: 2);

  /// How often a burst checks whether the shutter was let go between
  /// frames.
  static const burstReleasePollInterval = Duration(milliseconds: 50);
}
