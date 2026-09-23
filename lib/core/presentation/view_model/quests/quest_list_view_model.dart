import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import 'quest_participants_view_model.dart';

part 'quest_list_view_model.g.dart';

@riverpod
Future<List<Quest>> questList(Ref ref) {
  return ref.watch(questRepositoryProvider).getQuests();
}

/// A Quest as shown on a selection card, with the People joining it.
class QuestListItem {
  const QuestListItem({required this.quest, this.participants = const []});

  final Quest quest;

  /// Only filled for a user-created pair/group Quest. See design system §15.
  final List<Person> participants;
}

/// One shelf on the Quest picker: a category ("For Us", "For Family" …) and
/// its Quests, in the order they were first seen. See CLAUDE.md §33.
class QuestCategoryShelf {
  const QuestCategoryShelf({required this.category, required this.quests});

  final String category;
  final List<QuestListItem> quests;
}

@riverpod
Future<List<QuestCategoryShelf>> questShelves(Ref ref) async {
  final quests = await ref.watch(questListProvider.future);

  final grouped = <String, List<QuestListItem>>{};
  for (final quest in quests) {
    final showsParticipants = quest.type != 'solo' && quest.creatorId != null;
    final participants = showsParticipants
        ? [
            for (final entry in await ref.watch(
              questParticipantsViewModelProvider(quest.id).future,
            ))
              entry.person,
          ]
        : const <Person>[];
    grouped
        .putIfAbsent(quest.category, () => [])
        .add(QuestListItem(quest: quest, participants: participants));
  }

  return [
    for (final MapEntry(key: category, value: items) in grouped.entries)
      QuestCategoryShelf(category: category, quests: items),
  ];
}
