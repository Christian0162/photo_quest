/// One Person's membership/invitation status on one Quest.
class QuestParticipant {
  const QuestParticipant({
    required this.id,
    required this.questId,
    required this.personId,
    required this.status,
    required this.invitedAt,
    this.respondedAt,
  });

  final String id;
  final String questId;
  final String personId;
  final String status; // invited, accepted, declined, removed, completed
  final DateTime invitedAt;
  final DateTime? respondedAt;
}
