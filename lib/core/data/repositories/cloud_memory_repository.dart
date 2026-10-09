import 'dart:async';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../config/constant/app_constants.dart';
import '../../domain/memories/entities/memory.dart';
import '../../domain/memories/entities/photo.dart';
import '../../domain/quests/entities/quest_session.dart';
import '../../domain/sharing/entities/shared_memory.dart';
import '../../domain/sharing/entities/shared_quest.dart';
import '../../errors/app_failure.dart';
import '../services/image/image_processing_service.dart';
import '../services/storage/photo_storage_service.dart';
import '../services/storage/storage_tree_cleaner.dart';
import 'cloud_support.dart';
import 'memory_repository.dart';
import 'quest_repository.dart';
import 'quest_uploader.dart';

/// Backs up a memory to the person's account and shares it with friends.
///
/// Memories are only uploaded when asked (inviting a friend, or backup turned
/// on in Settings). The full-size originals never leave the phone: only
/// compressed copies go up. Every method throws a [SharingFailure] with copy
/// that is safe to show. Abstract so view models can be tested without a
/// network.
abstract class CloudMemoryRepository {
  /// Copies a memory (and the quest it came from) to the account. Safe to run
  /// again: it only uploads what is missing, so an interrupted upload picks up
  /// where it stopped. [onProgress] goes from 0 to 1.
  Future<void> backUpMemory(String memoryId, {ProgressCallback? onProgress});

  Future<bool> isOnline(String memoryId);

  /// Whether this memory was made from a quest the person has invited friends
  /// to (invited or joined). Those friends can only see it once it is online.
  Future<bool> isFromSharedQuest(String memoryId);

  /// Backs the memory up if needed, then makes a code a friend can use to view
  /// it. The code is only ever shown once, here.
  Future<String> createInvite(String memoryId, {ProgressCallback? onProgress});

  /// Backs the memory up if needed, then lets a real friend (someone added in
  /// People) view it, with no code. They find it under Shared with you.
  Future<void> shareWithFriend(
    String memoryId,
    String friendId, {
    ProgressCallback? onProgress,
  });

  /// Uses a friend's code, for a memory or for a quest. Returns what it was
  /// for, or null when the code doesn't work (wrong, expired, used up or
  /// revoked: deliberately the same).
  Future<InviteTarget?> redeemInvite(String code);

  Future<List<SharedMemorySummary>> getSharedWithMe();

  Future<SharedMemoryDetail> getSharedMemory(String memoryId);

  Future<void> leaveSharedMemory(String memoryId);

  Future<void> addPhotosToMemory(
    String memoryId,
    List<Uint8List> photos, {
    ProgressCallback? onProgress,
  });

  Future<List<ShareViewer>> getViewers(String memoryId);

  Future<void> removeViewer(String memoryId, String viewerId);

  Future<StorageUsage> getStorageUsage();

  /// Removes a memory's online copy (files and records), including photos
  /// friends added. The memory on the phone is untouched.
  Future<void> removeOnlineCopy(String memoryId);
}

class SupabaseCloudMemoryRepository implements CloudMemoryRepository {
  SupabaseCloudMemoryRepository({
    required SupabaseClient? client,
    required this._memories,
    required QuestRepository quests,
    required this._images,
    required this._storage,
    String? Function()? currentUserId,
  }) : _support = CloudSupport(client: client, currentUserId: currentUserId) {
    _questUploader = QuestUploader(_support, quests);
  }

  final CloudSupport _support;
  final MemoryRepository _memories;
  final ImageProcessingService _images;
  final PhotoStorageService _storage;
  late final QuestUploader _questUploader;

  static const _mimeTypes = {
    'jpg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
    'mp4': 'video/mp4',
  };

  static const _sessionStatuses = {'in_progress', 'completed', 'cancelled'};

