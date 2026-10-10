import '../database/daos/settings_dao.dart';

/// Photobooth preferences, remembered on this device.
class SettingsRepository {
  SettingsRepository(this._dao);

  final SettingsDao _dao;

  static const _countdownKey = 'booth.countdown_seconds';
  static const _clipKey = 'booth.clip_seconds';
  static const _backupKey = 'backup.enabled';
  static const _withheldKey = 'backup.withheld';
  static const _introSeenKey = 'onboarding.intro_seen';

  static const countdownChoices = [3, 5, 10];

  static const clipChoices = [6, 10, 15];

  /// Whether the get-started pages were already shown on this device.
  Future<bool> getIntroSeen() async =>
      await _dao.getValue(_introSeenKey) == '1';

  Future<void> setIntroSeen() => _dao.setValue(_introSeenKey, '1');

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

  /// Memories whose online copy the owner took away. Automatic backup leaves
  /// them alone until the owner shares them again.
  Future<Set<String>> getWithheldMemories() async {
    final saved = await _dao.getValue(_withheldKey) ?? '';
    return {
      for (final id in saved.split(','))
        if (id.isNotEmpty) id,
    };
  }

  Future<void> setMemoryWithheld(
    String memoryId, {
    required bool withheld,
  }) async {
    final ids = await getWithheldMemories();
    final changed = withheld ? ids.add(memoryId) : ids.remove(memoryId);
    if (changed) await _dao.setValue(_withheldKey, ids.join(','));
  }

  Future<int> _readChoice(String key, List<int> choices) async {
    final saved = int.tryParse(await _dao.getValue(key) ?? '');
    return choices.contains(saved) ? saved! : choices.first;
  }
}
