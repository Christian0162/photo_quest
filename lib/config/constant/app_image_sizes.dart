/// Sizes and encoding quality for the images the app generates. Used by
/// `ImageProcessingService`. See CLAUDE.md §7, §46.
abstract final class AppImageSizes {
  static const thumbnailWidth = 480;
  static const stripWidth = 800;

  /// Poster frames are kept large enough to print on a keepsake.
  static const posterWidth = 1080;

  /// Animated frames stay small so GIFs load and share quickly.
  static const animationWidth = 480;

  /// Photo strip layout, in pixels.
  static const stripMargin = 40;
  static const stripGap = 24;
  static const stripFooterHeight = 176;

  /// JPEG quality for thumbnails, where size matters more than detail.
  static const thumbnailJpegQuality = 85;

  /// JPEG quality for poster frames and photo strips.
  static const printJpegQuality = 90;

  /// JPEG quality for originals, which are kept as the memory itself.
  static const originalJpegQuality = 92;
}
