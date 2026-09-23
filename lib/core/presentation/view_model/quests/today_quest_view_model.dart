import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/quests/entities/quest.dart';
import 'quest_list_view_model.dart';

part 'today_quest_view_model.g.dart';

/// Picks the day's featured Quest for Home's hero card from the built-in
/// templates. Stable for the whole calendar day, different the next. See
/// CLAUDE.md §31, design system §14.
@riverpod
Future<Quest?> todayQuest(Ref ref) async {
  final quests = await ref.watch(questListProvider.future);
  final templates = quests.where((q) => q.creatorId == null).toList();
  final pool = templates.isNotEmpty ? templates : quests;
  if (pool.isEmpty) return null;

  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  return pool[dayOfYear % pool.length];
}
