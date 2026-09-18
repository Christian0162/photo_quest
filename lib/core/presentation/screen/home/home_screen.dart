import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../widget/atoms/primary_button.dart';
import '../../widget/atoms/loading_indicator.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../view_model/quests/quests_needing_confirmation_view_model.dart';
import '../../widget/molecules/section_header.dart';
import '../../widget/organisms/memory_card.dart';
import '../../widget/organisms/pending_quest_card.dart';
import '../../widget/organisms/recent_memories_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoryListProvider);
    final pendingQuests = ref.watch(questsNeedingConfirmationProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting, style: AppTypography.bodyMuted),
              const SizedBox(height: AppSpacing.xs),
              Text("Let's make a memory.", style: AppTypography.heading1),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Start a Quest',
                icon: Icons.auto_awesome_rounded,
                onPressed: () => context.push('/quests'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => context.push('/quests/create'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create your own Quest'),
              ),
              pendingQuests.maybeWhen(
                data: (list) => list.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: "Needs everyone's OK"),
                            const SizedBox(height: AppSpacing.sm),
                            for (final entry in list)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: PendingQuestCard(
                                  entry: entry,
                                  onTap: () =>
                                      context.push('/quests/${entry.quest.id}'),
                                ),
                              ),
                          ],
                        ),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Recent Memories'),
              const SizedBox(height: AppSpacing.sm),
              memories.when(
                data: (list) => RecentMemoriesSection(
                  memories: list.take(6).toList(),
                  builder: (memory) => SizedBox(
                    width: 160,
                    child: MemoryCard(
                      memory: memory,
                      coverPhoto: null,
                      onTap: () => context.push('/memory/${memory.id}'),
                    ),
                  ),
                ),
                loading: () =>
                    const SizedBox(height: 160, child: LoadingIndicator()),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
