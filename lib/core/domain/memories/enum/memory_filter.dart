/// The three ways to look through the memory box.
enum MemoryFilter {
  thisDay('This day'),

  thisMonth('This month'),

  allJourney('All journey');

  const MemoryFilter(this.label);

  final String label;

  bool includes(DateTime at, DateTime now) => switch (this) {
    thisDay => at.month == now.month && at.day == now.day,
    thisMonth => at.year == now.year && at.month == now.month,
    allJourney => true,
  };
}
