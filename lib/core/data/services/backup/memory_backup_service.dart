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
  /// reports memories handled so far and the total. With [sharedQuestsOnly],
  /// only memories from quests friends were invited to are considered.
  Future<BackupOutcome> backUpAll({
    void Function(int done, int total)? onProgress,
    bool sharedQuestsOnly = false,
  }) async {
    if (_running) return const BackupOutcome(total: 0, backedUp: 0);
    final accountId = _auth.currentUser?.id;
    _running = true;
    try {
      var all = [...await _memories.getMemories()]
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      if (sharedQuestsOnly) {
        final shared = [
          for (final memory in all)
            if (await _cloud.isFromSharedQuest(memory.id)) memory,
        ];
        all = shared;
      }
      var done = 0;
      var backedUp = 0;
      var failed = 0;
      onProgress?.call(0, all.length);

      for (final memory in all) {
        if (_auth.currentUser?.id != accountId) {
          return BackupOutcome(
            total: all.length,
            backedUp: backedUp,
            failed: failed,
            stopped: const SharingFailure.unknown(),
          );
        }
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
  ///
  /// A memory from a quest the person invited friends to is also saved, even
  /// with backup off: they chose to do it together, and the friends can only
  /// see and add to the memory once it is online.
  Future<void> memorySaved(String memoryId) async {
    if (_running) return;
    try {
      final accountId = _auth.currentUser?.id;
      if (accountId == null || !await _connectivity.isOnWifi()) return;
      if (await _settings.getBackupEnabled(accountId) ||
          await _cloud.isFromSharedQuest(memoryId)) {
        await _cloud.backUpMemory(memoryId);
      }
    } on Object {
      return;
    }
  }

  /// Called when the app opens: uploads anything still missing, under the
  /// same conditions as [memorySaved].
  Future<void> catchUp() async {
    try {
      final accountId = _auth.currentUser?.id;
      if (accountId == null || !await _connectivity.isOnWifi()) return;
      await backUpAll(
        sharedQuestsOnly: !await _settings.getBackupEnabled(accountId),
      );
    } on Object {
      return;
    }
  }
}
