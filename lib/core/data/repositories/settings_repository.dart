import '../database/daos/settings_dao.dart';

/// Photobooth preferences, remembered on this device. See CLAUDE.md §16.
class SettingsRepository {
  SettingsRepository(this._dao);

  final SettingsDao _dao;

  static const _countdownKey = 'booth.countdown_seconds';
  static const _clipKey = 'booth.clip_seconds';

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

  /// The saved value if it's still a valid choice, else the first one.
  Future<int> _readChoice(String key, List<int> choices) async {
    final saved = int.tryParse(await _dao.getValue(key) ?? '');
    return choices.contains(saved) ? saved! : choices.first;
  }
}
