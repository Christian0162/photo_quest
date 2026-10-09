import '../../../domain/sharing/entities/shared_quest.dart';

const _keep = Object();

/// The "Back up my memories" section of Settings.
class BackupState {
  const BackupState({
    this.enabled = false,
    this.usage,
    this.running = false,
    this.done = 0,
    this.total = 0,
    this.message,
    this.isError = false,
  });

  final bool enabled;

  final StorageUsage? usage;

  final bool running;
  final int done;
  final int total;

  final String? message;
  final bool isError;

  BackupState copyWith({
    bool? enabled,
    Object? usage = _keep,
    bool? running,
    int? done,
    int? total,
    Object? message = _keep,
    bool? isError,
  }) => BackupState(
    enabled: enabled ?? this.enabled,
    usage: identical(usage, _keep) ? this.usage : usage as StorageUsage?,
    running: running ?? this.running,
    done: done ?? this.done,
    total: total ?? this.total,
    message: identical(message, _keep) ? this.message : message as String?,
    isError: isError ?? this.isError,
  );
}
