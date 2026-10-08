import 'dart:ui' show Rect;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/cloud_memory_repository_provider.dart';
import '../../../data/repositories/service_providers.dart';
import '../../../domain/friends/entities/friend.dart';
import '../../../domain/sharing/entities/shared_memory.dart';
import '../../../domain/sharing/entities/shared_quest.dart';
import '../../../domain/sharing/invite_code.dart';
import '../../../errors/app_failure.dart';
import '../../../utils/provider_retry.dart';
import '../../types/sharing/shared_hub.dart';
import '../../types/sharing/sharing_states.dart';

part 'sharing_view_models.g.dart';

const _genericError = "We couldn't do that just now. Please try again.";

String _messageFor(Object error) =>
    error is AppFailure ? error.message : _genericError;

/// The "Invite a friend" sheet for one of my memories: saves it online, makes
/// a code, lists (and removes) the friends who can see it, and can take the
/// online copy away again.
@riverpod
class ShareMemoryViewModel extends _$ShareMemoryViewModel {
  @override
  ShareMemoryState build(String memoryId) {
    Future.microtask(refresh);
    return const ShareMemoryState();
  }

  Future<void> refresh() async {
    try {
      final cloud = ref.read(cloudMemoryRepositoryProvider);
      final viewers = await cloud.getViewers(memoryId);
      final online = await cloud.isOnline(memoryId);
      if (ref.mounted) {
        state = state.copyWith(viewers: viewers, isOnline: online);
      }
    } on Object {
      // Offline: the list stays as it was.
    }
    await _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final all = await ref.read(cloudFriendsRepositoryProvider).getFriends();
      if (ref.mounted) {
        state = state.copyWith(
          friends: [
            for (final f in all)
              if (f.isFriend) f,
          ],
        );
      }
    } on Object {
      return;
    }
  }

  Future<void> inviteFriend(Friend friend) async {
    state = state.copyWith(error: null);
    try {
      await ref
          .read(cloudMemoryRepositoryProvider)
          .shareWithFriend(memoryId, friend.id);
      await refresh();
    } on Object catch (error) {
      if (ref.mounted) state = state.copyWith(error: _messageFor(error));
    }
  }

  Future<void> createInvite() async {
    if (state.phase == SharePhase.saving) return;
    state = state.copyWith(phase: SharePhase.saving, progress: 0, error: null);
    try {
      final code = await ref
          .read(cloudMemoryRepositoryProvider)
          .createInvite(
            memoryId,
            onProgress: (progress) {
              if (ref.mounted) state = state.copyWith(progress: progress);
            },
          );
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: SharePhase.ready,
        code: InviteCode.format(code),
        progress: 1,
      );
      await refresh();
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(phase: SharePhase.idle, error: _messageFor(error));
    }
  }

  String get inviteMessage {
    final code = state.code;
    return "Here's my Photo Quest invite code: $code\n\n"
        'Open Photo Quest, go to Memories, then Shared with you, and enter '
        'the code to see the memory.';
  }

  Future<String?> sendCode({Rect? origin}) async {
    if (state.code == null) return null;
    try {
      await ref
          .read(sharingServiceProvider)
          .shareText(inviteMessage, origin: origin);
      return null;
    } on Object {
      return "We couldn't open sharing just now.";
    }
  }

  Future<void> removeViewer(String viewerId) async {
    try {
      await ref
          .read(cloudMemoryRepositoryProvider)
          .removeViewer(memoryId, viewerId);
      await refresh();
    } on Object catch (error) {
      if (ref.mounted) state = state.copyWith(error: _messageFor(error));
    }
  }

  /// Takes the memory's online copy away: its files, records, codes and who
  /// can see it. The memory on the phone stays. Frees storage.
  Future<void> removeOnlineCopy() async {
    if (state.removing) return;
    state = state.copyWith(removing: true, error: null);
    try {
      await ref.read(cloudMemoryRepositoryProvider).removeOnlineCopy(memoryId);
      if (!ref.mounted) return;
      state = const ShareMemoryState();
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(removing: false, error: _messageFor(error));
    }
  }
}

/// The "Invite a friend" sheet for one of my quests.
@riverpod
class ShareQuestViewModel extends _$ShareQuestViewModel {
  @override
  ShareMemoryState build(String questId) {
    Future.microtask(refresh);
    return const ShareMemoryState();
  }

  Future<void> refresh() async {
    try {
      final people = await ref
          .read(cloudQuestRepositoryProvider)
          .getParticipants(questId);
      if (ref.mounted) state = state.copyWith(viewers: people);
    } on Object {
      // Offline: the list stays as it was.
    }
    try {
      final all = await ref.read(cloudFriendsRepositoryProvider).getFriends();
      if (ref.mounted) {
        state = state.copyWith(
          friends: [
            for (final f in all)
              if (f.isFriend) f,
          ],
        );
      }
    } on Object {
      return;
    }
  }

  /// Invites a friend to this quest straight away, with no code. They still
  /// choose to accept.
  Future<void> inviteFriend(Friend friend) async {
    state = state.copyWith(error: null);
    try {
      await ref
          .read(cloudQuestRepositoryProvider)
          .inviteFriend(questId, friend.id);
      await refresh();
    } on Object catch (error) {
      if (ref.mounted) state = state.copyWith(error: _messageFor(error));
    }
  }

