import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';

part 'quests_needing_confirmation_view_model.g.dart';

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

/// Quests you created that still have participants who haven't confirmed
/// they're in. Surfaced on Home so a group quest doesn't quietly stall.
/// See CLAUDE.md §16A, §31, design system §13.
@riverpod
Future<List<QuestNeedingConfirmation>> questsNeedingConfirmation(
  Ref ref,
) async {
  final questRepo = ref.watch(questRepositoryProvider);
  final peopleRepo = ref.watch(peopleRepositoryProvider);

  final self = await peopleRepo.getSelfPerson();
  if (self == null) return const [];

  final quests = await questRepo.getQuests();
  final result = <QuestNeedingConfirmation>[];
  for (final quest in quests) {
    if (quest.creatorId != self.id || quest.type == 'solo') continue;

    final participants = await questRepo.getParticipants(quest.id);
    final pendingCount = participants
        .where((p) => p.status == 'invited')
        .length;
    if (pendingCount == 0) continue;

    final people = <Person>[];
    for (final participant in participants) {
      final person = await peopleRepo.getPerson(participant.personId);
      if (person != null) people.add(person);
    }

    result.add(
      QuestNeedingConfirmation(
        quest: quest,
        people: people,
        pendingCount: pendingCount,
      ),
    );
  }
  return result;
}
