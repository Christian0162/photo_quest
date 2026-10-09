import 'memory_summary.dart';

/// One month of the memory box, like a page in a photo album.
class MemoryMonth {
  const MemoryMonth({required this.month, required this.memories});

  final DateTime month;
  final List<MemorySummary> memories;
}
