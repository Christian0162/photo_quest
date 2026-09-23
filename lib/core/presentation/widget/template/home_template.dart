import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../view_model/quests/quests_needing_confirmation_view_model.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/section_header.dart';
import '../organisms/app_scaffold.dart';
import '../organisms/pending_quest_card.dart';
import '../organisms/recent_memories_section.dart';
import '../organisms/today_quest_card.dart';

/// Answers "What can we do today?" — a greeting, one hero Quest, anything
/// waiting on people, and a shelf of recent memories. Never a dashboard.
/// See CLAUDE.md §31, design system §13-14.
class HomeTemplate extends StatelessWidget {
  const HomeTemplate({
    super.key,
    required this.greeting,
    required this.todayQuest,
    required this.pendingQuests,
    required this.memories,
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
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSettings;
  final ValueChanged<Quest> onOpenQuest;
  final ValueChanged<MemorySummary> onOpenMemory;
  final VoidCallback onSeeAllMemories;
  final VoidCallback onBrowseQuests;
  final VoidCallback onCreateQuest;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xxl,
          ),
          children: [
            _Padded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting, style: AppTypography.bodyMuted),
                        const SizedBox(height: AppSpacing.xs),
                        Semantics(
                          header: true,
                          child: Text(
                            "Let's make a memory.",
                            style: AppTypography.display,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: onOpenSettings,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Padded(
              child: todayQuest.when(
                loading: () => const SkeletonBox(height: 460),
                error: (error, stack) => const SizedBox.shrink(),
                data: (quest) => quest == null
                    ? const SizedBox.shrink()
                    : TodayQuestCard(
                        quest: quest,
                        onStart: () => onOpenQuest(quest),
                      ),
              ),
            ),
            ...pendingQuests.maybeWhen(
              data: (list) => [
                if (list.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const _Padded(
                    child: SectionHeader(
                      title: "Needs everyone's OK",
                      subtitle: 'Get your people to say they’re in.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.ms),
                  for (final entry in list)
                    _Padded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: PendingQuestCard(
                          entry: entry,
                          onTap: () => onOpenQuest(entry.quest),
                        ),
                      ),
                    ),
                ],
              ],
              orElse: () => const [],
            ),
            const SizedBox(height: AppSpacing.xl),
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
            memories.when(
              loading: () => RecentMemoriesSection.skeleton(context),
              error: (error, stack) => const _Padded(
                child: Text(
                  "We couldn't load your memories right now.",
                  style: AppTypography.bodyMuted,
                ),
              ),
              data: (list) => RecentMemoriesSection(
                memories: list.take(_recentMemoryCount).toList(),
                onOpen: onOpenMemory,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _Padded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Something else in mind?',
                    subtitle: 'Pick another quest, or make your own.',
                  ),
                  const SizedBox(height: AppSpacing.ms),
                  SecondaryButton(
                    label: 'Browse quests',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: onBrowseQuests,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(
                    label: 'Create your own quest',
                    icon: Icons.edit_rounded,
                    onPressed: onCreateQuest,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Padded extends StatelessWidget {
  const _Padded({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: child,
    );
  }
}
