import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/moments/entities/day_moment.dart';
import '../../../domain/people/enum/mood.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../types/memories/memory_summary.dart';
import '../../types/quests/quest_needing_confirmation.dart';
import '../atoms/md_fade_slide_in.dart';
import '../atoms/md_profile_button.dart';
import '../atoms/md_section_action.dart';
import '../atoms/md_skeleton_box.dart';
import '../atoms/md_smooth_switch.dart';
import '../molecules/md_idea_tile.dart';
import '../molecules/md_mood_pill.dart';
import '../molecules/md_section_header.dart';
import '../organisms/md_app_scaffold.dart';
import '../organisms/md_day_moments_row.dart';
import '../organisms/md_on_this_day_card.dart';
import '../organisms/md_pending_quest_card.dart';
import '../organisms/md_recent_memories_section.dart';
import '../organisms/md_today_quest_card.dart';

/// Answers "What can we do today?" — a greeting, one hero Quest, anything
/// waiting on people, and a shelf of recent memories. Never a dashboard.
/// Sections ease in top-first, and loading placeholders cross-fade into
/// content instead of popping. See CLAUDE.md §31, design system §13-14.
class HomeTemplate extends StatelessWidget {
  const HomeTemplate({
    super.key,
    required this.greeting,
    required this.todayQuest,
    required this.pendingQuests,
    required this.memories,
    this.onThisDay = const AsyncData(null),
    this.now,
    required this.onRefresh,
    this.mood,
    this.avatarId,
    this.moments = const AsyncData([]),
    required this.onOpenMood,
    required this.onOpenProfile,
    required this.onAddMoment,
    required this.onOpenMoment,
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

  /// A memory from this date in an earlier year, resurfaced near the top.
  final AsyncValue<MemorySummary?> onThisDay;
  final Future<void> Function() onRefresh;

  /// The moment to treat as "now". Previews pin it; the app leaves it null.
  final DateTime? now;
  final Mood? mood;

  /// The avatar picked for the profile button, if any.
  final String? avatarId;

  /// "Your Day" moments that are still showing.
  final AsyncValue<List<DayMoment>> moments;
  final VoidCallback onOpenMood;
  final VoidCallback onOpenProfile;
  final VoidCallback onAddMoment;
  final ValueChanged<DayMoment> onOpenMoment;
  final ValueChanged<Quest> onOpenQuest;
  final ValueChanged<MemorySummary> onOpenMemory;
  final VoidCallback onSeeAllMemories;
  final VoidCallback onBrowseQuests;
  final VoidCallback onCreateQuest;

  @override
  Widget build(BuildContext context) {
    final today = now ?? DateTime.now();
    final onThisDaySummary = onThisDay.value;
    final pending = pendingQuests.value ?? const [];

    // Each section is one keyed entry, so a section that shows up later
    // (a pending quest, an "on this day") eases in on its own instead of
    // reusing a neighbour's finished animation.
    final sections = <(String, Widget)>[
      (
        'greeting',
        _Padded(
          child: _Greeting(
            greeting: greeting,
            today: today,
            mood: mood,
            avatarId: avatarId,
            onOpenMood: onOpenMood,
            onOpenProfile: onOpenProfile,
          ),
        ),
      ),
      (
        'your-day',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Padded(
              child: MdSectionHeader(
                title: 'Moments & Stories',
                subtitle: 'Little moments that matters',
              ),
            ),
            const SizedBox(height: AppSpacing.ms),
            MdDayMomentsRow(
              moments: moments,
              now: today,
              onAdd: onAddMoment,
              onOpen: onOpenMoment,
            ),
          ],
        ),
      ),
      (
        'today',
        _Padded(
          child: MdSmoothSwitch(
            child: todayQuest.when(
              loading: () => const MdSkeletonBox(
                key: ValueKey('today-loading'),
                height: 460,
                radius: AppRadius.photo,
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
          _Padded(
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
          _Padded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MdSectionHeader(
                  title: "Needs everyone's OK",
                  subtitle: 'Get your people to say they’re in.',
                ),
                const SizedBox(height: AppSpacing.ms),
                for (final entry in pending)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: MdPendingQuestCard(
                      entry: entry,
                      onTap: () => onOpenQuest(entry.quest),
                    ),
                  ),
              ],
            ),
          ),
        ),
      (
        'memories',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Padded(
              child: MdSectionHeader(
                title: 'Recent memories',
                trailing: memories.value?.isNotEmpty ?? false
                    ? MdSectionAction(
                        label: 'See all',
                        onPressed: onSeeAllMemories,
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
                error: (error, stack) => const _Padded(
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
        _Padded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

/// Today's date as a small kicker, the greeting, and the invitation —
/// with "memory" inked in coral so the one thing the app is for stands out.
class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.greeting,
    required this.today,
    required this.mood,
    required this.avatarId,
    required this.onOpenMood,
    required this.onOpenProfile,
  });

  final String greeting;
  final DateTime today;
  final Mood? mood;
  final String? avatarId;
  final VoidCallback onOpenMood;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // How you feel on the left, you on the right.
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: MdMoodPill(mood: mood, onTap: onOpenMood),
              ),
            ),
            MdProfileButton(avatarId: avatarId, onTap: onOpenProfile),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          DateFormat('EEEE · MMMM d').format(today).toUpperCase(),
          style: AppTypography.overline,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(greeting, style: AppTypography.bodyMuted),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          header: true,
          label: "Let's make a memory.",
          excludeSemantics: true,
          child: Text.rich(
            TextSpan(
              text: "Let's make a ",
              children: [
                TextSpan(
                  text: 'memory.',
                  style: AppTypography.display.copyWith(
                    color: AppColors.coralInk,
                  ),
                ),
              ],
            ),
            style: AppTypography.display,
          ),
        ),
      ],
    );
  }
}

class _Padded extends StatelessWidget {
  const _Padded({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: child,
    );
  }
}
