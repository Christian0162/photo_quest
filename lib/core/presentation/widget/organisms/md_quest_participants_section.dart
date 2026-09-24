import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../atoms/person_avatar.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../atoms/status_pill.dart';
import '../molecules/app_card.dart';
import '../molecules/section_header.dart';
import '../../../domain/quests/enum/status_tone.dart';
import '../../types/quests/quest_participant_with_person.dart';

/// Shows who's doing this Quest and lets the creator invite more People.
/// Since V1 is a single shared device (CLAUDE.md §54A), each participant
/// confirms in person with "I'm in" before the quest starts. Every status
/// is an icon + word, never color alone. See CLAUDE.md §40-41, §65,
/// design system §21, §60.
class QuestParticipantsSection extends StatelessWidget {
  const QuestParticipantsSection({
    super.key,
    required this.participants,
    required this.limit,
    required this.onInvite,
    required this.onConfirm,
    required this.onRemove,
  });

  final AsyncValue<List<QuestParticipantWithPerson>> participants;

  /// The most People this Quest can have (CLAUDE.md §15A).
  final int limit;
  final VoidCallback onInvite;
  final ValueChanged<QuestParticipantWithPerson> onConfirm;
  final ValueChanged<QuestParticipantWithPerson> onRemove;

  @override
  Widget build(BuildContext context) {
    return participants.when(
      loading: () => const SkeletonBox(height: 120),
      error: (error, stack) => Text(
        "We couldn't load who's joining. Please go back and try again.",
        style: AppTypography.bodyMuted,
      ),
      data: (people) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "Who's joining",
            subtitle: people.isEmpty
                ? 'Invite the people you want to do this with.'
                : 'Each person taps "I\'m in" to confirm.',
            trailing: Text(
              '${people.length} of $limit',
              style: AppTypography.label.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.ms),
          if (people.isNotEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  for (var i = 0; i < people.length; i++) ...[
                    if (i > 0) const Divider(indent: 72),
                    _ParticipantRow(
                      entry: people[i],
                      onConfirm: () => onConfirm(people[i]),
                      onRemove: () => onRemove(people[i]),
                    ),
                  ],
                ],
              ),
            ),
          if (people.length < limit) ...[
            const SizedBox(height: AppSpacing.ms),
            SecondaryButton(
              label: 'Invite someone to join',
              icon: Icons.person_add_alt_1_rounded,
              onPressed: onInvite,
            ),
          ],
        ],
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.entry,
    required this.onConfirm,
    required this.onRemove,
  });

  final QuestParticipantWithPerson entry;
  final VoidCallback onConfirm;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = entry.person.name;
    final status = entry.participant.status;
    final invited = status == 'invited';

    final pill = switch (status) {
      'accepted' || 'completed' => const StatusPill(
        label: "They're in",
        icon: Icons.check_circle_rounded,
        tone: StatusTone.positive,
      ),
      'declined' => const StatusPill(
        label: "Can't make it",
        icon: Icons.do_not_disturb_on_outlined,
      ),
      _ => const StatusPill(
        label: 'Waiting',
        icon: Icons.hourglass_top_rounded,
        tone: StatusTone.waiting,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.ms,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          PersonAvatar(person: entry.person, radius: 22),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.label,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.short),
                  child: KeyedSubtree(key: ValueKey(status), child: pill),
                ),
              ],
            ),
          ),
          if (invited)
            FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppTouch.minTarget),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              child: Text("I'm in", semanticsLabel: '$name is in'),
            ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Remove $name',
            icon: const Icon(Icons.close_rounded, size: AppIconSizes.md),
          ),
        ],
      ),
    );
  }
}
