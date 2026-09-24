import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/memories/enum/memory_filter.dart';
import '../../../domain/people/entities/person.dart';
import '../../types/memories/memory_box.dart';
import '../../types/memories/memory_month.dart';
import '../../types/memories/memory_summary.dart';

part 'memory_list_view_model.g.dart';

@riverpod
Future<List<MemorySummary>> memoryList(Ref ref) async {
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  final peopleRepo = ref.watch(peopleRepositoryProvider);
  final questRepo = ref.watch(questRepositoryProvider);

  final memories = await memoryRepo.getMemories();
  final summaries = <MemorySummary>[];
  for (final memory in memories) {
    final photos = await memoryRepo.getPhotos(memory.id);
    final cover =
        photos.where((p) => p.id == memory.coverPhotoId).firstOrNull ??
        photos.firstOrNull;

    final people = <Person>[];
    for (final id in await memoryRepo.getPersonIds(memory.id)) {
      final person = await peopleRepo.getPerson(id);
      if (person != null) people.add(person);
    }

    final session = await memoryRepo.getSession(memory.questSessionId);
    final quest = session == null
        ? null
        : await questRepo.getQuest(session.questId);

    summaries.add(
      MemorySummary(
        memory: memory,
        coverPhoto: cover,
        people: people,
        photos: [?cover, ...photos.where((p) => p != cover)],
        questCategory: quest?.category,
      ),
    );
  }
  return summaries;
}

/// Buckets [memories] (already newest first) by month, newest first.
List<MemoryMonth> groupByMonth(List<MemorySummary> memories) {
  final months = <DateTime, List<MemorySummary>>{};
  for (final summary in memories) {
    final at = summary.memory.capturedAt;
    months.putIfAbsent(DateTime(at.year, at.month), () => []).add(summary);
  }
  return [
    for (final MapEntry(key: month, value: items) in months.entries)
      MemoryMonth(month: month, memories: items),
  ];
}

/// Which [MemoryFilter] the Memories screen is showing.
@riverpod
class MemoryFilterSelection extends _$MemoryFilterSelection {
  @override
  MemoryFilter build() => MemoryFilter.allJourney;

  void select(MemoryFilter filter) => state = filter;
}

/// Filtering is synchronous on top of [memoryListProvider], so switching
/// filters never flashes a loading state. See CLAUDE.md §38, §43.
@riverpod
AsyncValue<MemoryBox> memoryBox(Ref ref) {
  final filter = ref.watch(memoryFilterSelectionProvider);
  return ref
      .watch(memoryListProvider)
      .whenData((list) => MemoryBox.from(list, filter, DateTime.now()));
}

/// A memory made on this calendar day in an earlier year, if there is one —
/// the time-capsule moment ("2 years ago today"). The most recent year wins.
/// See CLAUDE.md §21, §68.
@riverpod
Future<MemorySummary?> onThisDayMemory(Ref ref) async {
  final memories = await ref.watch(memoryListProvider.future);
  final today = DateTime.now();
  for (final summary in memories) {
    final at = summary.memory.capturedAt;
    if (at.year < today.year &&
        at.month == today.month &&
        at.day == today.day) {
      return summary;
    }
  }
  return null;
}
