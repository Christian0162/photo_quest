import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/quest_repository_provider.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_shot.dart';

part 'quest_detail_view_model.g.dart';

class QuestDetail {
  const QuestDetail({required this.quest, required this.shots});

  final Quest quest;
  final List<QuestShot> shots;
}

@riverpod
Future<QuestDetail> questDetail(Ref ref, String questId) async {
  final repo = ref.watch(questRepositoryProvider);
  final quest = await repo.getQuest(questId);
  if (quest == null) {
    throw StateError('Quest $questId was not found.');
  }
  final shots = await repo.getShots(questId);
  return QuestDetail(quest: quest, shots: shots);
}
