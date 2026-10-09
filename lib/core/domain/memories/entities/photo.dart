/// What a captured shot is. Stored as a plain string on the Photo so new
/// kinds need no enum migration. See CLAUDE.md §20.
abstract final class PhotoKind {
  /// A single still photo.
  static const photo = 'photo';

  /// A stop-motion GIF: a few flashes, a new pose each time.
  static const gif = 'gif';

  /// A short burst played forward then backward, on loop.
  static const boomerang = 'boomerang';

  /// A 360° clip, filmed while walking around the group.
  static const video = 'video';

  static const all = [photo, gif, boomerang, video];
}

/// A single captured shot belonging to a Memory — a photo, an animation or a
/// short clip. See CLAUDE.md §20.
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

  /// One of [PhotoKind].
  final String kind;

  bool get isVideo => kind == PhotoKind.video;

  /// A GIF or boomerang — plays wherever an image can be shown.
  bool get isAnimated => kind == PhotoKind.gif || kind == PhotoKind.boomerang;

  /// The best still image of this shot: the original photo, or the poster
  /// frame of an animation or clip.
  String get stillPath =>
      kind == PhotoKind.photo ? originalPath : thumbnailPath;
}
