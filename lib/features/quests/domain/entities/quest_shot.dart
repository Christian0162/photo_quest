/// One instruction/photo within a Quest. See CLAUDE.md §20.
class QuestShot {
  const QuestShot({
    required this.id,
    required this.questId,
    required this.position,
    required this.instruction,
    required this.shotType,
  });

  final String id;
  final String questId;
  final int position;
  final String instruction;
  final String shotType;
}
