import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/database/database_providers.dart';
import 'quest_repository.dart';

part 'quest_repository_provider.g.dart';

@riverpod
QuestRepository questRepository(Ref ref) {
  return QuestRepository(ref.watch(questDaoProvider));
}
