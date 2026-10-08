import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/auth_repository_provider.dart';
import '../../../domain/auth/enum/auth_status.dart';
import '../../../errors/app_failure.dart';
import '../../../utils/provider_retry.dart';
import '../../types/auth/account_data.dart';
import 'auth_session_view_model.dart';

part 'account_view_model.g.dart';

/// The signed-in person's account: email, display name and avatar. It watches
/// the auth status, so it empties itself the moment they log out.
@Riverpod(retry: neverRetry)
class AccountViewModel extends _$AccountViewModel {
  @override
  Future<AccountData> build() async {
    final status = ref.watch(authSessionViewModelProvider);
    if (status is! AuthSignedIn) {
      return const AccountData(email: '');
    }
    final repository = ref.watch(profileRepositoryProvider);
    final profile = await repository.getMyProfile();
    return AccountData(
      email: status.user.email,
      displayName: profile.displayName,
      avatarPath: profile.avatarPath,
      avatarUrl: await repository.avatarUrl(profile.avatarPath),
    );
  }

  Future<String?> saveName(String name) async {
    final current = state.value;
    if (current == null) return null;
    try {
      await ref.read(profileRepositoryProvider).updateDisplayName(name);
      final trimmed = name.trim();
      state = AsyncData(
        current.copyWith(displayName: trimmed.isEmpty ? null : trimmed),
      );
      return null;
    } on AppFailure catch (failure) {
      return failure.message;
    }
  }

  /// Deletes the account and everything online (files first). Returns a
  /// friendly message when it fails, otherwise null. On success the auth
  /// status flips to signed out and the router leaves this screen.
  Future<String?> deleteAccount() async {
    try {
      await ref.read(profileRepositoryProvider).deleteMyAccount();
      return null;
    } on AppFailure catch (failure) {
      return failure.message;
    }
  }

  /// Lets the person pick a photo and uploads it. Returns a friendly message
  /// when it fails, otherwise null (also null when they back out).
  Future<String?> changeAvatar() async {
    final current = state.value;
    if (current == null) return null;
    try {
      final picked = await ref.read(avatarPickerServiceProvider).pickAvatar();
      if (picked == null) return null;
      final repository = ref.read(profileRepositoryProvider);
      final path = await repository.replaceAvatar(
        picked.bytes,
        extension: picked.extension,
        previousPath: current.avatarPath,
      );
      state = AsyncData(
        current.copyWith(
          avatarPath: path,
          avatarUrl: await repository.avatarUrl(path),
        ),
      );
      return null;
    } on AppFailure catch (failure) {
      return failure.message;
    } on Object {
      return "We couldn't open your photos. Please try again.";
    }
  }
}

/// The name field on the Account screen. Saving goes through
/// [AccountViewModel]; this only holds what is being typed.
@riverpod
class AccountNameDraftViewModel extends _$AccountNameDraftViewModel {
  @override
  AccountNameDraft build() => const AccountNameDraft();

  void setText(String value) => state = state.copyWith(text: value);

  Future<String?> save() async {
    final text = state.text;
    if (text == null || state.saving) return null;
    state = state.copyWith(saving: true);
    final error = await ref
        .read(accountViewModelProvider.notifier)
        .saveName(text);
    state = error == null
        ? const AccountNameDraft()
        : state.copyWith(saving: false);
    return error;
  }
}
