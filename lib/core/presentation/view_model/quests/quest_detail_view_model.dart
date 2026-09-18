import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';

part 'quest_detail_view_model.g.dart';

class QuestDetail {
  const QuestDetail({required this.quest, required this.shots, this.creator});

  final Quest quest;
  final List<QuestShot> shots;

  /// Null for built-in quest templates. See design system §16.
  final Person? creator;
}

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