  @override
  Future<void> backUpMemory(String memoryId, {ProgressCallback? onProgress}) =>
      _support.guard(() async {
        final db = _support.db;
        final uid = _support.userId;

        final memory = await _memories.getMemory(memoryId);
        if (memory == null) {
          throw const SharingFailure(
            SharingFailureKind.notFound,
            "We couldn't find that memory.",
          );
        }
        final session = await _memories.getSession(memory.questSessionId);
        final quest = session == null
            ? null
            : await _questUploader.questFor(session.questId);
        final photos = [...await _memories.getPhotos(memoryId)]
          ..sort((a, b) => a.position.compareTo(b.position));

        // One step for the memory's details, then one per photo.
        final total = photos.length + 1;
        var done = 0;
        void step() => onProgress?.call(++done / total);

        var sessionSaved = false;
        final savedShotIds = <String>{};
        if (quest != null && session != null) {
          savedShotIds.addAll(await _questUploader.backUp(quest));
          await _ensureSession(db, uid, session);
          sessionSaved = true;
        }
        await _ensureMemory(db, uid, memory, sessionSaved ? session!.id : null);
        step();

        // The memory must exist before its files do: the storage policy
        // refuses files for a memory it can't find.
        final uploaded = await _support.existingIds(
          'photos',
          'memory_id',
          memoryId,
        );
        for (final photo in photos) {
          if (!uploaded.contains(photo.id)) {
            await _uploadPhoto(db, uid, photo, savedShotIds);
          }
          step();
        }

        final cover = memory.coverPhotoId;
        if (cover != null && photos.any((photo) => photo.id == cover)) {
          await db
              .from('memories')
              .update({'cover_photo_id': cover})
              .eq('id', memoryId);
        }
      });

  @override
  Future<bool> isOnline(String memoryId) => _support.guard(() async {
    final row = await _support.db
        .from('memories')
        .select('id')
        .eq('id', memoryId)
        .eq('owner_id', _support.userId)
        .maybeSingle();
    return row != null;
  });

  @override
  Future<bool> isFromSharedQuest(String memoryId) => _support.guard(() async {
    final memory = await _memories.getMemory(memoryId);
    if (memory == null) return false;
    final session = await _memories.getSession(memory.questSessionId);
    if (session == null) return false;
    final rows = await _support.db
        .from('quest_participants')
        .select('user_id')
        .eq('quest_id', session.questId)
        .neq('user_id', _support.userId)
        .inFilter('status', ['invited', 'accepted'])
        .limit(1);
    return rows.isNotEmpty;
  });

  Future<void> _ensureSession(
    SupabaseClient db,
    String uid,
    QuestSession session,
  ) async {
    final existing = await db
        .from('quest_sessions')
        .select('id')
        .eq('id', session.id)
        .maybeSingle();
    if (existing != null) return;

    final completedAt = session.completedAt;
    await db.from('quest_sessions').insert({
      'id': session.id,
      'quest_id': session.questId,
      'owner_id': uid,
      'started_at': CloudSupport.iso(session.startedAt),
      // The server insists a session can't finish before it starts.
      'completed_at': completedAt == null
          ? null
          : CloudSupport.iso(
              completedAt.isBefore(session.startedAt)
                  ? session.startedAt
                  : completedAt,
            ),
      'status': _sessionStatuses.contains(session.status)
          ? session.status
          : 'completed',
    });
  }

  Future<void> _ensureMemory(
    SupabaseClient db,
    String uid,
    Memory memory,
    String? sessionId,
  ) async {
    final title = CloudSupport.clamp(memory.title, 100, fallback: 'Our memory');
    final note = CloudSupport.clampOrNull(memory.note, 2000);

    final existing = await db
        .from('memories')
        .select('id')
        .eq('id', memory.id)
        .maybeSingle();
    if (existing != null) {
      // Pick up edits made since the last upload.
      await db
          .from('memories')
          .update({'title': title, 'note': note})
          .eq('id', memory.id);
      return;
    }

    await db.from('memories').insert({
      'id': memory.id,
      'owner_id': uid,
      'quest_session_id': sessionId,
      'title': title,
      'note': note,
      'captured_at': CloudSupport.iso(memory.capturedAt),
    });
  }

