import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../utils/app_haptics.dart';
import '../../types/quests/quest_participant_with_person.dart';
import '../../view_model/quests/quest_detail_view_model.dart';
import '../../view_model/quests/quest_intro_view_model.dart';
import '../../view_model/quests/quest_participants_view_model.dart';
import '../../widget/organisms/md_app_scaffold.dart';
import '../../widget/organisms/md_people_picker_sheet.dart';
import '../../widget/templates/quest_intro_template.dart';

/// Quest Introduction. Wires view models, the invite sheet and navigation
/// into [QuestIntroTemplate]. See CLAUDE.md §59.
class QuestIntroScreen extends ConsumerWidget {
  const QuestIntroScreen({super.key, required this.questId});

  final String questId;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    try {
      final sessionId = await ref
          .read(questIntroViewModelProvider(questId).notifier)
          .startQuest();
      if (sessionId != null && context.mounted) {
        context.push(AppRoutes.capturePath(sessionId));
      }
    } catch (_) {
      if (!context.mounted) return;
      showAppMessage(
        context,
        "We couldn't start this quest. Please try again.",
      );
    }
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final participants = ref.read(
      questParticipantsViewModelProvider(questId).notifier,
    );
    final available = await participants.invitablePeople();
    if (!context.mounted) return;

    if (available.isEmpty) {
      showAppMessage(
        context,
        'Everyone you know is already in. Add more people from the People '
        'tab.',
      );
      return;
    }

    final chosen = await showPeoplePickerSheet(context, people: available);
    if (chosen == null) return;
    await participants.addParticipant(chosen.id);
  }

  /// Removes someone, with a quick way back if it was a slip. Undo invites
  /// them again and restores their "I'm in". See CLAUDE.md §42.
  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    QuestParticipantWithPerson entry,
  ) async {
    final notifier = ref.read(
      questParticipantsViewModelProvider(questId).notifier,
    );
    AppHaptics.remove();
    await notifier.removeParticipant(entry.participant.id);
    if (!context.mounted) return;
    showAppMessage(
      context,
      '${entry.person.name} was removed.',
      actionLabel: 'Undo',
      onAction: () => notifier.restoreParticipant(entry),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = questParticipantsViewModelProvider(questId);

    // The last person says they're in: celebrate, and point at "Let's start".
    ref.listen(questStartReadinessProvider(questId), (previous, next) {
      if (previous != null &&
          previous.canStart == false &&
          previous.hint != null &&
          next.everyoneIn) {
        AppHaptics.success();
      }
    });

    return QuestIntroTemplate(
      detail: ref.watch(questDetailProvider(questId)),
      participants: ref.watch(participants),
      readiness: ref.watch(questStartReadinessProvider(questId)),
      isStarting: ref.watch(questIntroViewModelProvider(questId)),
      onRetry: () => ref.invalidate(questDetailProvider(questId)),
      onStart: () => _start(context, ref),
      onInvite: () => _invite(context, ref),
      onConfirmParticipant: (entry) {
        AppHaptics.selection();
        ref
            .read(participants.notifier)
            .respond(participantId: entry.participant.id, accepted: true);
      },
      onRemoveParticipant: (entry) => _remove(context, ref, entry),
    );
  }
}
