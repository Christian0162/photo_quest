/// Whether a Quest can begin now, and a short line explaining why not (or
/// what's next). See CLAUDE.md §16A, §37.
class QuestStartReadiness {
  const QuestStartReadiness({
    required this.canStart,
    this.hint,
    this.everyoneIn = false,
  });

  final bool canStart;
  final String? hint;

  /// A pair/group Quest whose invited People have all said they're in —
  /// a moment worth celebrating. See design system §49 ("invitation
  /// accepted").
  final bool everyoneIn;
}
