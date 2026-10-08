import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/friends/entities/friend.dart';
import '../../types/async_value_loading.dart';
import '../../view_model/friends/friends_view_models.dart';
import '../../view_model/people/add_person_view_model.dart';
import '../../view_model/people/people_list_view_model.dart';
import '../../widget/molecules/common/md_confirmation_dialog.dart';
import '../../widget/molecules/common/md_screen_loading.dart';
import '../../widget/organisms/friends/md_add_friend_sheet.dart';
import '../../widget/organisms/people/md_add_person_sheet.dart';
import '../../widget/organisms/common/md_app_scaffold.dart';
import '../../widget/templates/people/people_template.dart';

/// People. Wires [PeopleList] and the add-someone sheet into
/// [PeopleTemplate]. See CLAUDE.md §40.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  /// Resolves to `(name, type)`, or null if the sheet was dismissed.
  Future<(String, String)?> _askForPerson(BuildContext context) {
    return showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final form = ref.watch(addPersonViewModelProvider);
          final viewModel = ref.read(addPersonViewModelProvider.notifier);
          return MdAddPersonSheet(
            name: form.name,
            type: form.type,
            onNameChanged: viewModel.setName,
            onTypeChanged: viewModel.setType,
            onSubmit: () {
              if (!form.canSubmit) return;
              Navigator.of(context).pop((form.trimmedName, form.type));
            },
          );
        },
      ),
    );
  }

  Future<void> _addPerson(BuildContext context, WidgetRef ref) async {
    final added = await _askForPerson(context);
    if (added == null) return;

    try {
      await ref
          .read(peopleListProvider.notifier)
          .addPerson(name: added.$1, type: added.$2);
    } catch (_) {
      if (!context.mounted) return;
      showAppMessage(
        context,
        "We couldn't add them just now. Please try again.",
      );
    }
  }

  /// Opens the "Add a friend" sheet: my own friend code, and a box for theirs.
  Future<void> _addFriend(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final code = ref.watch(friendCodeViewModelProvider);
          final codeModel = ref.read(friendCodeViewModelProvider.notifier);
          final form = ref.watch(addFriendViewModelProvider);
          final formModel = ref.read(addFriendViewModelProvider.notifier);

          return MdAddFriendSheet(
            code: code,
            form: form,
            onCopy: () async {
              await Clipboard.setData(ClipboardData(text: code.code ?? ''));
              if (context.mounted) showAppMessage(context, 'Code copied.');
            },
            onSend: () async {
              final message = await codeModel.send();
              if (message != null && context.mounted) {
                showAppMessage(context, message);
              }
            },
            onReset: () async {
              final confirmed = await showConfirmationDialog(
                context,
                title: 'Get a new code?',
                message:
                    'Your old code stops working straight away. Friends you '
                    'already added stay your friends.',
                confirmLabel: 'Get a new code',
                cancelLabel: 'Keep my code',
              );
              if (confirmed) await codeModel.reset();
            },
            onRetryCode: codeModel.retry,
            onCodeChanged: formModel.setCode,
            onSubmit: formModel.submit,
          );
        },
      ),
    );
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    Friend friend, {
    required bool accept,
  }) async {
    final message = await ref
        .read(friendActionsViewModelProvider.notifier)
        .respond(friend, accept: accept);
    if (message != null && context.mounted) showAppMessage(context, message);
  }

  Future<void> _removeFriend(
    BuildContext context,
    WidgetRef ref,
    Friend friend,
  ) async {
    final isFriend = friend.isFriend;
    final confirmed = await showConfirmationDialog(
      context,
      title: isFriend ? 'Remove ${friend.name}?' : 'Cancel the request?',
      message: isFriend
          ? 'You will stop being friends. Anything you already shared with '
                'them stays shared until you remove it.'
          : 'The request to ${friend.name} is withdrawn.',
      confirmLabel: isFriend ? 'Remove them' : 'Cancel the request',
      cancelLabel: isFriend ? 'Keep them' : 'Keep it',
    );
    if (!confirmed || !context.mounted) return;

    final message = await ref
        .read(friendActionsViewModelProvider.notifier)
        .remove(friend);
    if (message != null && context.mounted) showAppMessage(context, message);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the actions notifier alive while People is open.
    ref.watch(friendActionsViewModelProvider);

    final people = ref.watch(peopleListProvider);
    final friends = ref.watch(friendsProvider);
    // The page is both lists: the people on this phone and the friends
    // fetched online. Until each has answered, show just the loader.
    if (people.isFirstFetch || friends.isFirstFetch) {
      return const MdAppScaffold(
        body: MdScreenLoading(message: 'Gathering your people…'),
      );
    }

    return PeopleTemplate(
      people: people,
      onRetry: () => ref.invalidate(peopleListProvider),
      onRefresh: () async {
        ref
          ..invalidate(peopleListProvider)
          ..invalidate(friendsProvider);
        // A failed fetch shows its own friendly message; the pull just ends.
        await Future.wait(
          [
            ref.read(peopleListProvider.future),
            ref.read(friendsProvider.future),
          ].map((fetch) => fetch.then<void>((_) {}, onError: (_) {})),
        );
      },
      onAddPerson: () => _addPerson(context, ref),
      friends: friends,
      onAddFriend: () => _addFriend(context),
      onRespondToFriend: (friend, {required accept}) =>
          _respond(context, ref, friend, accept: accept),
      onRemoveFriend: (friend) => _removeFriend(context, ref, friend),
      onRetryFriends: () => ref.invalidate(friendsProvider),
    );
  }
}
