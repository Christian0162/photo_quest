import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../types/quests/quest_detail.dart';

part 'quest_detail_view_model.g.dart';

@riverpod
Future<QuestDetail> questDetail(Ref ref, String questId) async {
  final repo = ref.watch(questRepositoryProvider);
  final peopleRepo = ref.watch(peopleRepositoryProvider);

  final quest = await repo.getQuest(questId);
  if (quest == null) {
    throw StateError('Quest $questId was not found.');
  }
  final shots = await repo.getShots(questId);
  final creator = quest.creatorId == null
      ? null
      : await peopleRepo.getPerson(quest.creatorId!);
  return QuestDetail(quest: quest, shots: shots, creator: creator);
}
