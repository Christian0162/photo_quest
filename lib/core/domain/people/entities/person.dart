/// Someone (or a pet) associated with memories. See CLAUDE.md §20, §40.
class Person {
  const Person({
    required this.id,
    required this.name,
    required this.type,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String type; // self, partner, family, friend, pet, other
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;
}
