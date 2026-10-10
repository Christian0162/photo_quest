import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/quests/entities/quest.dart';
import '../../../types/memories/memory_summary.dart';
import '../../../types/quests/quest_needing_confirmation.dart';
import '../../atoms/common/md_fade_slide_in.dart';
import '../../atoms/common/md_skeleton_box.dart';
import '../../atoms/common/md_smooth_switch.dart';
import '../../molecules/quests/md_idea_tile.dart';
import '../../molecules/common/md_section_header.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/memories/md_on_this_day_card.dart';
import '../../organisms/quests/md_pending_quest_tray.dart';
import '../../organisms/memories/md_recent_memories_section.dart';
import '../../organisms/quests/md_today_quest_card.dart';
import '../../molecules/home/md_home_greeting.dart';
import '../../atoms/common/md_gutter_padding.dart';

/// Answers "What can we do today?" — a greeting, one hero Quest, anything
/// waiting on people, and a shelf of recent memories. Never a dashboard.
/// Sections ease in top-first, and loading placeholders cross-fade into
/// content instead of popping.
class HomeTemplate extends StatelessWidget {
  const HomeTemplate({
    super.key,
    required this.greeting,
    required this.todayQuest,
    required this.pendingQuests,
    required this.memories,
    this.onThisDay = const AsyncData(null),
    required this.onRefresh,
    required this.onOpenSettings,
    required this.onOpenQuest,
    required this.onOpenMemory,
    required this.onSeeAllMemories,
    required this.onBrowseQuests,
    required this.onCreateQuest,
  });

  static const _recentMemoryCount = 8;

  final String greeting;
  final AsyncValue<Quest?> todayQuest;
  final AsyncValue<List<QuestNeedingConfirmation>> pendingQuests;
  final AsyncValue<List<MemorySummary>> memories;

  final AsyncValue<MemorySummary?> onThisDay;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSettings;
  final ValueChanged<Quest> onOpenQuest;
  final ValueChanged<MemorySummary> onOpenMemory;
  final VoidCallback onSeeAllMemories;
  final VoidCallback onBrowseQuests;
  final VoidCallback onCreateQuest;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final onThisDaySummary = onThisDay.value;
    final pending = pendingQuests.value ?? const [];

    // Each section is one keyed entry, so a section that shows up later
    // (a pending quest, an "on this day") eases in on its own instead of
    // reusing a neighbour's finished animation.
    final sections = <(String, Widget)>[
      (
        'greeting',
        MdGutterPadding(
          child: MdHomeGreeting(
            greeting: greeting,
            today: today,
            onOpenSettings: onOpenSettings,
          ),
        ),
      ),
      (
        'today',
        MdGutterPadding(
          child: MdSmoothSwitch(
            child: todayQuest.when(
              loading: () => const MdSkeletonBox(
                key: ValueKey('today-loading'),
                height: 520,
                radius: AppRadius.base,
              ),
              error: (error, stack) => const SizedBox.shrink(),
              data: (quest) => quest == null
                  ? const SizedBox.shrink()
                  : MdTodayQuestCard(
                      key: ValueKey(quest.id),
                      quest: quest,
                      onStart: () => onOpenQuest(quest),
                    ),
            ),
          ),
        ),
      ),
      if (onThisDaySummary != null)
        (
          'on-this-day',
          MdGutterPadding(
            child: MdOnThisDayCard(
              summary: onThisDaySummary,
              today: today,
              onTap: () => onOpenMemory(onThisDaySummary),
            ),
          ),
        ),
      if (pending.isNotEmpty)
        (
          'pending',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              const MdGutterPadding(
                child: MdSectionHeader(
                  title: 'Waiting on your people',
                  subtitle: 'One nudge and the quest is on.',
                ),
              ),
              const SizedBox(height: AppSpacing.ms),
              MdPendingQuestTray(
                entries: pending,
                onOpen: (entry) => onOpenQuest(entry.quest),
              ),
            ],
          ),
        ),
      (
        'memories',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            MdGutterPadding(
              child: MdSectionHeader(
                title: 'Recent memories',
                trailing: memories.value?.isNotEmpty ?? false
                    ? TextButton(
                        onPressed: onSeeAllMemories,
                        child: const Text('See all'),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.ms),
            MdSmoothSwitch(
              child: memories.when(
                loading: () => KeyedSubtree(
                  key: const ValueKey('memories-loading'),
                  child: MdRecentMemoriesSection.skeleton(context),
                ),
                error: (error, stack) => const MdGutterPadding(
                  key: ValueKey('memories-error'),
                  child: Text(
                    "We couldn't load your memories right now.",
                    style: AppTypography.bodyMuted,
                  ),
                ),
                data: (list) => MdRecentMemoriesSection(
                  key: const ValueKey('memories'),
                  memories: list.take(_recentMemoryCount).toList(),
                  onOpen: onOpenMemory,
                ),
              ),
            ),
          ],
        ),
      ),
      (
        'more',
        MdGutterPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              const MdSectionHeader(
                title: 'Something else in mind?',
                subtitle: 'Pick another quest, or make your own.',
              ),
              const SizedBox(height: AppSpacing.ms),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: MdIdeaTile(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Browse quests',
                        subtitle: 'For us, family, friends',
                        color: AppColors.softPeach,
                        onTap: onBrowseQuests,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.ms),
                    Expanded(
                      child: MdIdeaTile(
                        icon: Icons.edit_rounded,
                        title: 'Create your own',
                        subtitle: 'Your idea, your people',
                        color: AppColors.paper,
                        onTap: onCreateQuest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return MdAppScaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.coralInk,
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.tabScrollEnd,
          ),
          children: [
            for (final (index, (id, section)) in sections.indexed)
              Padding(
                key: ValueKey(id),
                padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.lg),
                child: MdFadeSlideIn(order: index, child: section),
              ),
          ],
        ),
      ),
    );
  }
}
