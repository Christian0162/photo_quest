import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/sharing/entities/shared_memory.dart';
import '../../../../domain/sharing/entities/shared_quest.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_skeleton_box.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../molecules/common/md_section_header.dart';
import '../../molecules/sharing/md_shared_memory_tile.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// A quest a friend invited you to, or one you have joined.
///
/// An invitation reads like a note from a friend, with one dominant action:
/// accept. Once you're in, it shows who is taking part, the memories made so
/// far (add your own photos from there), and a quiet way out. See CLAUDE.md
/// §22, §41, design system §22.
class SharedQuestTemplate extends StatelessWidget {
  const SharedQuestTemplate({
    super.key,
    required this.quest,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
    required this.onLeave,
    required this.onOpenMemory,
    required this.onRetry,
  });

  final AsyncValue<SharedQuestDetail> quest;

  /// True while an answer or a leave is being sent.
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onLeave;
  final ValueChanged<SharedMemorySummary> onOpenMemory;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final data = quest.value;
    final invited = data?.status == ParticipationStatus.invited;

    return MdAppScaffold(
      showAppBar: true,
      bottomAction: invited
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MdPrimaryButton(
                  label: 'Accept the quest',
                  icon: Icons.check_rounded,
                  loading: busy,
                  onPressed: busy ? null : onAccept,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: busy ? null : onDecline,
                  child: const Text('Not now'),
                ),
              ],
            )
          : null,
      body: quest.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: const [
            MdSkeletonBox(height: 32),
            SizedBox(height: AppSpacing.md),
            MdSkeletonBox(height: 160, radius: AppRadius.lg),
          ],
        ),
        error: (error, stack) => MdEmptyState.error(
          title: "We couldn't open this quest",
          message:
              'It may no longer be shared with you, or you may be offline.',
          onRetry: onRetry,
        ),
        data: (detail) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.xxl,
          ),
          children: [
            Semantics(
              header: true,
              child: Text(detail.title, style: AppTypography.display),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              invited
                  ? '${detail.ownerName} invited you to do this together.'
                  : 'With ${detail.ownerName}',
              style: AppTypography.bodyLarge,
            ),
            if (detail.description != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(detail.description!, style: AppTypography.body),
            ],
            if (detail.shots.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const MdSectionHeader(title: 'The photos you will take'),
              const SizedBox(height: AppSpacing.sm),
              for (final (index, shot) in detail.shots.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: AppSpacing.xl,
                        child: Text(
                          '${index + 1}.',
                          style: AppTypography.label,
                        ),
                      ),
                      Expanded(child: Text(shot, style: AppTypography.body)),
                    ],
                  ),
                ),
            ],
            if (detail.participants.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const MdSectionHeader(title: "Who's taking part"),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final person in detail.participants)
                    Chip(
                      avatar: CircleAvatar(
                        backgroundColor: AppColors.softPeach,
                        child: Text(
                          person.name.characters.first.toUpperCase(),
                          style: AppTypography.caption,
                        ),
                      ),
                      label: Text(
                        person.status == null
                            ? person.name
                            : '${person.name} · ${person.status}',
                      ),
                    ),
                ],
              ),
            ],
            if (!invited) ...[
              const SizedBox(height: AppSpacing.xl),
              const MdSectionHeader(title: 'Memories from this quest'),
              const SizedBox(height: AppSpacing.sm),
              if (detail.memories.isEmpty)
                Text(
                  'None yet. When ${detail.ownerName} finishes the quest, the '
                  'memory shows up here and you can add your own photos.',
                  style: AppTypography.bodyMuted,
                )
              else
                for (final memory in detail.memories) ...[
                  MdSharedMemoryTile(
                    memory: memory,
                    onTap: () => onOpenMemory(memory),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              const SizedBox(height: AppSpacing.lg),
              MdSecondaryButton(
                label: 'Leave this quest',
                icon: Icons.logout_rounded,
                onPressed: busy ? null : onLeave,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