  Future<void> _uploadPhoto(
    SupabaseClient db,
    String uid,
    Photo photo,
    Set<String> savedShotIds,
  ) async {
    final folder = '$uid/${photo.memoryId}';

    var kind = photo.kind;
    var extension = _extensionOf(photo.originalPath);
    var width = photo.width;
    var height = photo.height;
    Uint8List main;

    if (photo.kind == PhotoKind.photo) {
      main = await _images.createShareCopy(
        await _storage.readBytes(photo.originalPath),
      );
      extension = 'jpg';
      final (w, h) = ImageProcessingService.sizeOf(main);
      if (w > 0 && h > 0) (width, height) = (w, h);
    } else {
      final raw = await _storage.readBytes(photo.originalPath);
      if (raw.length > AppConstants.sharedFileMaxBytes ||
          !_mimeTypes.containsKey(extension)) {
        // Too big (or a type the bucket won't take): share its still poster.
        main = await _images.createShareCopy(
          await _storage.readBytes(photo.thumbnailPath),
        );
        kind = PhotoKind.photo;
        extension = 'jpg';
        (width, height) = (0, 0);
      } else {
        main = raw;
      }
    }

    final thumbnail = await _storage.readBytes(photo.thumbnailPath);
    final mainPath = '$folder/${photo.id}.$extension';
    final thumbPath = '$folder/${photo.id}_thumb.jpg';

    await _support.uploadPhoto(
      mainPath,
      main,
      contentType: _mimeTypes[extension],
    );
    await _support.uploadPhoto(thumbPath, thumbnail, contentType: 'image/jpeg');

    final shotId = photo.shotId;
    await db.from('photos').insert({
      'id': photo.id,
      'memory_id': photo.memoryId,
      'owner_id': uid,
      'uploaded_by': uid,
      'shot_id': shotId != null && savedShotIds.contains(shotId)
          ? shotId
          : null,
      'storage_path': mainPath,
      'thumbnail_path': thumbPath,
      'position': photo.position < 0 ? 0 : photo.position,
      'kind': kind,
      'width': width > 0 ? width : null,
      'height': height > 0 ? height : null,
      'mirrored': kind == PhotoKind.video && photo.mirrored,
      'captured_at': CloudSupport.iso(photo.capturedAt),
    });
  }

  @override
  Future<String> createInvite(
    String memoryId, {
    ProgressCallback? onProgress,
  }) => _support.guard(() async {
    await backUpMemory(memoryId, onProgress: onProgress);
    final code = await _support.db.rpc<dynamic>(
      'create_memory_invite',
      params: {
        'p_memory_id': memoryId,
        'p_valid_days': AppConstants.inviteValidDays,
        'p_max_uses': AppConstants.inviteMaxUses,
      },
    );
    return code as String;
  });

  @override
  Future<void> shareWithFriend(
    String memoryId,
    String friendId, {
    ProgressCallback? onProgress,
  }) => _support.guard(() async {
    await backUpMemory(memoryId, onProgress: onProgress);
    await _support.db.rpc<dynamic>(
      'share_memory_with_friend',
      params: {'p_memory': memoryId, 'p_friend': friendId},
    );
  });

  @override
  Future<InviteTarget?> redeemInvite(String code) => _support.guard(() async {
    final result = await _support.db.rpc<dynamic>(
      'redeem_invite',
      params: {'p_code': code},
    );
    if (result is! Map<String, dynamic>) return null;
    final kind = result['kind'] == 'quest'
        ? InviteKind.quest
        : InviteKind.memory;
    return InviteTarget(kind, result['id'] as String);
  });

  @override
  Future<List<SharedMemorySummary>> getSharedWithMe() =>
      _support.guard(() async {
        final db = _support.db;
        final shares = await db
            .from('memory_shares')
            .select('memory_id, owner_id')
            .eq('viewer_id', _support.userId)
            .order('created_at', ascending: false);
        if (shares.isEmpty) return const [];

        final memoryIds = [for (final s in shares) s['memory_id'] as String];
        final memoryRows = await db
            .from('memories')
            .select('id, owner_id, title, captured_at')
            .inFilter('id', memoryIds);

        // Newest share first, as the shares came back.
        final byId = {for (final row in memoryRows) row['id'] as String: row};
        return _support.memorySummaries([
          for (final share in shares) ?byId[share['memory_id']],
        ]);
      });

