import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';

class QuestDetail {
  const QuestDetail({required this.quest, required this.shots, this.creator});

  final Quest quest;
  final List<QuestShot> shots;

  /// Null for built-in quest templates. See design system §16.
  final Person? creator;
}
