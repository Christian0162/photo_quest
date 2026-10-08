import '../../../config/constant/app_avatars.dart';
import '../../domain/people/enum/mood.dart';
import '../database/daos/settings_dao.dart';

/// Preferences (photobooth, mood), remembered on this device. See
/// CLAUDE.md §16.
class SettingsRepository {
  SettingsRepository(this._dao);

  final SettingsDao _dao;

  static const _countdownKey = 'booth.countdown_seconds';
  static const _clipKey = 'booth.clip_seconds';
  static const _moodKey = 'profile.mood';
  static const _avatarKey = 'profile.avatar';

  /// Countdown lengths people can pick, in seconds.
  static const countdownChoices = [3, 5, 10];

  /// 360° clip lengths people can pick, in seconds.
  static const clipChoices = [6, 10, 15];

  Future<int> getCountdownSeconds() =>
      _readChoice(_countdownKey, countdownChoices);

  Future<void> setCountdownSeconds(int seconds) =>
      _dao.setValue(_countdownKey, '$seconds');

  Future<int> getClipSeconds() => _readChoice(_clipKey, clipChoices);

  Future<void> setClipSeconds(int seconds) =>
      _dao.setValue(_clipKey, '$seconds');

  /// How the device owner said they feel, or null if they never said.
  Future<Mood?> getMood() async => Mood.fromName(await _dao.getValue(_moodKey));

  Future<void> setMood(Mood? mood) => _dao.setValue(_moodKey, mood?.name ?? '');

  /// The avatar id the device owner picked, or null if they never did.
  Future<String?> getAvatar() async {
    final saved = await _dao.getValue(_avatarKey);
    return AppAvatars.ids.contains(saved) ? saved : null;
  }

  Future<void> setAvatar(String avatarId) =>
      _dao.setValue(_avatarKey, avatarId);

  /// The saved value if it's still a valid choice, else the first one.
  Future<int> _readChoice(String key, List<int> choices) async {
    final saved = int.tryParse(await _dao.getValue(key) ?? '');
    return choices.contains(saved) ? saved! : choices.first;
  }
}