  @override
  Future<SharedMemoryDetail> getSharedMemory(String memoryId) =>
      _support.guard(() async {
        final db = _support.db;
        final row = await db
            .from('memories')
            .select('id, owner_id, quest_session_id, title, note, captured_at')
            .eq('id', memoryId)
            .maybeSingle();
        if (row == null) {
          throw const SharingFailure(
            SharingFailureKind.notFound,
            'This memory is no longer shared with you.',
          );
        }

        final ownerId = row['owner_id'] as String;
        final owner = await db
            .from('profiles')
            .select('display_name, avatar_path')
            .eq('id', ownerId)
            .maybeSingle();

        final photoRows = await db
            .from('photos')
            .select(
              'id, position, kind, storage_path, thumbnail_path, width, '
              'height, mirrored, uploaded_by',
            )
            .eq('memory_id', memoryId)
            .order('position', ascending: true);

        // Names of friends who added photos (only the people I may see).
        final adders = {
          for (final p in photoRows)
            if (p['uploaded_by'] != ownerId) p['uploaded_by'] as String,
        };
        final names = await _support.profileNames(adders);

        final photoUrls = await _support.signedUrls(CloudSupport.photosBucket, [
          for (final p in photoRows) ...[
            p['storage_path'] as String,
            ?(p['thumbnail_path'] as String?),
          ],
        ]);
        final avatarPath = owner?['avatar_path'] as String?;
        final avatarUrls = await _support.signedUrls(
          CloudSupport.avatarsBucket,
          [?avatarPath],
        );

        return SharedMemoryDetail(
          id: memoryId,
          title: row['title'] as String,
          note: row['note'] as String?,
          capturedAt: DateTime.parse(row['captured_at'] as String).toLocal(),
          ownerName: CloudSupport.nameOf(owner?['display_name'] as String?),
          ownerAvatarUrl: avatarUrls[avatarPath],
          canAddPhotos: await _canAddPhotos(row, ownerId),
          photos: [
            for (final p in photoRows)
              if (photoUrls[p['storage_path']] case final url?)
                SharedPhoto(
                  id: p['id'] as String,
                  position: p['position'] as int,
                  kind: p['kind'] as String,
                  url: url,
                  thumbnailUrl: photoUrls[p['thumbnail_path']],
                  width: p['width'] as int?,
                  height: p['height'] as int?,
                  mirrored: p['mirrored'] as bool? ?? false,
                  addedByName: p['uploaded_by'] == ownerId
                      ? null
                      : names[p['uploaded_by']] ?? 'A friend',
                ),
          ],
        );
      });

  /// The owner and friends taking part in the memory's quest may add photos.
  /// Quest sessions are only readable by exactly those people, so being able
  /// to read this memory's session is the answer.
  Future<bool> _canAddPhotos(
    Map<String, dynamic> memory,
    String ownerId,
  ) async {
    if (ownerId == _support.userId) return true;
    final sessionId = memory['quest_session_id'] as String?;
    if (sessionId == null) return false;
    final session = await _support.db
        .from('quest_sessions')
        .select('id')
        .eq('id', sessionId)
        .maybeSingle();
    return session != null;
  }

  @override
  Future<void> leaveSharedMemory(String memoryId) => _support.guard(() async {
    await _support.db
        .from('memory_shares')
        .delete()
        .eq('memory_id', memoryId)
        .eq('viewer_id', _support.userId);
  });

  @override
  Future<void> addPhotosToMemory(
    String memoryId,
    List<Uint8List> photos, {
    ProgressCallback? onProgress,
  }) => _support.guard(() async {
    final db = _support.db;
    final uid = _support.userId;

    final memory = await db
        .from('memories')
        .select('id, owner_id')
        .eq('id', memoryId)
        .maybeSingle();
    if (memory == null) {
      throw const SharingFailure(
        SharingFailureKind.notFound,
        'This memory is no longer shared with you.',
      );
    }
    final ownerId = memory['owner_id'] as String;

    final existing = await db
        .from('photos')
        .select('position')
        .eq('memory_id', memoryId);
    var next =
        existing.fold<int>(
          -1,
          (max, row) =>
              (row['position'] as int) > max ? row['position'] as int : max,
        ) +
        1;

    const uuid = Uuid();
    for (var i = 0; i < photos.length; i++) {
      final id = uuid.v4();
      final folder = '$uid/$memoryId';
      final main = await _images.createShareCopy(photos[i]);
      final thumbnail = await _images.createThumbnail(main);
      final (width, height) = ImageProcessingService.sizeOf(main);

      final mainPath = '$folder/$id.jpg';
      final thumbPath = '$folder/${id}_thumb.jpg';
      try {
        await _support.uploadPhoto(mainPath, main, contentType: 'image/jpeg');
        await _support.uploadPhoto(
          thumbPath,
          thumbnail,
          contentType: 'image/jpeg',
        );
        await db.from('photos').insert({
          'id': id,
          'memory_id': memoryId,
          'owner_id': ownerId,
          'uploaded_by': uid,
          'storage_path': mainPath,
          'thumbnail_path': thumbPath,
          'position': next++,
          'kind': PhotoKind.photo,
          'width': width > 0 ? width : null,
          'height': height > 0 ? height : null,
          'captured_at': CloudSupport.iso(DateTime.now()),
        });
      } on Object {
        // If no row points at these files, nothing else would ever remove
        // them and they would keep using the person's allowance. But the
        // insert may have been saved even though its answer never arrived,
        // so the files go only when the row is confirmed missing.
        try {
          final saved = await db
              .from('photos')
              .select('id')
              .eq('id', id)
              .maybeSingle();
          if (saved == null) {
            await db.storage.from(CloudSupport.photosBucket).remove([
              mainPath,
              thumbPath,
            ]);
          }
        } on Object {
          // Outcome unknown: keep the files. The original failure is the one
          // to report.
        }
        rethrow;
      }
      onProgress?.call((i + 1) / photos.length);
    }
  });

