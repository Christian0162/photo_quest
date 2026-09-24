
enum CameraFrameFormat {
  /// Android: separate Y, U and V planes.
  yuv420,

  /// iOS: one interleaved blue-green-red-alpha plane.
  bgra8888,
}
