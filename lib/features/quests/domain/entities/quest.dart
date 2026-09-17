/// A reusable guided photobooth experience template. See CLAUDE.md §20.
class Quest {
  const Quest({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.coverImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final String? coverImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
}
