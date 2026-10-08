import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/backup_providers.dart';
import '../../../data/repositories/cloud_memory_repository_provider.dart';
import '../../../data/repositories/settings_repository_provider.dart';
import '../../../data/services/backup/memory_backup_service.dart';
import '../../../domain/auth/enum/auth_status.dart';
import '../../../errors/app_failure.dart';
import '../../types/settings/backup_state.dart';
import '../auth/auth_session_view_model.dart';

part 'backup_view_model.g.dart';

/// Uploads anything still missing when the app opens (and again after logging
/// in), if the person has turned backup on. Watched once from the app root.
@Riverpod(keepAlive: true)
Future<void> backupCatchUp(Ref ref) async {
  final status = ref.watch(authSessionViewModelProvider);
  if (status is! AuthSignedIn) return;
  await ref.read(memoryBackupServiceProvider).catchUp();
}

/// The backup switch, the storage meter and "Back up now" in Settings.
@riverpod
class BackupViewModel extends _$BackupViewModel {
  @override
  BackupState build() {
    Future.microtask(_load);
    return const BackupState();
  }

  Future<void> _load() async {
    final enabled = await ref
        .read(settingsRepositoryProvider)
        .getBackupEnabled();
    if (ref.mounted) state = state.copyWith(enabled: enabled);
    await refreshUsage();
  }

  Future<void> refreshUsage() async {
    try {
      final usage = await ref
          .read(cloudMemoryRepositoryProvider)
          .getStorageUsage();
      if (ref.mounted) state = state.copyWith(usage: usage);
    } on Object {
      return;
    }
  }

  /// Turns automatic backup on or off. Turning it on also catches up older
  /// memories when the phone is on Wi-Fi.
  Future<void> setEnabled({required bool enabled}) async {
    await ref.read(settingsRepositoryProvider).setBackupEnabled(enabled);
    if (!ref.mounted) return;
    state = state.copyWith(enabled: enabled, message: null, isError: false);
    if (enabled) {
      await ref.read(memoryBackupServiceProvider).catchUp();
      await refreshUsage();
    }
  }

  Future<void> backUpNow() async {
    if (state.running) return;
    state = state.copyWith(
      running: true,
      done: 0,
      total: 0,
      message: null,
      isError: false,
    );
    final outcome = await ref
        .read(memoryBackupServiceProvider)
        .backUpAll(
          onProgress: (done, total) {
            if (ref.mounted) state = state.copyWith(done: done, total: total);
          },
        );
    if (!ref.mounted) return;
    state = state.copyWith(
      running: false,
      message: _describe(outcome),
      isError: !outcome.complete,
    );
    await refreshUsage();
  }

  static String _describe(BackupOutcome outcome) {
    final stopped = outcome.stopped;
    if (stopped != null) {
      return switch (stopped.kind) {
        SharingFailureKind.storageFull =>
          'Your online storage is full. Open a memory and remove its online '
              'copy to make room.',
        _ => stopped.message,
      };
    }
    if (outcome.failed > 0) {
      return "Some memories couldn't be saved. Try again in a bit.";
    }
    if (outcome.total == 0) return 'You have no memories to back up yet.';
    return outcome.total == 1
        ? 'Your memory is backed up.'
        : 'All ${outcome.total} of your memories are backed up.';
  }
}
