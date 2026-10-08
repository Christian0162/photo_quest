import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/homes/day_moments_view_model.dart';
import '../../view_model/homes/home_view_model.dart';
import '../../view_model/homes/profile_view_model.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../view_model/quests/quests_needing_confirmation_view_model.dart';
import '../../view_model/quests/today_quest_view_model.dart';
import '../../widget/organisms/md_mood_sheet.dart';
import '../../widget/templates/home_template.dart';

/// Home. Wires view models, sheets and navigation into [HomeTemplate].
/// See CLAUDE.md §31.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(moodSettingProvider);
    final avatarId = ref.watch(avatarSettingProvider).value;

    return HomeTemplate(
      greeting: ref.watch(homeGreetingProvider),
      todayQuest: ref.watch(todayQuestProvider),
      pendingQuests: ref.watch(questsNeedingConfirmationProvider),
      memories: ref.watch(memoryListProvider),
      onThisDay: ref.watch(onThisDayMemoryProvider),
      mood: mood.value,
      avatarId: avatarId,
      moments: ref.watch(dayMomentListProvider),
      onRefresh: () async {
        ref.invalidate(memoryListProvider);
        ref.invalidate(questsNeedingConfirmationProvider);
        ref.invalidate(dayMomentListProvider);
        await ref.read(memoryListProvider.future);
      },
      onOpenMood: () => showMoodSheet(
        context,
        current: mood.value,
        onChosen: ref.read(moodSettingProvider.notifier).choose,
      ),
      onOpenProfile: () => context.push(AppRoutes.settings),
      onAddMoment: () => context.push(AppRoutes.momentCapture),
      onOpenMoment: (moment) =>
          context.push(AppRoutes.momentViewPath(moment.id)),
      onOpenQuest: (quest) => context.push(AppRoutes.questDetailPath(quest.id)),
      onOpenMemory: (summary) => context.push(
        AppRoutes.memoryDetailPath(summary.memory.id),
        extra: summary.coverPhoto?.thumbnailPath,
      ),
      onSeeAllMemories: () => context.go(AppRoutes.memories),
      onBrowseQuests: () => context.go(AppRoutes.quests),
      onCreateQuest: () => context.push(AppRoutes.createQuest),
    );
  }
}
