/// Sizes and encoding quality for the images the app generates. Used by
/// `ImageProcessingService`.
abstract final class AppImageSizes {
  static const thumbnailWidth = 480;
  static const stripWidth = 800;

  static const posterWidth = 1080;

  static const animationWidth = 480;

  static const stripMargin = 40;
  static const stripGap = 24;
  static const stripFooterHeight = 176;

  static const thumbnailJpegQuality = 85;

  static const printJpegQuality = 90;

  static const originalJpegQuality = 92;
}
