import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/memories/entities/memory.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/people/entities/person.dart';

part 'memory_list_view_model.g.dart';

/// A Memory as shown in a collection: its cover photo, its photos, the
/// people who were there and the kind of quest it came from. See CLAUDE.md
/// §38 (prioritize photography, dates, participants).
class MemorySummary {
  const MemorySummary({
    required this.memory,
    required this.coverPhoto,
    required this.people,
    this.photos = const [],
    this.questCategory,
  });

  final Memory memory;

  /// The chosen cover, else the first photo, else null (no photos yet).
  final Photo? coverPhoto;
  final List<Person> people;

  /// Every shot of the memory, cover first, in capture order after that.
  final List<Photo> photos;

  /// The category of the Quest this memory came from ("For Us", ...), used
  /// to pick its occasion. Null if the quest has since been deleted.
  final String? questCategory;

  /// A short, human line about the memory: its note, else who was there.
  String get description {
    final note = memory.note?.trim();
    if (note != null && note.isNotEmpty) return note;

    final others = [
      for (final person in people)
        if (person.type != 'self') person.name,
    ];
    return switch (others.length) {
      0 => 'Just you, and a moment worth keeping.',
      1 => 'You and ${others[0]}, together.',
      2 => 'You, ${others[0]} and ${others[1]}, together.',
      _ => 'You, ${others[0]}, ${others[1]} and ${others.length - 2} more.',
    };
  }
}

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

/// One month of the memory box, like a page in a photo album.
class MemoryMonth {
  const MemoryMonth({required this.month, required this.memories});

  /// The first day of the month.
  final DateTime month;
  final List<MemorySummary> memories;
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

/// The three ways to look through the memory box.
enum MemoryFilter {
  /// Today's date in any year — today, and this day a year ago, and so on.
  thisDay('This day'),

  /// This calendar month, this year.
  thisMonth('This month'),

  /// Every memory, ever.
  allJourney('All journey');

  const MemoryFilter(this.label);

  final String label;

  bool includes(DateTime at, DateTime now) => switch (this) {
    thisDay => at.month == now.month && at.day == now.day,
    thisMonth => at.year == now.year && at.month == now.month,
    allJourney => true,
  };
}

/// Which [MemoryFilter] the Memories screen is showing.
@riverpod
class MemoryFilterSelection extends _$MemoryFilterSelection {
  @override
  MemoryFilter build() => MemoryFilter.allJourney;

  void select(MemoryFilter filter) => state = filter;
}

/// The memory box as the Memories screen shows it: the chosen filter, how
/// many memories each filter holds, and the matching memories by month.
class MemoryBox {
  const MemoryBox({
    required this.filter,
    required this.counts,
    required this.months,
  });

  factory MemoryBox.from(
    List<MemorySummary> memories,
    MemoryFilter filter,
    DateTime now,
  ) {
    bool matches(MemoryFilter f, MemorySummary m) =>
        f.includes(m.memory.capturedAt, now);
    return MemoryBox(
      filter: filter,
      counts: {
        for (final f in MemoryFilter.values)
          f: memories.where((m) => matches(f, m)).length,
      },
      months: groupByMonth([
        for (final m in memories)
          if (matches(filter, m)) m,
      ]),
    );
  }

  final MemoryFilter filter;
  final Map<MemoryFilter, int> counts;
  final List<MemoryMonth> months;

  /// True when there are no memories at all, not just none in [filter].
  bool get isEmpty => counts[MemoryFilter.allJourney] == 0;
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
