import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/people_repository_provider.dart';
import '../../../domain/memories/entities/memory.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/people/entities/person.dart';

part 'memory_list_view_model.g.dart';

/// A Memory as shown in a collection: its cover photo and the people who
/// were there. See CLAUDE.md §38 (prioritize photography, dates,
/// participants).
class MemorySummary {
  const MemorySummary({
    required this.memory,
    required this.coverPhoto,
    required this.people,
  });

  final Memory memory;

  /// The chosen cover, else the first photo, else null (no photos yet).
  final Photo? coverPhoto;
  final List<Person> people;
}

@riverpod
Future<List<MemorySummary>> memoryList(Ref ref) async {
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  final peopleRepo = ref.watch(peopleRepositoryProvider);

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

    summaries.add(
      MemorySummary(memory: memory, coverPhoto: cover, people: people),
    );
  }
  return summaries;
}

/// One month of the memory box, like a page in a photo album.
class MemoryMonth {
  const MemoryMonth({required this.month, required this.memories});

  /// The first day of the month.
  final DateTime month;
  final List<MemorySummary> memories;
}

/// Memories bucketed by month, newest first. See CLAUDE.md §38.
@riverpod
Future<List<MemoryMonth>> memoriesByMonth(Ref ref) async {
  final memories = await ref.watch(memoryListProvider.future);

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
