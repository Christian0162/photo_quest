import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/sharing/sharing_view_models.dart';
import '../../widget/molecules/common/md_confirmation_dialog.dart';
import '../../widget/organisms/common/md_app_scaffold.dart';
import '../../widget/organisms/sharing/md_invite_friend_sheet.dart';

/// Opens the "Invite a friend" sheet for one of my memories.
Future<void> showInviteFriendSheet(BuildContext context, String memoryId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => InviteFriendSheet(memoryId: memoryId),
  );
}

/// Opens the "Do this quest together" sheet for one of my quests.
Future<void> showInviteToQuestSheet(BuildContext context, String questId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => InviteToQuestSheet(questId: questId),
  );
}

Future<void> _copyCode(BuildContext context, String? code) async {
  await Clipboard.setData(ClipboardData(text: code ?? ''));
  if (context.mounted) showAppMessage(context, 'Code copied.');
}

Future<void> _report(BuildContext context, Future<String?> action) async {
  final message = await action;
  if (message != null && context.mounted) showAppMessage(context, message);
}

/// Wires [ShareMemoryViewModel] into [MdInviteFriendSheet].
class InviteFriendSheet extends ConsumerWidget {
  const InviteFriendSheet({super.key, required this.memoryId});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shareMemoryViewModelProvider(memoryId));
    final viewModel = ref.read(shareMemoryViewModelProvider(memoryId).notifier);

    return MdInviteFriendSheet(
      copy: InviteSheetCopy.memory,
      state: state,
      onCreate: viewModel.createInvite,
      onCopy: () => _copyCode(context, state.code),
      onSend: () => _report(context, viewModel.sendCode()),
      onRemoveViewer: (viewer) => viewModel.removeViewer(viewer.id),
      onInviteFriend: viewModel.inviteFriend,
      onRemoveOnlineCopy: () async {
        final confirmed = await showConfirmationDialog(
          context,
          title: 'Remove the online copy?',
          message:
              'Friends will no longer see this memory, and their codes stop '
              'working. Photos friends added to it online go too. The memory '
              'on this phone stays, and you can share it again later.',
          confirmLabel: 'Remove it',
          cancelLabel: 'Keep it',
        );
        if (confirmed) await viewModel.removeOnlineCopy();
      },
    );
  }
}

/// Wires [ShareQuestViewModel] into [MdInviteFriendSheet].
class InviteToQuestSheet extends ConsumerWidget {
  const InviteToQuestSheet({super.key, required this.questId});

  final String questId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shareQuestViewModelProvider(questId));
    final viewModel = ref.read(shareQuestViewModelProvider(questId).notifier);

    return MdInviteFriendSheet(
      copy: InviteSheetCopy.quest,
      state: state,
      onCreate: viewModel.createInvite,
      onCopy: () => _copyCode(context, state.code),
      onSend: () => _report(context, viewModel.sendCode()),
      onRemoveViewer: (person) => viewModel.removeParticipant(person.id),
      onInviteFriend: viewModel.inviteFriend,
    );
  }
}
