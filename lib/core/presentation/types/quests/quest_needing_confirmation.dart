import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';

/// A Quest you created, still waiting on some participants to confirm.
class QuestNeedingConfirmation {
  const QuestNeedingConfirmation({
    required this.quest,
    required this.people,
    required this.pendingCount,
  });

  final Quest quest;
  final List<Person> people;
  final int pendingCount;
}
