import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/memory_repository_provider.dart';
import '../../domain/entities/memory.dart';

part 'memory_list_view_model.g.dart';

@riverpod
Future<List<Memory>> memoryList(Ref ref) {
  return ref.watch(memoryRepositoryProvider).getMemories();
}
