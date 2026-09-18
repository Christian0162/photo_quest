import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_constants.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../view_model/people/people_list_view_model.dart';
import '../../view_model/quests/quest_participants_view_model.dart';
import '../atoms/person_avatar.dart';
import '../molecules/section_header.dart';

/// Shows who's doing this Quest and lets the creator invite more People.
/// Since V1 is a single shared device (CLAUDE.md §54A), each participant
/// confirms in person by tapping their own chip before the quest starts.
/// See CLAUDE.md §33, §40-41, §60.
class QuestParticipantsSection extends ConsumerWidget {
  const QuestParticipantsSection({super.key, required this.quest});

  final Quest quest;

  bool get _showsParticipants => quest.type != 'solo';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_showsParticipants) return const SizedBox.shrink();

    final participants = ref.watch(
      questParticipantsViewModelProvider(quest.id),
    );

    return participants.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (people) {
        final limit =
            quest.maxParticipants ??
            AppConstants.defaultGroupQuestParticipantLimit;
        final pendingCount = people
            .where((p) => p.participant.status == 'invited')
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Who\'s joining',
              trailing: Text(
                '${people.length} / $limit',
                style: AppTypography.bodyMuted,
              ),
            ),
            if (pendingCount > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                pendingCount == 1
                    ? 'Waiting on 1 person to confirm'
                    : 'Waiting on $pendingCount people to confirm',
                style: AppTypography.bodyMuted,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final entry in people)
                  _ParticipantChip(
                    entry: entry,
                    onTap: entry.participant.status == 'invited'
                        ? () => ref
                              .read(
                                questParticipantsViewModelProvider(quest.id)
                                    .notifier,
                              )
                              .respond(
                                participantId: entry.participant.id,
                                accepted: true,
                              )
                        : null,
                    onRemove: () => ref
                        .read(
                          questParticipantsViewModelProvider(quest.id).notifier,
                        )
                        .removeParticipant(entry.participant.id),
                  ),
                if (people.length < limit)
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Invite someone'),
                    backgroundColor: AppColors.softPeach,
                    onPressed: () => _openPeoplePicker(context, ref, people),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _openPeoplePicker(
    BuildContext context,
    WidgetRef ref,
    List<QuestParticipantWithPerson> current,
  ) async {
    final currentIds = current.map((p) => p.person.id).toSet();
    final people = await ref.read(peopleListProvider.future);
    final available = people.where((p) => !currentIds.contains(p.id)).toList();

    if (!context.mounted) return;

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Everyone you know is already in.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Invite someone to join',
                  style: AppTypography.heading3,
                ),
              ),
              for (final person in available)
                ListTile(
                  leading: PersonAvatar(person: person, radius: 20),
                  title: Text(person.name, style: AppTypography.body),
                  onTap: () {
                    ref
                        .read(
                          questParticipantsViewModelProvider(quest.id).notifier,
                        )
                        .addParticipant(person.id);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A tappable participant pill that eases between "waiting" and "confirmed"
/// styling instead of snapping, per design system §48-49 (short, purposeful
/// micro-interactions).
class _ParticipantChip extends StatelessWidget {
  const _ParticipantChip({
    required this.entry,
    required this.onTap,
    required this.onRemove,
  });

  final QuestParticipantWithPerson entry;
  final VoidCallback? onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final accepted = entry.participant.status == 'accepted';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            right: AppSpacing.sm,
            top: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: accepted
                ? AppColors.softGreen.withValues(alpha: 0.25)
                : AppColors.warmCream,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PersonAvatar(person: entry.person, radius: 14),
              const SizedBox(width: AppSpacing.xs),
              Text(entry.person.name, style: AppTypography.body),
              const SizedBox(width: AppSpacing.xs),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  accepted
                      ? Icons.check_circle_rounded
                      : Icons.schedule_rounded,
                  key: ValueKey(accepted),
                  size: 16,
                  color: accepted
                      ? AppColors.softGreen
                      : AppColors.warmCharcoal,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: const Icon(Icons.close_rounded, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
