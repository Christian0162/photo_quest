import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import 'quest_participants_view_model.dart';
import '../../types/quests/quest_list_item.dart';
import '../../types/quests/quest_category_shelf.dart';

part 'quest_list_view_model.g.dart';

@riverpod
Future<List<Quest>> questList(Ref ref) {
  return ref.watch(questRepositoryProvider).getQuests();
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
