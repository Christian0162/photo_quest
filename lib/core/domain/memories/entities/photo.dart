/// A single captured image belonging to a Memory. See CLAUDE.md §20.
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
}