  @override
  Future<List<ShareViewer>> getViewers(String memoryId) =>
      _support.guard(() async {
        final db = _support.db;
        final shares = await db
            .from('memory_shares')
            .select('viewer_id, created_at')
            .eq('memory_id', memoryId)
            .order('created_at', ascending: true);
        if (shares.isEmpty) return const [];

        final ids = [for (final s in shares) s['viewer_id'] as String];
        final profiles = await db
            .from('profiles')
            .select('id, display_name, avatar_path')
            .inFilter('id', ids);
        final byId = {for (final p in profiles) p['id'] as String: p};
        final avatars = await _support.signedUrls(CloudSupport.avatarsBucket, [
          for (final p in profiles) ?(p['avatar_path'] as String?),
        ]);

        return [
          for (final share in shares)
            ShareViewer(
              id: share['viewer_id'] as String,
              name: CloudSupport.nameOf(
                byId[share['viewer_id']]?['display_name'] as String?,
              ),
              avatarUrl: avatars[byId[share['viewer_id']]?['avatar_path']],
              sharedAt: DateTime.parse(share['created_at'] as String).toLocal(),
            ),
        ];
      });

  @override
  Future<void> removeViewer(String memoryId, String viewerId) =>
      _support.guard(() async {
        await _support.db
            .from('memory_shares')
            .delete()
            .eq('memory_id', memoryId)
            .eq('viewer_id', viewerId);
      });

  @override
  Future<StorageUsage> getStorageUsage() => _support.storageUsage();

  @override
  Future<void> removeOnlineCopy(String memoryId) => _support.guard(() async {
    final db = _support.db;
    final uid = _support.userId;
    final files = db.storage.from(CloudSupport.photosBucket);

    // Files first (Storage isn't touched by database cascades): every photo
    // the records point at, including friends', then anything left in the
    // owner's own folder for this memory.
    final rows = await db
        .from('photos')
        .select('storage_path, thumbnail_path')
        .eq('memory_id', memoryId);
    final paths = {
      for (final row in rows) ...[
        row['storage_path'] as String,
        ?(row['thumbnail_path'] as String?),
      ],
    }.toList();
    const batch = 100;
    for (var i = 0; i < paths.length; i += batch) {
      await files.remove(
        paths.sublist(i, i + batch > paths.length ? paths.length : i + batch),
      );
    }
    const cleaner = StorageTreeCleaner();
    await cleaner.deleteTree(
      '$uid/$memoryId',
      list: (folder, offset) async {
        final items = await files.list(
          path: folder,
          searchOptions: SearchOptions(limit: cleaner.pageSize, offset: offset),
        );
        return [
          for (final item in items)
            StorageEntry(item.name, isFolder: item.id == null),
        ];
      },
      remove: (toRemove) async {
        await files.remove(toRemove);
      },
    );

    // Then the records. Photos, shares and invites go with the memory.
    await db.from('memories').delete().eq('id', memoryId).eq('owner_id', uid);
  });

  /// The last `.ext` of [path], lowercased, without the dot; `jpeg` counts as
  /// `jpg`.
  static String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    final extension = dot == -1 ? '' : path.substring(dot + 1).toLowerCase();
    return extension == 'jpeg' ? 'jpg' : extension;
  }
}
