import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../types/async_value_loading.dart';
import '../../view_model/homes/home_view_model.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../view_model/quests/quests_needing_confirmation_view_model.dart';
import '../../view_model/quests/today_quest_view_model.dart';
import '../../widget/molecules/common/md_screen_loading.dart';
import '../../widget/organisms/common/md_app_scaffold.dart';
import '../../widget/templates/home/home_template.dart';

/// Home. Wires view models and navigation into [HomeTemplate].
/// See CLAUDE.md §31.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayQuest = ref.watch(todayQuestProvider);
    final memories = ref.watch(memoryListProvider);
    // Today's quest and the recent memories are the page: until both have
    // arrived, show just the loader (the tab bar stays).
    if (todayQuest.isFirstFetch || memories.isFirstFetch) {
      return const MdAppScaffold(
        body: MdScreenLoading(message: 'Getting today ready…'),
      );
    }

    return HomeTemplate(
      greeting: ref.watch(homeGreetingProvider),
      todayQuest: todayQuest,
      pendingQuests: ref.watch(questsNeedingConfirmationProvider),
      memories: memories,
      onThisDay: ref.watch(onThisDayMemoryProvider),
      onRefresh: () async {
        ref.invalidate(memoryListProvider);
        ref.invalidate(questsNeedingConfirmationProvider);
        await ref.read(memoryListProvider.future);
      },
      onOpenSettings: () => context.push(AppRoutes.settings),
      onOpenQuest: (quest) => context.push(AppRoutes.questDetailPath(quest.id)),
      onOpenMemory: (summary) => context.push(
        AppRoutes.memoryDetailPath(summary.memory.id),
        extra: summary.coverPhoto?.thumbnailPath,
      ),
      onSeeAllMemories: () => context.go(AppRoutes.memories),
      onBrowseQuests: () => context.push(AppRoutes.quests),
      onCreateQuest: () => context.push(AppRoutes.createQuest),
    );
  }
}
