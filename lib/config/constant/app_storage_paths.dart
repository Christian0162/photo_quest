/// Where photo files live, relative to the app documents directory. Only
/// `PhotoStorageService` resolves these into real paths. See CLAUDE.md §6.
abstract final class AppStoragePaths {
  /// Still photos.
  static const originals = 'photos/originals';

  /// Thumbnails, and poster frames of GIFs and clips.
  static const thumbnails = 'photos/thumbnails';

  /// GIFs and boomerangs.
  static const motion = 'photos/motion';

  /// 360° clips.
  static const videos = 'photos/videos';

  /// Printed keepsakes (strip / grid / polaroid).
  static const strips = 'photos/strips';
}
