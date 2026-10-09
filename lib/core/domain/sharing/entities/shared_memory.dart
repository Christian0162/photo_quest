/// One photo, GIF or clip of a memory somebody shared, with short-lived links
/// to view it. Links expire; ask for them again rather than keeping them.
class SharedPhoto {
  const SharedPhoto({
    required this.id,
    required this.position,
    required this.kind,
    required this.url,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.mirrored = false,
    this.addedByName,
  });

  final String id;
  final int position;

  final String kind;
  final String url;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
  final bool mirrored;

  final String? addedByName;

  bool get isVideo => kind == 'video';

  String get previewUrl => thumbnailUrl ?? url;
}

/// A memory a friend shared with the signed-in person, as a card.
class SharedMemorySummary {
  const SharedMemorySummary({
    required this.id,
    required this.title,
    required this.capturedAt,
    required this.ownerName,
    this.coverUrl,
  });

  final String id;
  final String title;
  final DateTime capturedAt;

  final String ownerName;
  final String? coverUrl;
}

/// A shared memory, opened.
class SharedMemoryDetail {
  const SharedMemoryDetail({
    required this.id,
    required this.title,
    this.note,
    required this.capturedAt,
    required this.ownerName,
    this.ownerAvatarUrl,
    required this.photos,
    this.canAddPhotos = false,
  });

  final String id;
  final String title;
  final String? note;
  final DateTime capturedAt;
  final String ownerName;
  final String? ownerAvatarUrl;
  final List<SharedPhoto> photos;

  /// True for friends taking part in the quest this memory came from: they
  /// can add their own photos. People who only have a memory code can't.
  final bool canAddPhotos;
}

/// Someone a memory or quest has been shared with, as its owner sees them.
class ShareViewer {
  const ShareViewer({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.sharedAt,
    this.status,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime sharedAt;

  final String? status;
}
