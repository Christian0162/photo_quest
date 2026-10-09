import 'memory_summary.dart';

/// One month of the memory box, like a page in a photo album.
class MemoryMonth {
  const MemoryMonth({required this.month, required this.memories});

  /// The first day of the month.
  final DateTime month;
  final List<MemorySummary> memories;
}
