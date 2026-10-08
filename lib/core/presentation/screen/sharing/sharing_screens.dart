import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../domain/sharing/entities/shared_quest.dart';
import '../../view_model/sharing/sharing_view_models.dart';
import '../../widget/molecules/common/md_confirmation_dialog.dart';
import '../../widget/organisms/common/md_app_scaffold.dart';
import '../../widget/organisms/sharing/md_shared_photo_viewer.dart';
import '../../widget/templates/sharing/join_memory_template.dart';
import '../../widget/templates/sharing/shared_memories_template.dart';
import '../../widget/templates/sharing/shared_memory_template.dart';
import '../../widget/templates/sharing/shared_quest_template.dart';

/// "Got a code?" Design lives in [JoinMemoryTemplate].
class JoinMemoryScreen extends ConsumerWidget {
  const JoinMemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(joinMemoryViewModelProvider.notifier);

    return JoinMemoryTemplate(
      form: ref.watch(joinMemoryViewModelProvider),
      onCodeChanged: viewModel.setCode,
      onSubmit: () async {
        final target = await viewModel.submit();
        if (target == null || !context.mounted) return;
        context.pushReplacement(switch (target.kind) {
          InviteKind.memory => AppRoutes.sharedMemoryPath(target.id),
          InviteKind.quest => AppRoutes.sharedQuestPath(target.id),
        });
      },
    );
  }
}

/// Memories friends shared with me. Design lives in
/// [SharedMemoriesTemplate].
class SharedMemoriesScreen extends ConsumerWidget {
  const SharedMemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SharedMemoriesTemplate(
      hub: ref.watch(sharedHubProvider),
      onOpenMemory: (memory) =>
          context.push(AppRoutes.sharedMemoryPath(memory.id)),
      onOpenQuest: (quest) => context.push(AppRoutes.sharedQuestPath(quest.id)),
      onEnterCode: () => context.push(AppRoutes.join),
      onRetry: () {
        ref.invalidate(sharedMemoriesProvider);
        ref.invalidate(sharedQuestsProvider);
      },
    );
  }
}

/// One shared memory. Design lives in [SharedMemoryTemplate].
class SharedMemoryScreen extends ConsumerWidget {
  const SharedMemoryScreen({super.key, required this.memoryId});

  final String memoryId;

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Remove this memory?',
      message:
          'It will disappear from your list. You will need a new code to see '
          'it again.',
      confirmLabel: 'Remove it',
      cancelLabel: 'Keep it',
    );
    if (!confirmed || !context.mounted) return;

    final message = await ref
        .read(sharedMemoryViewModelProvider(memoryId).notifier)
        .leave();
    if (!context.mounted) return;
    if (message != null) {
      showAppMessage(context, message);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the actions notifier alive while the memory is open, so leaving
    // isn't cut short by it being disposed mid-call. Its state is true while
    // the person's photos are being added.
    final addingPhotos = ref.watch(sharedMemoryViewModelProvider(memoryId));

    return SharedMemoryTemplate(
      detail: ref.watch(sharedMemoryProvider(memoryId)),
      onOpenPhoto: (detail, index) => showSharedPhotoViewer(
        context,
        photos: detail.photos,
        initialIndex: index,
        title: detail.title,
      ),
      onLeave: () => _leave(context, ref),
      onRetry: () => ref.invalidate(sharedMemoryProvider(memoryId)),
      addingPhotos: addingPhotos,
      onAddPhotos: () async {
        final message = await ref
            .read(sharedMemoryViewModelProvider(memoryId).notifier)
            .addPhotos();
        if (message != null && context.mounted) {
          showAppMessage(context, message);
        }
      },
    );
  }
}

/// A quest a friend invited me to, or one I have joined. Design lives in
/// [SharedQuestTemplate].
class SharedQuestScreen extends ConsumerWidget {
  const SharedQuestScreen({super.key, required this.questId});

  final String questId;

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref, {
    required bool accept,
  }) async {
    final message = await ref
        .read(sharedQuestViewModelProvider(questId).notifier)
        .respond(accept: accept);
    if (!context.mounted) return;
    if (message != null) {
      showAppMessage(context, message);
    } else if (!accept) {
      context.pop();
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Leave this quest?',
      message:
          'You will stop seeing its memories. You will need a new code to '
          'join again.',
      confirmLabel: 'Leave it',
      cancelLabel: 'Stay',
    );
    if (!confirmed || !context.mounted) return;

    final message = await ref
        .read(sharedQuestViewModelProvider(questId).notifier)
        .leave();
    if (!context.mounted) return;
    if (message != null) {
      showAppMessage(context, message);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the actions notifier alive while the quest is open. Its state is
    // true while an answer or a leave is being sent.
    final busy = ref.watch(sharedQuestViewModelProvider(questId));

    return SharedQuestTemplate(
      quest: ref.watch(sharedQuestProvider(questId)),
      busy: busy,
      onAccept: () => _answer(context, ref, accept: true),
      onDecline: () => _answer(context, ref, accept: false),
      onLeave: () => _leave(context, ref),
      onOpenMemory: (memory) =>
          context.push(AppRoutes.sharedMemoryPath(memory.id)),
      onRetry: () => ref.invalidate(sharedQuestProvider(questId)),
    );
  }
}
