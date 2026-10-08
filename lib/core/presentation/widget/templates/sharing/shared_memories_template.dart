import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/sharing/entities/shared_memory.dart';
import '../../../../domain/sharing/entities/shared_quest.dart';
import '../../../types/sharing/shared_hub.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_skeleton_box.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../molecules/common/md_section_header.dart';
import '../../molecules/sharing/md_shared_memory_tile.dart';
import '../../molecules/sharing/md_shared_quest_tile.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// Everything friends shared with you: invitations to answer, quests you are
/// taking part in, and memories they gave you a code for. Private to you and
/// the friends who invited you: not a feed. See CLAUDE.md §22, §38, §54C.
class SharedMemoriesTemplate extends StatelessWidget {
  const SharedMemoriesTemplate({
    super.key,
    required this.hub,
    required this.onOpenMemory,
    required this.onOpenQuest,
    required this.onEnterCode,
    required this.onRetry,
  });

  final AsyncValue<SharedHub> hub;
  final ValueChanged<SharedMemorySummary> onOpenMemory;
  final ValueChanged<SharedQuestSummary> onOpenQuest;
  final VoidCallback onEnterCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      showAppBar: true,
      bottomAction: MdPrimaryButton(
        label: 'Enter a code',
        icon: Icons.vpn_key_outlined,
        onPressed: onEnterCode,
      ),
      body: hub.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: const [
            MdSkeletonBox(height: 96, radius: AppRadius.lg),
            SizedBox(height: AppSpacing.md),
            MdSkeletonBox(height: 96, radius: AppRadius.lg),
          ],
        ),
        error: (error, stack) => MdEmptyState.error(
          title: "We couldn't open what's shared with you",
          message: 'Check your connection and try again.',
          onRetry: onRetry,
        ),
        data: (data) => data.isEmpty
            ? const MdEmptyState(
                icon: Icons.group_outlined,
                title: 'Nothing shared with you yet',
                message:
                    'When a friend sends you an invite code, their memory or '
                    'quest shows up here.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0,
                  AppSpacing.gutter,
                  AppSpacing.xxl,
                ),
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Shared with you',
                      style: AppTypography.heading1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (data.invitations.isNotEmpty) ...[
                    const MdSectionHeader(title: 'Invitations'),
                    const SizedBox(height: AppSpacing.sm),
                    for (final quest in data.invitations) ...[
                      MdSharedQuestTile(
                        quest: quest,
                        onTap: () => onOpenQuest(quest),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (data.quests.isNotEmpty) ...[
                    const MdSectionHeader(title: 'Quests you are in'),
                    const SizedBox(height: AppSpacing.sm),
                    for (final quest in data.quests) ...[
                      MdSharedQuestTile(
                        quest: quest,
                        onTap: () => onOpenQuest(quest),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (data.memories.isNotEmpty) ...[
                    const MdSectionHeader(title: 'Memories'),
                    const SizedBox(height: AppSpacing.sm),
                    for (final memory in data.memories) ...[
                      MdSharedMemoryTile(
                        memory: memory,
                        onTap: () => onOpenMemory(memory),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ],
              ),
      ),
    );
  }
}
