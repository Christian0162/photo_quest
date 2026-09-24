
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
