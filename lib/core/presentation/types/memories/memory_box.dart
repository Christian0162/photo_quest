import '../../../domain/memories/enum/memory_filter.dart';
import 'memory_summary.dart';
import 'memory_month.dart';
import '../../view_model/memories/memory_list_view_model.dart';

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
