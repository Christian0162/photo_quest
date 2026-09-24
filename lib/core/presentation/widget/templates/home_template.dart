import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../view_model/quests/quests_needing_confirmation_view_model.dart';
import '../atoms/fade_slide_in.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/app_card.dart';
import '../molecules/section_header.dart';
import '../organisms/app_scaffold.dart';
import '../organisms/on_this_day_card.dart';
import '../organisms/pending_quest_card.dart';
import '../organisms/recent_memories_section.dart';
import '../organisms/today_quest_card.dart';

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

  /// A memory from this date in an earlier year, resurfaced near the top.
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
        _Padded(
          child: _Greeting(
            greeting: greeting,
            today: today,
            onOpenSettings: onOpenSettings,
          ),
        ),
      ),
      (
        'today',
        _Padded(
          child: _SmoothSwitch(
            child: todayQuest.when(
              loading: () => const SkeletonBox(
                key: ValueKey('today-loading'),
                height: 460,
                radius: AppRadius.photo,
              ),
              error: (error, stack) => const SizedBox.shrink(),
              data: (quest) => quest == null
                  ? const SizedBox.shrink()
                  : TodayQuestCard(
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
            child: OnThisDayCard(
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
                const SizedBox(height: AppSpacing.sm),
                const SectionHeader(
                  title: "Needs everyone's OK",
                  subtitle: 'Get your people to say they’re in.',
                ),
                const SizedBox(height: AppSpacing.ms),
                for (final entry in pending)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: PendingQuestCard(
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
            const SizedBox(height: AppSpacing.sm),
            _Padded(
              child: SectionHeader(
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
            _SmoothSwitch(
              child: memories.when(
                loading: () => KeyedSubtree(
                  key: const ValueKey('memories-loading'),
                  child: RecentMemoriesSection.skeleton(context),
                ),
                error: (error, stack) => const _Padded(
                  key: ValueKey('memories-error'),
                  child: Text(
                    "We couldn't load your memories right now.",
                    style: AppTypography.bodyMuted,
                  ),
                ),
                data: (list) => RecentMemoriesSection(
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
              const SizedBox(height: AppSpacing.sm),
              const SectionHeader(
                title: 'Something else in mind?',
                subtitle: 'Pick another quest, or make your own.',
              ),
              const SizedBox(height: AppSpacing.ms),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _IdeaTile(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Browse quests',
                        subtitle: 'For us, family, friends',
                        color: AppColors.softPeach,
                        onTap: onBrowseQuests,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.ms),
                    Expanded(
                      child: _IdeaTile(
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

    return AppScaffold(
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
                child: FadeSlideIn(order: index, child: section),
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
    required this.onOpenSettings,
  });

  final String greeting;
  final DateTime today;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RoundIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onPressed: onOpenSettings,
        ),
      ],
    );
  }
}

/// A soft paper circle for secondary header actions (settings, add).
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
      ),
      child: IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.square(AppTouch.minTarget),
        ),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

/// A half-width "other ways in" card: an icon badge, a title and one line.
class _IdeaTile extends StatelessWidget {
  const _IdeaTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color,
      radius: AppRadius.xl,
      onTap: onTap,
      semanticLabel: '$title. $subtitle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color == AppColors.paper
                  ? AppColors.sunken
                  : AppColors.paper,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppIconSizes.md),
          ),
          const SizedBox(height: AppSpacing.ms),
          Text(title, style: AppTypography.heading3),
          const SizedBox(height: AppSpacing.xxs),
          Text(subtitle, style: AppTypography.caption),
        ],
      ),
    );
  }
}

/// Cross-fades between loading and loaded content with a gentle size
/// settle, so the page doesn't jump when data arrives. Children need
/// distinct keys per state.
class _SmoothSwitch extends StatelessWidget {
  const _SmoothSwitch({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    return AnimatedSize(
      duration: duration,
      curve: AppMotion.standard,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: AppMotion.standard,
        switchOutCurve: AppMotion.standard,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        child: child,
      ),
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
