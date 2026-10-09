import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:photoquest/core/data/database/app_database.dart';
import 'package:photoquest/core/data/repositories/cloud_memory_repository.dart';
import 'package:photoquest/core/data/repositories/memory_repository.dart';
import 'package:photoquest/core/data/repositories/quest_repository.dart';
import 'package:photoquest/core/data/services/image/image_processing_service.dart';
import 'package:photoquest/core/data/services/storage/photo_storage_service.dart';
import 'package:photoquest/core/domain/memories/entities/photo.dart';
import 'package:photoquest/core/domain/sharing/entities/shared_quest.dart';
import 'package:photoquest/core/errors/app_failure.dart';

import '../support/fake_supabase_server.dart';

const _me = 'a0000000-0000-0000-0000-00000000000a';
const _photoOne = '10000000-0000-0000-0000-000000000001';
const _photoTwo = '10000000-0000-0000-0000-000000000002';

class _FakeStorage extends PhotoStorageService {
  _FakeStorage(this._files);

  final Map<String, Uint8List> _files;

  @override
  Future<Uint8List> readBytes(String path) async =>
      _files[path] ?? (throw StateError('no $path'));
}

void main() {
  late AppDatabase db;
  late MemoryRepository memories;
  late QuestRepository quests;
  late FakeSupabaseServer server;
  late Map<String, Uint8List> files;
  late String memoryId;
  late String sessionId;
  late String questId;
  late String shotId;

  Uint8List jpeg({int width = 64, int height = 48}) => Uint8List.fromList(
    img.encodeJpg(img.Image(width: width, height: height)),
  );

  SupabaseCloudMemoryRepository build({
    String? userId = _me,
    bool online = true,
  }) {
    return SupabaseCloudMemoryRepository(
      client: online ? server.client : null,
      memories: memories,
      quests: quests,
      images: ImageProcessingService(),
      storage: _FakeStorage(files),
      currentUserId: () => userId,
    );
  }

  Future<void> addPhoto(
    String id,
    int position, {
    String kind = PhotoKind.photo,
    String? original,
    bool mirrored = false,
  }) {
    final originalPath = original ?? '/originals/$id.jpg';
    files.putIfAbsent(originalPath, jpeg);
    files['/thumbs/$id.jpg'] = jpeg(width: 20, height: 15);
    return memories.addPhoto(
      id: id,
      memoryId: memoryId,
      shotId: shotId,
      originalPath: originalPath,
      thumbnailPath: '/thumbs/$id.jpg',
      position: position,
      width: 64,
      height: 48,
      kind: kind,
      mirrored: mirrored,
    );
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    memories = MemoryRepository(db.memoryDao);
    quests = QuestRepository(db.questDao);
    server = FakeSupabaseServer();
    files = {};

    final quest = (await quests.getQuests()).first;
    questId = quest.id;
    shotId = (await quests.getShots(questId)).first.id;
    sessionId = await memories.startQuestSession(questId);
    await memories.completeQuestSession(sessionId);
    final memory = await memories.createMemory(
      questSessionId: sessionId,
      title: 'Our day',
      note: 'A good one',
      capturedAt: DateTime.utc(2026, 9, 17),
      personIds: const [],
    );
    memoryId = memory.id;
    await addPhoto(_photoOne, 0);
    await addPhoto(_photoTwo, 1);
  });

  tearDown(() => db.close());

  group('backing up', () {
    test('saves the quest, session and memory before any file', () async {
      await build().backUpMemory(memoryId);

      final firstUpload = server.log.indexWhere((e) => e.startsWith('upload'));
      final order = server.log.sublist(0, firstUpload);
      expect(order, [
        'insert quests',
        'insert quest_shots',
        'insert quest_sessions',
        'insert memories',
      ]);
    });

    test('each photo is uploaded, then recorded, in shot order', () async {
      await build().backUpMemory(memoryId);

      final afterMemory = server.log.sublist(
        server.log.indexOf('insert memories') + 1,
      );
      expect(afterMemory.take(6), [
        'upload photos/$_me/$memoryId/$_photoOne.jpg',
        'upload photos/$_me/$memoryId/${_photoOne}_thumb.jpg',
        'insert photos',
        'upload photos/$_me/$memoryId/$_photoTwo.jpg',
        'upload photos/$_me/$memoryId/${_photoTwo}_thumb.jpg',
        'insert photos',
      ]);
      expect(server.table('photos').map((p) => p['position']), [0, 1]);
    });

    test(
      'rows are owned by the signed-in person, whatever the data says',
      () async {
        await build().backUpMemory(memoryId);

        for (final table in [
          'quests',
          'quest_shots',
          'quest_sessions',
          'memories',
          'photos',
        ]) {
          for (final row in server.table(table)) {
            expect(row['owner_id'], _me, reason: table);
          }
        }
        expect(
          server.table('photos').first['storage_path'],
          '$_me/$memoryId/$_photoOne.jpg',
        );
      },
    );

    test('uploads a compressed copy, never the original', () async {
      files['/originals/$_photoOne.jpg'] = jpeg(width: 4000, height: 3000);
      await build().backUpMemory(memoryId);

      final sent = server.uploads['photos/$_me/$memoryId/$_photoOne.jpg']!;
      expect(sent, lessThan(files['/originals/$_photoOne.jpg']!.length));

      final row = server.table('photos').first;
      expect(row['width'], 1600);
      expect(row['height'], 1200);
    });

    test('is safe to run again: nothing is uploaded twice', () async {
      final repo = build();
      await repo.backUpMemory(memoryId);
      server.log.clear();
      server.uploads.clear();

      await repo.backUpMemory(memoryId);

      expect(server.uploads, isEmpty);
      expect(server.log.where((e) => e.startsWith('insert')), isEmpty);
      expect(server.table('photos'), hasLength(2));
    });

    test('an interrupted upload resumes where it stopped', () async {
      final repo = build();
      server.failWhen = (entry) => entry.contains('$_photoTwo.jpg');

      await expectLater(
        repo.backUpMemory(memoryId),
        throwsA(isA<SharingFailure>()),
      );
      expect(server.table('photos').map((p) => p['id']), [_photoOne]);

      server.failWhen = null;
      server.log.clear();
      await repo.backUpMemory(memoryId);

      expect(server.table('photos').map((p) => p['id']), [
        _photoOne,
        _photoTwo,
      ]);
      expect(
        server.log.where((e) => e.contains(_photoOne)),
        isEmpty,
        reason: 'the first photo was not sent again',
      );
    });

    test('edits made since the last upload are picked up', () async {
      final repo = build();
      await repo.backUpMemory(memoryId);

      await db.customStatement('UPDATE memories SET title = ?', ['Renamed']);
      await repo.backUpMemory(memoryId);

      expect(server.table('memories').single['title'], 'Renamed');
      expect(server.inserts('memories'), hasLength(1));
    });

    test('titles and notes are cut to what the server allows', () async {
      await db.customStatement('UPDATE memories SET title = ?, note = ?', [
        'T' * 150,
        '   ',
      ]);
      await build().backUpMemory(memoryId);

      final row = server.table('memories').single;
      expect((row['title'] as String).length, 100);
      expect(row['note'], isNull);
    });

    test('a clip that is too big is shared as its still poster', () async {
      await db.customStatement('DELETE FROM photos');
      const clip = '20000000-0000-0000-0000-000000000003';
      files['/motion/$clip.mp4'] = Uint8List(11 * 1024 * 1024);
      await addPhoto(
        clip,
        0,
        kind: PhotoKind.video,
        original: '/motion/$clip.mp4',
        mirrored: true,
      );

      await build().backUpMemory(memoryId);

      final row = server.table('photos').single;
      expect(row['kind'], 'photo');
      expect(row['storage_path'], endsWith('$clip.jpg'));
      expect(row['mirrored'], false);
      expect(server.uploads.keys.where((k) => k.endsWith('.mp4')), isEmpty);
    });

    test('a small clip is uploaded as it is, with its mirrored flag', () async {
      await db.customStatement('DELETE FROM photos');
      const clip = '20000000-0000-0000-0000-000000000004';
      files['/motion/$clip.mp4'] = Uint8List(2048);
      await addPhoto(
        clip,
        0,
        kind: PhotoKind.video,
        original: '/motion/$clip.mp4',
        mirrored: true,
      );

      await build().backUpMemory(memoryId);

      final row = server.table('photos').single;
      expect(row['kind'], 'video');
      expect(row['storage_path'], endsWith('$clip.mp4'));
      expect(row['mirrored'], true);
      // The upload is wrapped in multipart framing, so a little bigger.
      expect(
        server.uploads['photos/$_me/$memoryId/$clip.mp4'],
        inInclusiveRange(2048, 2048 + 1024),
      );
    });

    test('progress goes from nothing to done', () async {
      final seen = <double>[];
      await build().backUpMemory(memoryId, onProgress: seen.add);

      expect(seen.last, 1);
      expect(seen, orderedEquals([...seen]..sort()));
      expect(seen.length, 3);
    });

    test('a missing memory is a friendly not-found', () async {
      await expectLater(
        build().backUpMemory('nope'),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.kind,
            'kind',
            SharingFailureKind.notFound,
          ),
        ),
      );
    });

    test('offline is explained, not raw', () async {
      server.offline = true;
      await expectLater(
        build().backUpMemory(memoryId),
        throwsA(
          isA<SharingFailure>()
              .having((f) => f.kind, 'kind', SharingFailureKind.offline)
              .having((f) => f.message, 'message', contains('connection')),
        ),
      );
    });

    test('without an account it refuses before touching the network', () async {
      await expectLater(
        build(userId: null).backUpMemory(memoryId),
        throwsA(isA<SharingFailure>()),
      );
      expect(server.log, isEmpty);
    });

    test('a build without Supabase says sharing is not set up', () async {
      await expectLater(
        build(online: false).backUpMemory(memoryId),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.kind,
            'kind',
            SharingFailureKind.notConfigured,
          ),
        ),
      );
    });
  });

  group('invites', () {
    test('backs the memory up first, then asks for a code', () async {
      server.rpcResults['create_memory_invite'] = 'ABCDE-FGHJK';

      final code = await build().createInvite(memoryId);

      expect(code, 'ABCDE-FGHJK');
      expect(
        server.log.indexOf('insert memories'),
        lessThan(server.log.indexOf('rpc create_memory_invite')),
      );
      expect(server.rpcParams['create_memory_invite'], {
        'p_memory_id': memoryId,
        'p_valid_days': 7,
        'p_max_uses': 5,
      });
    });

    test('too many live codes is explained', () async {
      server.rpcResults['create_memory_invite'] = const RpcError(
        '54000',
        'too_many_invites',
      );

      await expectLater(
        build().createInvite(memoryId),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.kind,
            'kind',
            SharingFailureKind.tooManyInvites,
          ),
        ),
      );
    });

    test('a wrong code comes back as null, not an error', () async {
      server.rpcResults['redeem_invite'] = null;
      expect(await build().redeemInvite('ZZZZZ-ZZZZZ'), isNull);
    });

    test('a memory code gives the memory id', () async {
      server.rpcResults['redeem_invite'] = {'kind': 'memory', 'id': memoryId};
      final target = await build().redeemInvite('ABCDE-FGHJK');
      expect(target?.kind, InviteKind.memory);
      expect(target?.id, memoryId);
      expect(server.rpcParams['redeem_invite'], {'p_code': 'ABCDE-FGHJK'});
    });

    test('a quest code says it is for a quest', () async {
      server.rpcResults['redeem_invite'] = {'kind': 'quest', 'id': 'q1'};
      final target = await build().redeemInvite('ABCDE-FGHJK');
      expect(target?.kind, InviteKind.quest);
      expect(target?.id, 'q1');
    });

    test('a full quest says so', () async {
      server.rpcResults['redeem_invite'] = const RpcError(
        '53400',
        'quest_full',
      );

      await expectLater(
        build().redeemInvite('ABCDE-FGHJK'),
        throwsA(
          isA<SharingFailure>()
              .having((f) => f.kind, 'kind', SharingFailureKind.questFull)
              .having((f) => f.message, 'message', contains('full')),
        ),
      );
    });

    test('guessing too often asks the person to wait', () async {
      server.rpcResults['redeem_invite'] = const RpcError(
        '54000',
        'too_many_attempts',
      );

      await expectLater(
        build().redeemInvite('ZZZZZ-ZZZZZ'),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.kind,
            'kind',
            SharingFailureKind.tooManyTries,
          ),
        ),
      );
    });
  });

  group('seeing what friends shared', () {
    void seedShare() {
      server.table('memory_shares').add({
        'memory_id': 'm1',
        'owner_id': 'owner-1',
        'viewer_id': _me,
        'created_at': '2026-10-01T00:00:00Z',
      });
      server.table('memories').add({
        'id': 'm1',
        'owner_id': 'owner-1',
        'title': 'Beach day',
        'note': 'Sunny',
        'captured_at': '2026-09-20T10:00:00Z',
      });
      server.table('profiles').add({
        'id': 'owner-1',
        'display_name': 'Sam',
        'avatar_path': 'owner-1/avatar.jpg',
      });
      server.table('photos')
        ..add({
          'id': 'p2',
          'uploaded_by': 'owner-1',
          'memory_id': 'm1',
          'position': 1,
          'kind': 'gif',
          'storage_path': 'owner-1/m1/p2.gif',
          'thumbnail_path': 'owner-1/m1/p2_thumb.jpg',
          'width': 10,
          'height': 10,
          'mirrored': false,
        })
        ..add({
          'id': 'p1',
          'uploaded_by': 'owner-1',
          'memory_id': 'm1',
          'position': 0,
          'kind': 'photo',
          'storage_path': 'owner-1/m1/p1.jpg',
          'thumbnail_path': 'owner-1/m1/p1_thumb.jpg',
          'width': 10,
          'height': 10,
          'mirrored': false,
        })
        ..add({
          'id': 'p3',
          'uploaded_by': 'friend-1',
          'memory_id': 'm1',
          'position': 2,
          'kind': 'photo',
          'storage_path': 'friend-1/m1/p3.jpg',
          'thumbnail_path': 'friend-1/m1/p3_thumb.jpg',
          'width': 10,
          'height': 10,
          'mirrored': false,
        });
      server.table('profiles').add({
        'id': 'friend-1',
        'display_name': 'Bo',
        'avatar_path': null,
      });
    }

    test(
      'the list shows who shared it and a cover from the first photo',
      () async {
        seedShare();

        final list = await build().getSharedWithMe();

        expect(list, hasLength(1));
        expect(list.single.title, 'Beach day');
        expect(list.single.ownerName, 'Sam');
        expect(list.single.coverUrl, contains('owner-1/m1/p1_thumb.jpg'));
      },
    );

    test('nothing shared is an empty list', () async {
      expect(await build().getSharedWithMe(), isEmpty);
    });

    test('opening one gives its photos in order with signed links', () async {
      seedShare();

      final detail = await build().getSharedMemory('m1');

      expect(detail.title, 'Beach day');
      expect(detail.ownerName, 'Sam');
      expect(detail.ownerAvatarUrl, contains('owner-1/avatar.jpg'));
      expect(detail.photos.map((p) => p.id), ['p1', 'p2', 'p3']);
      expect(detail.photos[1].kind, 'gif');
      expect(detail.photos.first.url, contains('token='));
      expect(detail.photos.first.previewUrl, contains('p1_thumb.jpg'));
    });

    test('photos a friend added say who added them', () async {
      seedShare();

      final detail = await build().getSharedMemory('m1');

      expect(detail.photos.map((p) => p.addedByName), [null, null, 'Bo']);
    });

    test(
      'a friend on the quest can add photos, a code viewer cannot',
      () async {
        seedShare();
        final repo = build();

        // A memory from a quest I can read the session of: I'm taking part.
        server.table('memories').single['quest_session_id'] = 's1';
        server.table('quest_sessions').add({'id': 's1'});
        expect((await repo.getSharedMemory('m1')).canAddPhotos, isTrue);

        // No session I can read: I only have a memory code.
        server.table('quest_sessions').clear();
        expect((await repo.getSharedMemory('m1')).canAddPhotos, isFalse);
      },
    );

    test('a memory that is no longer shared is a friendly not-found', () async {
      await expectLater(
        build().getSharedMemory('gone'),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.kind,
            'kind',
            SharingFailureKind.notFound,
          ),
        ),
      );
    });

    test('leaving removes only my own share', () async {
      seedShare();
      server.table('memory_shares').add({
        'memory_id': 'm1',
        'owner_id': 'owner-1',
        'viewer_id': 'someone-else',
        'created_at': '2026-10-02T00:00:00Z',
      });

      await build().leaveSharedMemory('m1');

      expect(server.table('memory_shares').map((s) => s['viewer_id']), [
        'someone-else',
      ]);
    });
  });

  group('my own memories', () {
    test('lists who can see one, and can remove them', () async {
      server.table('memory_shares')
        ..add({
          'memory_id': memoryId,
          'owner_id': _me,
          'viewer_id': 'friend-1',
          'created_at': '2026-10-01T00:00:00Z',
        })
        ..add({
          'memory_id': memoryId,
          'owner_id': _me,
          'viewer_id': 'friend-2',
          'created_at': '2026-10-02T00:00:00Z',
        });
      server.table('profiles')
        ..add({'id': 'friend-1', 'display_name': 'Bo', 'avatar_path': null})
        ..add({'id': 'friend-2', 'display_name': '', 'avatar_path': null});

      final repo = build();
      final viewers = await repo.getViewers(memoryId);
      expect(viewers.map((v) => v.name), ['Bo', 'A friend']);

      await repo.removeViewer(memoryId, 'friend-1');
      expect((await repo.getViewers(memoryId)).map((v) => v.id), ['friend-2']);
    });

    test('no viewers is an empty list', () async {
      expect(await build().getViewers(memoryId), isEmpty);
    });
  });

  group('adding a friend\'s own photos', () {
    void seedFriendsMemory() {
      server.table('memories').add({
        'id': 'm1',
        'owner_id': 'owner-1',
        'title': 'Family day',
        'captured_at': '2026-09-20T10:00:00Z',
      });
      server.table('photos').add({
        'id': 'existing',
        'memory_id': 'm1',
        'position': 3,
      });
    }

    test(
      'uploads compressed copies and records them as the friend\'s',
      () async {
        seedFriendsMemory();
        final big = jpeg(width: 4000, height: 3000);

        await build().addPhotosToMemory('m1', [big, jpeg()]);

        final rows = server.table('photos').skip(1).toList();
        expect(rows, hasLength(2));
        for (final row in rows) {
          expect(row['uploaded_by'], _me);
          expect(
            row['owner_id'],
            'owner-1',
            reason: 'the memory\'s real owner',
          );
          expect(row['storage_path'], startsWith('$_me/m1/'));
          expect(row['thumbnail_path'], endsWith('_thumb.jpg'));
          expect(row['kind'], 'photo');
        }
        expect(rows.map((r) => r['position']), [
          4,
          5,
        ], reason: 'after the last');
        expect(rows.first['width'], 1600);
        expect(
          server.uploads['photos/${rows.first['storage_path']}']!,
          lessThan(big.length),
        );
      },
    );

    test('each file is uploaded before its record', () async {
      seedFriendsMemory();
      await build().addPhotosToMemory('m1', [jpeg()]);

      final order = server.log.where(
        (e) => e.startsWith('upload') || e == 'insert photos',
      );
      expect(order.map((e) => e.split(' ').first), [
        'upload',
        'upload',
        'insert',
      ]);
    });

    test('reports progress and handles no photos', () async {
      seedFriendsMemory();
      final seen = <double>[];
      await build().addPhotosToMemory('m1', [
        jpeg(),
        jpeg(),
      ], onProgress: seen.add);
      expect(seen, [0.5, 1.0]);

      await build().addPhotosToMemory('m1', const []);
      expect(server.table('photos'), hasLength(3));
    });

    test('a memory that is gone is a friendly not-found', () async {
      await expectLater(
        build().addPhotosToMemory('nope', [jpeg()]),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.kind,
            'kind',
            SharingFailureKind.notFound,
          ),
        ),
      );
      expect(server.uploads, isEmpty);
    });

    test(
      'a full allowance is explained, not shown as a server error',
      () async {
        seedFriendsMemory();
        server
          ..failStatus = 403
          ..failWhen = ((entry) => entry.startsWith('upload'))
          ..rpcResults['my_storage_usage'] = [
            {'used_bytes': 104857600, 'quota_bytes': 104857600},
          ];

        await expectLater(
          build().addPhotosToMemory('m1', [jpeg()]),
          throwsA(
            isA<SharingFailure>()
                .having((f) => f.kind, 'kind', SharingFailureKind.storageFull)
                .having(
                  (f) => f.message,
                  'message',
                  contains('storage is full'),
                ),
          ),
        );
        expect(
          server.table('photos'),
          hasLength(1),
          reason: 'nothing recorded',
        );
      },
    );

    test('a refused upload with room left is a generic failure', () async {
      seedFriendsMemory();
      server
        ..failStatus = 403
        ..failWhen = ((entry) => entry.startsWith('upload'))
        ..rpcResults['my_storage_usage'] = [
          {'used_bytes': 1000, 'quota_bytes': 104857600},
        ];

      await expectLater(
        build().addPhotosToMemory('m1', [jpeg()]),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.kind,
            'kind',
            SharingFailureKind.unknown,
          ),
        ),
      );
    });
  });

  group('storage and removing an online copy', () {
    test('reads the allowance', () async {
      server.rpcResults['my_storage_usage'] = [
        {'used_bytes': 12582912, 'quota_bytes': 104857600},
      ];

      final usage = await build().getStorageUsage();

      expect(usage.usedBytes, 12582912);
      expect(usage.quotaBytes, 104857600);
      expect(usage.isFull, isFalse);
      expect(usage.label, '12 MB of 100 MB used');
      expect(usage.fraction, closeTo(0.12, 0.001));
    });

    test('knows whether a memory is online', () async {
      final repo = build();
      expect(await repo.isOnline(memoryId), isFalse);

      await repo.backUpMemory(memoryId);

      expect(await repo.isOnline(memoryId), isTrue);
    });

    test('removes files first (friends\' too), then the memory', () async {
      server.table('memories').add({'id': 'm1', 'owner_id': _me});
      server.table('photos')
        ..add({
          'id': 'a',
          'memory_id': 'm1',
          'storage_path': '$_me/m1/a.jpg',
          'thumbnail_path': '$_me/m1/a_thumb.jpg',
        })
        ..add({
          'id': 'f',
          'memory_id': 'm1',
          'storage_path': 'friend-1/m1/f.jpg',
          'thumbnail_path': 'friend-1/m1/f_thumb.jpg',
        });
      server.uploads
        ..['photos/$_me/m1/a.jpg'] = 10
        ..['photos/$_me/m1/a_thumb.jpg'] = 10
        ..['photos/$_me/m1/orphan.jpg'] = 10
        ..['photos/friend-1/m1/f.jpg'] = 10
        ..['photos/friend-1/m1/f_thumb.jpg'] = 10
        ..['photos/$_me/other-memory/keep.jpg'] = 10;

      await build().removeOnlineCopy('m1');

      expect(server.uploads.keys, ['photos/$_me/other-memory/keep.jpg']);
      expect(server.table('memories'), isEmpty);
      final lastRemove = server.log.lastIndexWhere(
        (e) => e.startsWith('remove'),
      );
      expect(lastRemove, lessThan(server.log.indexOf('delete memories')));
    });

    test('removing one memory leaves the others online', () async {
      server.table('memories')
        ..add({'id': 'm1', 'owner_id': _me})
        ..add({'id': 'm2', 'owner_id': _me});

      await build().removeOnlineCopy('m1');

      expect(server.table('memories').map((m) => m['id']), ['m2']);
    });

    test('offline is explained', () async {
      server.offline = true;
      await expectLater(
        build().removeOnlineCopy('m1'),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.kind,
            'kind',
            SharingFailureKind.offline,
          ),
        ),
      );
    });
  });
}
