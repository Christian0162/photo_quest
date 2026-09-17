/// App-wide product constants that must not be hardcoded per-screen.
/// See CLAUDE.md §15A.
abstract final class AppConstants {
  /// Default participant cap for a group quest when
  /// `quest.maxParticipants` is null.
  static const defaultGroupQuestParticipantLimit = 5;
}
