/// App-wide product constants that must not be hardcoded per-screen.
/// See CLAUDE.md §15A.
abstract final class AppConstants {
  /// Default participant cap for a group quest when
  /// `quest.maxParticipants` is null.
  static const defaultGroupQuestParticipantLimit = 5;

  /// How long a "Your Day" moment stays before it disappears.
  static const dayMomentLifetime = Duration(hours: 24);

  /// The longest caption a moment can carry.
  static const dayMomentCaptionLimit = 80;
}
