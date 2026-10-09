import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../types/async_value_loading.dart';
import '../../view_model/auth/account_view_model.dart';
import '../../view_model/auth/auth_session_view_model.dart';
import '../../widget/molecules/common/md_confirmation_dialog.dart';
import '../../widget/molecules/common/md_empty_state.dart';
import '../../widget/molecules/common/md_screen_loading.dart';
import '../../widget/organisms/common/md_app_scaffold.dart';
import '../../widget/templates/auth/account_template.dart';

/// The signed-in person's account. Design lives in [AccountTemplate].
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _loggingOut = false;
  bool _deleting = false;

  Future<void> _logOut() async {
    setState(() => _loggingOut = true);
    try {
      await ref.read(authSessionViewModelProvider.notifier).signOut();
    } on Object {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      showAppMessage(context, "We couldn't log you out. Please try again.");
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete your account?',
      message:
          'This permanently deletes your account and everything you backed '
          'up or shared online. Friends you shared memories with will lose '
          'access. Photos saved on this phone stay.',
      confirmLabel: 'Delete my account',
      cancelLabel: 'Keep my account',
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    final message = await ref
        .read(accountViewModelProvider.notifier)
        .deleteAccount();
    if (message != null && mounted) {
      setState(() => _deleting = false);
      showAppMessage(context, message);
    }
    // On success the router takes the person to the welcome screen.
  }

  Future<void> _report(Future<String?> action) async {
    final message = await action;
    if (message != null && mounted) showAppMessage(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountViewModelProvider);
    final draft = ref.watch(accountNameDraftViewModelProvider);

    if (account.isFirstFetch) {
      return const MdAppScaffold(
        showAppBar: true,
        body: MdScreenLoading(message: 'Loading your account…'),
      );
    }

    return account.when(
      data: (data) => AccountTemplate(
        account: data,
        draft: draft,
        loggingOut: _loggingOut,
        deleting: _deleting,
        onNameChanged: ref
            .read(accountNameDraftViewModelProvider.notifier)
            .setText,
        onSaveName: () => _report(
          ref.read(accountNameDraftViewModelProvider.notifier).save(),
        ),
        onChangeAvatar: () =>
            _report(ref.read(accountViewModelProvider.notifier).changeAvatar()),
        onLogOut: _logOut,
        onDeleteAccount: _deleteAccount,
      ),
      loading: () => const MdAppScaffold(
        showAppBar: true,
        body: MdScreenLoading(message: 'Loading your account…'),
      ),
      error: (_, _) => MdAppScaffold(
        showAppBar: true,
        body: MdEmptyState.error(
          title: "We couldn't load your account",
          message: 'Check your connection and try again.',
          onRetry: () => ref.invalidate(accountViewModelProvider),
        ),
      ),
    );
  }
}
