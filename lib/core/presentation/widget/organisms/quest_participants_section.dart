import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../view_model/people/people_list_view_model.dart';
import '../../view_model/quests/quest_participants_view_model.dart';
import '../atoms/person_avatar.dart';

/// Shows who is doing this Quest and lets the creator invite more People.
/// See CLAUDE.md §33, §40-41, §59.
class QuestParticipantsSection extends ConsumerWidget {
  const QuestParticipantsSection({super.key, required this.questId});

  final String questId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(questParticipantsViewModelProvider(questId));

    return participants.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (people) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who\'s joining', style: AppTypography.heading3),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final entry in people)
                  _ParticipantChip(
                    name: entry.person.name,
                    avatarBuilder: () =>
                        PersonAvatar(person: entry.person, radius: 18),
                    onRemove: () => ref
                        .read(
                          questParticipantsViewModelProvider(questId).notifier,
                        )
                        .removeParticipant(entry.participant.id),
                  ),
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
                          questParticipantsViewModelProvider(questId).notifier,
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

class _ParticipantChip extends StatelessWidget {
  const _ParticipantChip({
    required this.name,
    required this.avatarBuilder,
    required this.onRemove,
  });

  final String name;
  final Widget Function() avatarBuilder;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: avatarBuilder(),
      label: Text(name),
      backgroundColor: AppColors.warmCream,
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
    );
  }
}
