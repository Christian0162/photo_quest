/// One instruction/photo within a Quest. See CLAUDE.md §20.
class QuestShot {
  const QuestShot({
    required this.id,
    required this.questId,
    required this.position,
    required this.instruction,
    required this.shotType,
    this.exampleImagePath,
    this.required = true,
  });

  final String id;
  final String questId;
  final int position;
  final String instruction;
  final String shotType;
  final String? exampleImagePath;

  /// Whether this shot gates quest completion. See CLAUDE.md §37.
  final bool required;
}
