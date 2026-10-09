/// Where photo files live, relative to the app documents directory. Only
/// `PhotoStorageService` resolves these into real paths.
abstract final class AppStoragePaths {
  static const originals = 'photos/originals';

  static const thumbnails = 'photos/thumbnails';

  static const motion = 'photos/motion';

  static const videos = 'photos/videos';

  static const strips = 'photos/strips';
}
