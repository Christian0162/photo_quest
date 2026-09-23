import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/home/home_view_model.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../view_model/quests/quests_needing_confirmation_view_model.dart';
import '../../view_model/quests/today_quest_view_model.dart';
import '../../widget/template/home_template.dart';

/// Home. Wires view models and navigation into [HomeTemplate].
/// See CLAUDE.md §31.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomeTemplate(
      greeting: ref.watch(homeGreetingProvider),
      todayQuest: ref.watch(todayQuestProvider),
      pendingQuests: ref.watch(questsNeedingConfirmationProvider),
      memories: ref.watch(memoryListProvider),
      onRefresh: () async {
        ref.invalidate(memoryListProvider);
        ref.invalidate(questsNeedingConfirmationProvider);
        await ref.read(memoryListProvider.future);
      },
      onOpenSettings: () => context.push(AppRoutes.settings),
      onOpenQuest: (quest) => context.push(AppRoutes.questDetailPath(quest.id)),
      onOpenMemory: (summary) =>
          context.push(AppRoutes.memoryDetailPath(summary.memory.id)),
      onSeeAllMemories: () => context.go(AppRoutes.memories),
      onBrowseQuests: () => context.push(AppRoutes.quests),
      onCreateQuest: () => context.push(AppRoutes.createQuest),
    );
  }
}
