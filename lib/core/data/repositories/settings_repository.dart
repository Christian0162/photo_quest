import '../database/daos/settings_dao.dart';

/// Photobooth preferences, remembered on this device.
class SettingsRepository {
  SettingsRepository(this._dao);

  final SettingsDao _dao;

  static const _countdownKey = 'booth.countdown_seconds';
  static const _clipKey = 'booth.clip_seconds';
  static const _backupKey = 'backup.enabled';

  static const countdownChoices = [3, 5, 10];

  static const clipChoices = [6, 10, 15];

  Future<int> getCountdownSeconds() =>
      _readChoice(_countdownKey, countdownChoices);

  Future<void> setCountdownSeconds(int seconds) =>
      _dao.setValue(_countdownKey, '$seconds');

  Future<int> getClipSeconds() => _readChoice(_clipKey, clipChoices);

  Future<void> setClipSeconds(int seconds) =>
      _dao.setValue(_clipKey, '$seconds');

  /// Whether [accountId] has turned on backing up their memories online.
  /// Consent belongs to one account: the saved value is the account that
  /// chose it, so another account signing in on this phone starts with it off.
  Future<bool> getBackupEnabled(String accountId) async =>
      await _dao.getValue(_backupKey) == accountId;

  Future<void> setBackupEnabled(String accountId, {required bool enabled}) =>
      _dao.setValue(_backupKey, enabled ? accountId : '0');

  Future<int> _readChoice(String key, List<int> choices) async {
    final saved = int.tryParse(await _dao.getValue(key) ?? '');
    return choices.contains(saved) ? saved! : choices.first;
  }
}
