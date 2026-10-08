import '../../../errors/app_failure.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/cloud_memory_repository.dart';
import '../../repositories/memory_repository.dart';
import '../../repositories/settings_repository.dart';
import '../connectivity/connectivity_service.dart';

/// How a "back up everything" run went.
class BackupOutcome {
  const BackupOutcome({
    required this.total,
    required this.backedUp,
    this.failed = 0,
    this.stopped,
  });

  final int total;

  final int backedUp;

  final int failed;

  final SharingFailure? stopped;

  bool get storageFull => stopped?.kind == SharingFailureKind.storageFull;
  bool get complete => stopped == null && failed == 0;
}

/// Keeps memories safe online, only when the person has turned backup on.
///
/// Photos are large and the allowance is small, so this is deliberately
/// polite: it is off until the person turns it on, it only runs on Wi-Fi by
/// itself, it stops at once when storage is full, and a capture is never
/// delayed or lost by it (the memory is already saved on the phone first).
/// "Back up now" is the person's own choice, so it works on any connection.
class MemoryBackupService {
  MemoryBackupService({
    required this._memories,
    required this._cloud,
    required this._settings,
    required this._connectivity,
    required this._auth,
  });

  final MemoryRepository _memories;
  final CloudMemoryRepository _cloud;
  final SettingsRepository _settings;
  final ConnectivityService _connectivity;
  final AuthRepository _auth;

  bool _running = false;

  bool get isRunning => _running;

  /// Backs up every memory on the phone that isn't online yet, newest first.
  /// Stops early when storage is full or the network is gone. [onProgress]
  /// reports memories handled so far and the total.
  Future<BackupOutcome> backUpAll({
    void Function(int done, int total)? onProgress,
  }) async {
    if (_running) return const BackupOutcome(total: 0, backedUp: 0);
    _running = true;
    try {
      final all = [...await _memories.getMemories()]
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      var done = 0;
      var backedUp = 0;
      var failed = 0;
      onProgress?.call(0, all.length);

      for (final memory in all) {
        try {
          await _cloud.backUpMemory(memory.id);
          backedUp++;
        } on SharingFailure catch (failure) {
          switch (failure.kind) {
            case SharingFailureKind.storageFull:
            case SharingFailureKind.offline:
            case SharingFailureKind.notConfigured:
              return BackupOutcome(
                total: all.length,
                backedUp: backedUp,
                failed: failed,
                stopped: failure,
              );
            case _:
              failed++;
          }
        }
        onProgress?.call(++done, all.length);
      }
      return BackupOutcome(
        total: all.length,
        backedUp: backedUp,
        failed: failed,
      );
    } finally {
      _running = false;
    }
  }

  /// Called right after a memory is saved on the phone. Does nothing unless
  /// backup is on, someone is signed in and the phone is on Wi-Fi; any
  /// failure is ignored, because the next launch or "Back up now" catches up.
  Future<void> memorySaved(String memoryId) async {
    if (_running || !await _shouldRunByItself()) return;
    try {
      await _cloud.backUpMemory(memoryId);
    } on Object {
      return;
    }
  }

  /// Called when the app opens: uploads anything still missing, under the
  /// same conditions as [memorySaved].
  Future<void> catchUp() async {
    if (!await _shouldRunByItself()) return;
    try {
      await backUpAll();
    } on Object {
      return;
    }
  }

  Future<bool> _shouldRunByItself() async {
    if (_auth.currentUser == null) return false;
    if (!await _settings.getBackupEnabled()) return false;
    return _connectivity.isOnWifi();
  }
}
