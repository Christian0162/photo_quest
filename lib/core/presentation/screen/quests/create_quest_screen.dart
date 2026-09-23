import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/people/people_list_view_model.dart';
import '../../view_model/quests/create_quest_view_model.dart';
import '../../widget/molecules/confirmation_dialog.dart';
import '../../widget/organisms/app_scaffold.dart';
import '../../widget/template/create_quest_template.dart';

/// Create Quest. Wires [CreateQuestViewModel], the discard dialog and
/// navigation into [CreateQuestTemplate]. See CLAUDE.md §33.
class CreateQuestScreen extends ConsumerWidget {
  const CreateQuestScreen({super.key});

  Future<void> _close(BuildContext context, WidgetRef ref) async {
    if (ref.read(createQuestViewModelProvider).hasWork) {
      final discard = await showConfirmationDialog(
        context,
        title: 'Discard this quest?',
        message: "What you've written so far won't be saved.",
        confirmLabel: 'Discard',
        cancelLabel: 'Keep editing',
      );
      if (!discard) return;
    }
    if (context.mounted) context.pop();
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    try {
      final questId = await ref
          .read(createQuestViewModelProvider.notifier)
          .submit();
      if (questId != null && context.mounted) {
        context.pushReplacement(AppRoutes.questDetailPath(questId));
      }
    } catch (_) {
      if (!context.mounted) return;
      showAppMessage(context, "We couldn't save your quest. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(createQuestViewModelProvider.notifier);

    return CreateQuestTemplate(
      draft: ref.watch(createQuestViewModelProvider),
      people: ref.watch(invitablePeopleProvider),
      onClose: () => _close(context, ref),
      onBack: () {
        if (!notifier.previousStep()) _close(context, ref);
      },
      onContinue: notifier.nextStep,
      onCreate: () => _create(context, ref),
      onTitleChanged: notifier.setTitle,
      onDescriptionChanged: notifier.setDescription,
      onCategoryChanged: notifier.setCategory,
      onTypeChanged: notifier.setType,
      onToggleParticipant: notifier.toggleParticipant,
      onAddShot: notifier.addShot,
      onRemoveShot: notifier.removeShotAt,
    );
  }
}
