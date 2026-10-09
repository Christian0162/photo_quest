/// What a captured shot is. Stored as a plain string on the Photo so new
/// kinds need no enum migration.
abstract final class PhotoKind {
  static const photo = 'photo';

  static const gif = 'gif';

  static const boomerang = 'boomerang';

  static const video = 'video';

  static const all = [photo, gif, boomerang, video];
}

/// A single captured shot belonging to a Memory — a photo, an animation or a
/// short clip.
///
/// For animated and video kinds, [originalPath] is the `.gif` / `.mp4` and
/// [thumbnailPath] is a still poster frame, so everything that needs a still
/// image (cards, strips, keepsakes) can use [stillPath].
class Photo {
  const Photo({
    required this.id,
    required this.memoryId,
    this.shotId,
    required this.originalPath,
    required this.thumbnailPath,
    required this.position,
    required this.capturedAt,
    required this.width,
    required this.height,
    this.kind = PhotoKind.photo,
    this.mirrored = false,
  });

  final String id;
  final String memoryId;
  final String? shotId;
  final String originalPath;
  final String thumbnailPath;
  final int position;
  final DateTime capturedAt;
  final int width;
  final int height;

  final String kind;

  /// A clip recorded unmirrored from a front camera whose preview was
  /// mirrored; the viewer flips it so it matches the preview and poster.
  final bool mirrored;

  bool get isVideo => kind == PhotoKind.video;

  bool get isAnimated => kind == PhotoKind.gif || kind == PhotoKind.boomerang;

  /// The best still image of this shot: the original photo, or the poster
  /// frame of an animation or clip.
  String get stillPath =>
      kind == PhotoKind.photo ? originalPath : thumbnailPath;
}
