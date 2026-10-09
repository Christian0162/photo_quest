import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';

/// A Quest as shown on a selection card, with the People joining it.
class QuestListItem {
  const QuestListItem({required this.quest, this.participants = const []});

  final Quest quest;

  final List<Person> participants;
}
