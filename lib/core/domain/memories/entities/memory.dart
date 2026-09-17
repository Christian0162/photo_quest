/// The completed collection of photos representing a moment. See CLAUDE.md §20.
class Memory {
  const Memory({
    required this.id,
    required this.questSessionId,
    required this.title,
    this.note,
    required this.capturedAt,
    this.coverPhotoId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String questSessionId;
  final String title;
  final String? note;
  final DateTime capturedAt;
  final String? coverPhotoId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
