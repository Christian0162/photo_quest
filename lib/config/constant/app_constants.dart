/// App-wide product constants that must not be hardcoded per-screen.
abstract final class AppConstants {
  /// Default participant cap for a group quest when
  /// `quest.maxParticipants` is null.
  static const defaultGroupQuestParticipantLimit = 5;

  static const inviteValidDays = 7;

  static const inviteMaxUses = 5;

  /// Longest side, in pixels, of the compressed copy of a photo that is
  /// uploaded for sharing. The full-size original stays on the phone.
  static const sharedPhotoMaxSide = 1600;

  static const sharedPhotoJpegQuality = 82;

  /// The largest file the `photos` bucket accepts. Bigger clips are shared
  /// as their still poster instead.
  static const sharedFileMaxBytes = 10 * 1024 * 1024;
}
