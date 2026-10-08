/// A reusable guided real-life activity + photobooth experience, with an
/// owner and a participation model.
class Quest {
  const Quest({
    required this.id,
    this.creatorId,
    required this.title,
    this.description,
    required this.category,
    this.type = 'solo',
    this.status = 'published',
    this.maxParticipants,
    this.coverImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  final String? creatorId;
  final String title;
  final String? description;
  final String category;
  final String type; // solo, pair, group
  final String status; // draft, published, invited, active, completed
  final int? maxParticipants;
  final String? coverImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
}
