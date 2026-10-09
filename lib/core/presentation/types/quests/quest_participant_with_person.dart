import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest_participant.dart';

/// A Quest Participant paired with the Person it refers to, for display.
class QuestParticipantWithPerson {
  const QuestParticipantWithPerson({
    required this.participant,
    required this.person,
  });

  final QuestParticipant participant;
  final Person person;
}
