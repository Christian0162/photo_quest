import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/quest_repository_provider.dart';
import '../../domain/entities/quest.dart';

part 'quest_list_view_model.g.dart';

@riverpod
Future<List<Quest>> questList(Ref ref) {
  return ref.watch(questRepositoryProvider).getQuests();
}
