import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:photoquest/core/data/repositories/cloud_friends_repository.dart';
import 'package:photoquest/core/data/repositories/cloud_memory_repository.dart';
import 'package:photoquest/core/data/repositories/cloud_quest_repository.dart';
import 'package:photoquest/core/data/services/connectivity/connectivity_service.dart';
import 'package:photoquest/core/data/services/image/image_processing_service.dart';
import 'package:photoquest/core/data/services/image/photo_picker_service.dart';
import 'package:photoquest/core/data/services/sharing/sharing_service.dart';
import 'package:photoquest/core/domain/friends/entities/friend.dart';
import 'package:photoquest/core/domain/sharing/entities/shared_memory.dart';
import 'package:photoquest/core/domain/sharing/entities/shared_quest.dart';
import 'package:photoquest/core/errors/app_failure.dart';

/// An in-memory stand-in for the cloud: what a friend shared, who can see my
/// memories, and which invite codes work. Records what the app asked for.
class FakeCloudMemoryRepository implements CloudMemoryRepository {
  final calls = <String>[];

  final validCodes = <String, InviteTarget>{};

  String inviteCode = 'ABCDE-FGHJK';

  AppFailure? failNext;

  final failuresByMemory = <String, AppFailure>{};

  /// When set, [createInvite] waits for it after reporting half way, so a
  /// test can look at the "saving" moment.
  Completer<void>? holdInvite;

  List<SharedMemorySummary> shared = [];
  final details = <String, SharedMemoryDetail>{};
  List<ShareViewer> viewers = [];
  bool online = false;
  StorageUsage usage = const StorageUsage(
    usedBytes: 12 * 1024 * 1024,
    quotaBytes: 100 * 1024 * 1024,
  );

  final addedPhotos = <Uint8List>[];

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  @override
  Future<void> backUpMemory(
    String memoryId, {
    ProgressCallback? onProgress,
  }) async {
    calls.add('backUp:$memoryId');
    _maybeFail();
    final failure = failuresByMemory[memoryId];
    if (failure != null) throw failure;
    online = true;
  }

  @override
  Future<bool> isOnline(String memoryId) async {
    calls.add('isOnline:$memoryId');
    return online;
  }

  @override
  Future<String> createInvite(
    String memoryId, {
    ProgressCallback? onProgress,
  }) async {
    calls.add('createInvite:$memoryId');
    onProgress?.call(0.5);
    await holdInvite?.future;
    _maybeFail();
    onProgress?.call(1);
    online = true;
    return inviteCode;
  }

  @override
  Future<void> shareWithFriend(
    String memoryId,
    String friendId, {
    ProgressCallback? onProgress,
  }) async {
    calls.add('shareWithFriend:$memoryId:$friendId');
    _maybeFail();
    online = true;
    viewers = [
      ...viewers,
      ShareViewer(id: friendId, name: friendId, sharedAt: DateTime(2026)),
    ];
  }

  @override
  Future<InviteTarget?> redeemInvite(String code) async {
    calls.add('redeem:$code');
    _maybeFail();
    return validCodes[code];
  }

  @override
  Future<List<SharedMemorySummary>> getSharedWithMe() async {
    calls.add('sharedWithMe');
    _maybeFail();
    return shared;
  }

  @override
  Future<SharedMemoryDetail> getSharedMemory(String memoryId) async {
    calls.add('sharedMemory:$memoryId');
    _maybeFail();
    final detail = details[memoryId];
    if (detail == null) {
      throw const SharingFailure(
        SharingFailureKind.notFound,
        'This memory is no longer shared with you.',
      );
    }
    return detail;
  }

  @override
  Future<void> leaveSharedMemory(String memoryId) async {
    calls.add('leave:$memoryId');
    _maybeFail();
    shared = [
      for (final m in shared)
        if (m.id != memoryId) m,
    ];
  }

  @override
  Future<void> addPhotosToMemory(
    String memoryId,
    List<Uint8List> photos, {
    ProgressCallback? onProgress,
  }) async {
    calls.add('addPhotos:$memoryId:${photos.length}');
    _maybeFail();
    addedPhotos.addAll(photos);
  }

  @override
  Future<List<ShareViewer>> getViewers(String memoryId) async {
    calls.add('viewers:$memoryId');
    return viewers;
  }

  @override
  Future<void> removeViewer(String memoryId, String viewerId) async {
    calls.add('removeViewer:$viewerId');
    _maybeFail();
    viewers = [
      for (final v in viewers)
        if (v.id != viewerId) v,
    ];
  }

  @override
  Future<StorageUsage> getStorageUsage() async {
    calls.add('usage');
    return usage;
  }

  @override
  Future<void> removeOnlineCopy(String memoryId) async {
    calls.add('removeOnlineCopy:$memoryId');
    _maybeFail();
    online = false;
    viewers = [];
  }
}

/// An in-memory stand-in for quest invitations and participation.
class FakeCloudQuestRepository implements CloudQuestRepository {
  final calls = <String>[];
  String inviteCode = 'QUEST-CODE1';
  AppFailure? failNext;

