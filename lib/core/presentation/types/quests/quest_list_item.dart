import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';

/// A Quest as shown on a selection card, with the People joining it.
class QuestListItem {
  const QuestListItem({required this.quest, this.participants = const []});

  final Quest quest;

  /// Only filled for a user-created pair/group Quest. See design system §15.
  final List<Person> participants;
}
