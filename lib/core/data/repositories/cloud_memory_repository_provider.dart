import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_repository_provider.dart';
import 'cloud_friends_repository.dart';
import 'cloud_memory_repository.dart';
import 'cloud_quest_repository.dart';
import 'memory_repository_provider.dart';
import 'quest_repository_provider.dart';
import 'service_providers.dart';

part 'cloud_memory_repository_provider.g.dart';

@Riverpod(keepAlive: true)
CloudMemoryRepository cloudMemoryRepository(Ref ref) {
  return SupabaseCloudMemoryRepository(
    client: ref.watch(supabaseClientProvider),
    memories: ref.watch(memoryRepositoryProvider),
    quests: ref.watch(questRepositoryProvider),
    images: ref.watch(imageProcessingServiceProvider),
  );
}

@Riverpod(keepAlive: true)
CloudFriendsRepository cloudFriendsRepository(Ref ref) {
  return SupabaseCloudFriendsRepository(
    client: ref.watch(supabaseClientProvider),
  );
}

@Riverpod(keepAlive: true)
CloudQuestRepository cloudQuestRepository(Ref ref) {
  return SupabaseCloudQuestRepository(
    client: ref.watch(supabaseClientProvider),
    quests: ref.watch(questRepositoryProvider),
  );
}
