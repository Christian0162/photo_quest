/// One execution/attempt of a Quest. See CLAUDE.md §20-21.
class QuestSession {
  const QuestSession({
    required this.id,
    required this.questId,
    required this.startedAt,
    this.completedAt,
    required this.status,
  });

  final String id;
  final String questId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status; // in_progress, completed, cancelled
}
