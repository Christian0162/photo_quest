import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/backup/memory_backup_service.dart';
import '../services/connectivity/connectivity_service.dart';
import 'auth_repository_provider.dart';
import 'cloud_memory_repository_provider.dart';
import 'memory_repository_provider.dart';
import 'settings_repository_provider.dart';

part 'backup_providers.g.dart';

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => ConnectivityService();

@Riverpod(keepAlive: true)
MemoryBackupService memoryBackupService(Ref ref) {
  return MemoryBackupService(
    memories: ref.watch(memoryRepositoryProvider),
    cloud: ref.watch(cloudMemoryRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    auth: ref.watch(authRepositoryProvider),
  );
}
