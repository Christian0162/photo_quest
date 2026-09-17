import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database_providers.dart';
import 'memory_repository.dart';

part 'memory_repository_provider.g.dart';

@riverpod
MemoryRepository memoryRepository(Ref ref) {
  return MemoryRepository(ref.watch(memoryDaoProvider));
}