  List<SharedQuestSummary> quests = [];
  final details = <String, SharedQuestDetail>{};
  List<ShareViewer> participants = [];

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  @override
  Future<String> createInvite(String questId) async {
    calls.add('createInvite:$questId');
    _maybeFail();
    return inviteCode;
  }

  @override
  Future<void> inviteFriend(String questId, String friendId) async {
    calls.add('inviteFriend:$questId:$friendId');
    _maybeFail();
    participants = [
      ...participants,
      ShareViewer(
        id: friendId,
        name: friendId,
        sharedAt: DateTime(2026),
        status: 'Invited',
      ),
    ];
  }

  @override
  Future<List<SharedQuestSummary>> getMyQuests() async {
    calls.add('myQuests');
    _maybeFail();
    return quests;
  }

  @override
  Future<SharedQuestDetail> getQuest(String questId) async {
    calls.add('quest:$questId');
    _maybeFail();
    final detail = details[questId];
    if (detail == null) {
      throw const SharingFailure(
        SharingFailureKind.notFound,
        'This quest is no longer shared with you.',
      );
    }
    return detail;
  }

  @override
  Future<void> respond(String questId, {required bool accept}) async {
    calls.add('respond:$questId:$accept');
    _maybeFail();
    final index = quests.indexWhere((q) => q.id == questId);
    if (index == -1) return;
    final quest = quests[index];
    if (!accept) {
      quests = [...quests]..removeAt(index);
      return;
    }
    final joined = SharedQuestSummary(
      id: quest.id,
      title: quest.title,
      description: quest.description,
      ownerName: quest.ownerName,
      status: ParticipationStatus.accepted,
    );
    quests = [...quests]..[index] = joined;
    final detail = details[questId];
    if (detail != null) {
      details[questId] = SharedQuestDetail(
        id: detail.id,
        title: detail.title,
        description: detail.description,
        ownerName: detail.ownerName,
        status: ParticipationStatus.accepted,
        shots: detail.shots,
        participants: detail.participants,
        memories: detail.memories,
      );
    }
  }

  @override
  Future<void> leave(String questId) async {
    calls.add('leave:$questId');
    _maybeFail();
    quests = [
      for (final q in quests)
        if (q.id != questId) q,
    ];
  }

  @override
  Future<List<ShareViewer>> getParticipants(String questId) async {
    calls.add('participants:$questId');
    return participants;
  }

  @override
  Future<void> removeParticipant(String questId, String userId) async {
    calls.add('removeParticipant:$userId');
    _maybeFail();
    participants = [
      for (final p in participants)
        if (p.id != userId) p,
    ];
  }
}

/// Real friends, in memory: who is a friend, who asked, and which codes work.
class FakeCloudFriendsRepository implements CloudFriendsRepository {
  final calls = <String>[];

  String myCode = 'ABCDEFGHJK';
  AppFailure? failNext;
  List<Friend> friends = [];

  final validCodes = <String, FriendRequestResult>{};

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  @override
  Future<String> getMyFriendCode() async {
    calls.add('myCode');
    _maybeFail();
    return myCode;
  }

  @override
  Future<String> resetFriendCode() async {
    calls.add('resetCode');
    _maybeFail();
    myCode = 'MNPQRSTVWX';
    return myCode;
  }

  @override
  Future<FriendRequestResult?> addByCode(String code) async {
    calls.add('add:$code');
    _maybeFail();
    final result = validCodes[code];
    if (result == null) return null;
    friends = [
      ...friends.where((f) => f.id != result.userId),
      Friend(
        id: result.userId,
        name: result.name,
        status: result.accepted
            ? FriendStatus.friend
            : FriendStatus.requestedByMe,
      ),
    ];
    return result;
  }

  @override
  Future<List<Friend>> getFriends() async {
    calls.add('friends');
    _maybeFail();
    return friends;
  }

  @override
  Future<void> respond(String userId, {required bool accept}) async {
    calls.add('respond:$userId:$accept');
    _maybeFail();
    friends = [
      for (final f in friends)
        if (f.id != userId)
          f
        else if (accept)
          Friend(id: f.id, name: f.name, status: FriendStatus.friend),
    ];
  }

  @override
  Future<void> remove(String userId) async {
    calls.add('remove:$userId');
    _maybeFail();
    friends = [
      for (final f in friends)
        if (f.id != userId) f,
    ];
  }
}

/// Records what the app tried to send instead of opening a share sheet.
class FakeSharingService extends SharingService {
  String? sentText;

  @override
  Future<void> shareText(String text, {Rect? origin}) async {
    sentText = text;
  }
}

/// Hands back photos without opening the library.
class FakePhotoPickerService extends PhotoPickerService {
  FakePhotoPickerService([this.photos = const []]);

  List<Uint8List> photos;

  @override
  Future<List<Uint8List>> pickPhotos() async => photos;
}

/// Says whether the phone is on Wi-Fi, as the test decides.
class FakeConnectivityService extends ConnectivityService {
  FakeConnectivityService({this.wifi = true});

  bool wifi;

  @override
  Future<bool> isOnWifi() async => wifi;
}
