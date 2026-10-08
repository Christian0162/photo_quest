import 'dart:ui' show Rect;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/cloud_memory_repository_provider.dart';
import '../../../data/repositories/service_providers.dart';
import '../../../domain/friends/entities/friend.dart';
import '../../../domain/sharing/invite_code.dart';
import '../../../errors/app_failure.dart';
import '../../../utils/provider_retry.dart';
import '../../types/friends/friends_states.dart';

part 'friends_view_models.g.dart';

const _genericError = "We couldn't do that just now. Please try again.";

String _messageFor(Object error) =>
    error is AppFailure ? error.message : _genericError;

/// Real friends: people I've added, requests waiting for my answer, and
/// requests I'm waiting on.
@Riverpod(retry: neverRetry)
Future<List<Friend>> friends(Ref ref) =>
    ref.watch(cloudFriendsRepositoryProvider).getFriends();

/// My friend code: shown to copy or send, and reset when I want a new one.
@riverpod
class FriendCodeViewModel extends _$FriendCodeViewModel {
  @override
  FriendCodeState build() {
    Future.microtask(_load);
    return const FriendCodeState();
  }

  Future<void> _load() async {
    try {
      final code = await ref
          .read(cloudFriendsRepositoryProvider)
          .getMyFriendCode();
      if (ref.mounted) {
        state = state.copyWith(code: InviteCode.format(code), loading: false);
      }
    } on Object catch (error) {
      if (ref.mounted) {
        state = state.copyWith(loading: false, error: _messageFor(error));
      }
    }
  }

  Future<void> retry() {
    state = const FriendCodeState();
    return _load();
  }

  /// A new code; the old one stops working at once.
  Future<void> reset() async {
    if (state.resetting) return;
    state = state.copyWith(resetting: true, error: null);
    try {
      final code = await ref
          .read(cloudFriendsRepositoryProvider)
          .resetFriendCode();
      if (ref.mounted) {
        state = state.copyWith(code: InviteCode.format(code), resetting: false);
      }
    } on Object catch (error) {
      if (ref.mounted) {
        state = state.copyWith(resetting: false, error: _messageFor(error));
      }
    }
  }

  /// Opens the share sheet with the code. Returns a message on failure.
  Future<String?> send({Rect? origin}) async {
    final code = state.code;
    if (code == null) return null;
    try {
      await ref
          .read(sharingServiceProvider)
          .shareText(
            "Add me on Photo Quest! Here's my friend code: $code\n\n"
            'Open Photo Quest, go to People, tap Add a friend and enter it.',
            origin: origin,
          );
      return null;
    } on Object {
      return "We couldn't open sharing just now.";
    }
  }
}

/// The "enter a friend's code" form.
@riverpod
class AddFriendViewModel extends _$AddFriendViewModel {
  @override
  AddFriendState build() => const AddFriendState();

  void setCode(String value) =>
      state = state.copyWith(code: value, error: null, notice: null);

  Future<void> submit() async {
    if (state.busy) return;
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(busy: true, error: null, notice: null);
    try {
      final result = await ref
          .read(cloudFriendsRepositoryProvider)
          .addByCode(InviteCode.normalize(state.code));
      if (!ref.mounted) return;
      if (result == null) {
        state = state.copyWith(
          busy: false,
          error:
              "That code didn't work. Check it and try again, or ask them "
              'for a new one.',
        );
        return;
      }
      ref.invalidate(friendsProvider);
      state = AddFriendState(
        notice: result.accepted
            ? 'You and ${result.name} are now friends.'
            : 'Request sent to ${result.name}. They will see it in People.',
      );
    } on Object catch (error) {
      if (ref.mounted) {
        state = state.copyWith(busy: false, error: _messageFor(error));
      }
    }
  }
}

/// Answering a request, or removing a friend. The state is true while
/// something is happening.
@riverpod
class FriendActionsViewModel extends _$FriendActionsViewModel {
  @override
  bool build() => false;

  /// Accepts or declines a request. Returns a message on failure.
  Future<String?> respond(Friend friend, {required bool accept}) async {
    if (state) return null;
    state = true;
    try {
      await ref
          .read(cloudFriendsRepositoryProvider)
          .respond(friend.id, accept: accept);
      ref.invalidate(friendsProvider);
      return null;
    } on Object catch (error) {
      return _messageFor(error);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Removes a friend, or cancels a request. Returns a message on failure.
  Future<String?> remove(Friend friend) async {
    if (state) return null;
    state = true;
    try {
      await ref.read(cloudFriendsRepositoryProvider).remove(friend.id);
      ref.invalidate(friendsProvider);
      return null;
    } on Object catch (error) {
      return _messageFor(error);
    } finally {
      if (ref.mounted) state = false;
    }
  }
}