  Future<void> createInvite() async {
    if (state.phase == SharePhase.saving) return;
    state = state.copyWith(phase: SharePhase.saving, progress: 0, error: null);
    try {
      final code = await ref
          .read(cloudQuestRepositoryProvider)
          .createInvite(questId);
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: SharePhase.ready,
        code: InviteCode.format(code),
        progress: 1,
      );
      await refresh();
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(phase: SharePhase.idle, error: _messageFor(error));
    }
  }

  String get inviteMessage {
    final code = state.code;
    return "Come do a quest with me on Photo Quest! Here's my invite code: "
        '$code\n\n'
        'Open Photo Quest, go to Memories, then Shared with you, and enter '
        'the code to join.';
  }

  Future<String?> sendCode({Rect? origin}) async {
    if (state.code == null) return null;
    try {
      await ref
          .read(sharingServiceProvider)
          .shareText(inviteMessage, origin: origin);
      return null;
    } on Object {
      return "We couldn't open sharing just now.";
    }
  }

  Future<void> removeParticipant(String userId) async {
    try {
      await ref
          .read(cloudQuestRepositoryProvider)
          .removeParticipant(questId, userId);
      await refresh();
    } on Object catch (error) {
      if (ref.mounted) state = state.copyWith(error: _messageFor(error));
    }
  }
}

/// The "Got a code?" form. A code can be for a memory or for a quest.
@riverpod
class JoinMemoryViewModel extends _$JoinMemoryViewModel {
  @override
  JoinFormState build() => const JoinFormState();

  void setCode(String value) =>
      state = state.copyWith(code: value, error: null);

  /// Returns what the code was for when it worked, otherwise null (and the
  /// form says why).
  Future<InviteTarget?> submit() async {
    if (state.busy) return null;
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return null;
    }
    state = state.copyWith(busy: true, error: null);
    try {
      final target = await ref
          .read(cloudMemoryRepositoryProvider)
          .redeemInvite(InviteCode.normalize(state.code));
      if (target == null) {
        state = state.copyWith(
          busy: false,
          error:
              "That code didn't work. Check it and try again, or ask your "
              'friend for a new one.',
        );
        return null;
      }
      ref.invalidate(sharedMemoriesProvider);
      ref.invalidate(sharedQuestsProvider);
      state = state.copyWith(busy: false);
      return target;
    } on Object catch (error) {
      state = state.copyWith(busy: false, error: _messageFor(error));
      return null;
    }
  }
}

/// Memories friends shared with me.
@Riverpod(retry: neverRetry)
Future<List<SharedMemorySummary>> sharedMemories(Ref ref) =>
    ref.watch(cloudMemoryRepositoryProvider).getSharedWithMe();

/// Quests I've been invited to or have joined.
@Riverpod(retry: neverRetry)
Future<List<SharedQuestSummary>> sharedQuests(Ref ref) =>
    ref.watch(cloudQuestRepositoryProvider).getMyQuests();

/// Everything shared with me, in one list.
@Riverpod(retry: neverRetry)
Future<SharedHub> sharedHub(Ref ref) async {
  final quests = await ref.watch(sharedQuestsProvider.future);
  final memories = await ref.watch(sharedMemoriesProvider.future);
  return SharedHub(
    invitations: [
      for (final q in quests)
        if (q.status == ParticipationStatus.invited) q,
    ],
    quests: [
      for (final q in quests)
        if (q.status == ParticipationStatus.accepted) q,
    ],
    memories: memories,
  );
}

/// One shared memory, with fresh links to its photos.
@Riverpod(retry: neverRetry)
Future<SharedMemoryDetail> sharedMemory(Ref ref, String memoryId) =>
    ref.watch(cloudMemoryRepositoryProvider).getSharedMemory(memoryId);

/// Actions on a memory somebody shared with me. The state is true while the
/// person's own photos are being added.
@riverpod
class SharedMemoryViewModel extends _$SharedMemoryViewModel {
  @override
  bool build(String memoryId) => false;

  Future<String?> leave() async {
    try {
      await ref.read(cloudMemoryRepositoryProvider).leaveSharedMemory(memoryId);
      ref.invalidate(sharedMemoriesProvider);
      return null;
    } on Object catch (error) {
      return _messageFor(error);
    }
  }

  /// Lets the person pick photos and adds them to this memory. Returns a
  /// message on failure, otherwise null (also null when they back out).
  Future<String?> addPhotos() async {
    if (state) return null;
    try {
      final picked = await ref.read(photoPickerServiceProvider).pickPhotos();
      if (picked.isEmpty || !ref.mounted) return null;
      state = true;
      await ref
          .read(cloudMemoryRepositoryProvider)
          .addPhotosToMemory(memoryId, picked);
      ref.invalidate(sharedMemoryProvider(memoryId));
      return null;
    } on Object catch (error) {
      return _messageFor(error);
    } finally {
      if (ref.mounted) state = false;
    }
  }
}

/// One shared quest: what it is, who is in, and the memories made from it.
@Riverpod(retry: neverRetry)
Future<SharedQuestDetail> sharedQuest(Ref ref, String questId) =>
    ref.watch(cloudQuestRepositoryProvider).getQuest(questId);

/// Answering an invitation, or leaving a quest. The state is true while
/// something is happening.
@riverpod
class SharedQuestViewModel extends _$SharedQuestViewModel {
  @override
  bool build(String questId) => false;

  void _refreshEverywhere() {
    ref.invalidate(sharedQuestsProvider);
    ref.invalidate(sharedQuestProvider(questId));
  }

  Future<String?> respond({required bool accept}) async {
    if (state) return null;
    state = true;
    try {
      await ref
          .read(cloudQuestRepositoryProvider)
          .respond(questId, accept: accept);
      _refreshEverywhere();
      return null;
    } on Object catch (error) {
      return _messageFor(error);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  Future<String?> leave() async {
    if (state) return null;
    state = true;
    try {
      await ref.read(cloudQuestRepositoryProvider).leave(questId);
      _refreshEverywhere();
      return null;
    } on Object catch (error) {
      return _messageFor(error);
    } finally {
      if (ref.mounted) state = false;
    }
  }
}
