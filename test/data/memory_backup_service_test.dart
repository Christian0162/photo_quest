import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/data/database/app_database.dart';
import 'package:photoquest/core/data/repositories/memory_repository.dart';
import 'package:photoquest/core/data/repositories/settings_repository.dart';
import 'package:photoquest/core/data/services/backup/memory_backup_service.dart';
import 'package:photoquest/core/errors/app_failure.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_cloud_memory_repository.dart';

void main() {
  late AppDatabase db;
  late MemoryRepository memories;
  late SettingsRepository settings;
  late FakeCloudMemoryRepository cloud;
  late FakeConnectivityService connectivity;
  late FakeAuthRepository auth;
  late MemoryBackupService service;
  late List<String> ids; // oldest first

  Future<String> addMemory(DateTime capturedAt) async {
    final quest = (await db.questDao.getAllQuests()).first;
    final session = await memories.startQuestSession(quest.id);
    final memory = await memories.createMemory(
      questSessionId: session,
      title: 'Memory ${capturedAt.day}',
      capturedAt: capturedAt,
      personIds: const [],
    );
    return memory.id;
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    memories = MemoryRepository(db.memoryDao);
    settings = SettingsRepository(db.settingsDao);
    cloud = FakeCloudMemoryRepository();
    connectivity = FakeConnectivityService();
    auth = FakeAuthRepository(signedIn: true);
    service = MemoryBackupService(
      memories: memories,
      cloud: cloud,
      settings: settings,
      connectivity: connectivity,
      auth: auth,
    );
    ids = [
      await addMemory(DateTime(2026, 9, 1)),
      await addMemory(DateTime(2026, 9, 2)),
      await addMemory(DateTime(2026, 9, 3)),
    ];
  });

  tearDown(() => db.close());

  List<String> backedUp() => [
    for (final call in cloud.calls)
      if (call.startsWith('backUp:')) call.substring(7),
  ];

  group('the setting', () {
    test('is off until the person turns it on, and remembers', () async {
      expect(await settings.getBackupEnabled('me'), isFalse);

      await settings.setBackupEnabled('me', enabled: true);
      expect(await settings.getBackupEnabled('me'), isTrue);

      await settings.setBackupEnabled('me', enabled: false);
      expect(await settings.getBackupEnabled('me'), isFalse);
    });
  });

  group('backing everything up', () {
    test('goes newest first and counts them', () async {
      final progress = <(int, int)>[];

      final outcome = await service.backUpAll(
        onProgress: (done, total) => progress.add((done, total)),
      );

      expect(backedUp(), [ids[2], ids[1], ids[0]]);
      expect(outcome.total, 3);
      expect(outcome.backedUp, 3);
      expect(outcome.complete, isTrue);
      expect(progress, [(0, 3), (1, 3), (2, 3), (3, 3)]);
    });

    test('stops the moment storage is full', () async {
      cloud.failuresByMemory[ids[1]] = const SharingFailure(
        SharingFailureKind.storageFull,
        'Your online storage is full.',
      );

      final outcome = await service.backUpAll();

      expect(backedUp(), [ids[2], ids[1]], reason: 'the oldest is never tried');
      expect(outcome.storageFull, isTrue);
      expect(outcome.backedUp, 1);
      expect(outcome.complete, isFalse);
    });

    test('stops when the network is gone', () async {
      cloud.failuresByMemory[ids[2]] = const SharingFailure(
        SharingFailureKind.offline,
        'No connection.',
      );

      final outcome = await service.backUpAll();

      expect(backedUp(), [ids[2]]);
      expect(outcome.stopped?.kind, SharingFailureKind.offline);
    });

    test('carries on past a memory that can\'t be saved', () async {
      cloud.failuresByMemory[ids[1]] = const SharingFailure.unknown();

      final outcome = await service.backUpAll();

      expect(backedUp(), [ids[2], ids[1], ids[0]]);
      expect(outcome.backedUp, 2);
      expect(outcome.failed, 1);
      expect(outcome.stopped, isNull);
      expect(outcome.complete, isFalse);
    });

    test('two runs at once do not trample each other', () async {
      final first = service.backUpAll();
      final second = await service.backUpAll();

      expect(second.total, 0);
      await first;
      expect(backedUp(), hasLength(3));
    });

    test('with nothing to back up it is simply done', () async {
      await db.customStatement('DELETE FROM memories');

      final outcome = await service.backUpAll();

      expect(outcome.total, 0);
      expect(outcome.complete, isTrue);
      expect(backedUp(), isEmpty);
    });
  });

  group('by itself, after a memory is saved', () {
    test('does nothing while the setting is off', () async {
      await service.memorySaved(ids.first);
      expect(cloud.calls, isEmpty);
    });

    test('saves that memory when it is on, on Wi-Fi, signed in', () async {
      await settings.setBackupEnabled('me', enabled: true);

      await service.memorySaved(ids.first);

      expect(backedUp(), [ids.first]);
    });

    test('saves a shared quest\'s memory even with backup off', () async {
      cloud.fromSharedQuest.add(ids.first);

      await service.memorySaved(ids.first);
      await service.memorySaved(ids.last);

      expect(backedUp(), [ids.first]);
    });

    test('shared quest memories still wait for Wi-Fi', () async {
      cloud.fromSharedQuest.add(ids.first);
      connectivity.wifi = false;

      await service.memorySaved(ids.first);

      expect(cloud.calls, isEmpty);
    });

    test('waits for Wi-Fi rather than using mobile data', () async {
      await settings.setBackupEnabled('me', enabled: true);
      connectivity.wifi = false;

      await service.memorySaved(ids.first);

      expect(cloud.calls, isEmpty);
    });

    test('does nothing when nobody is signed in', () async {
      await settings.setBackupEnabled('me', enabled: true);
      final signedOut = MemoryBackupService(
        memories: memories,
        cloud: cloud,
        settings: settings,
        connectivity: connectivity,
        auth: FakeAuthRepository(),
      );

      await signedOut.memorySaved(ids.first);

      expect(cloud.calls, isEmpty);
    });

    test('a failure is ignored: the memory is safe on the phone', () async {
      await settings.setBackupEnabled('me', enabled: true);
      cloud.failNext = const SharingFailure.unknown();

      await expectLater(service.memorySaved(ids.first), completes);
    });
  });

  group('when the app opens', () {
    test(
      'catches up everything missing, if backup is on and on Wi-Fi',
      () async {
        await settings.setBackupEnabled('me', enabled: true);

        await service.catchUp();

        expect(backedUp(), hasLength(3));
      },
    );

    test('with backup off, only catches up shared quests', () async {
      cloud.fromSharedQuest.add(ids[1]);

      await service.catchUp();

      expect(backedUp(), [ids[1]]);
    });

    test('leaves alone a memory whose online copy was removed', () async {
      cloud.fromSharedQuest.addAll([ids[0], ids[1]]);
      await settings.setMemoryWithheld(ids[1], withheld: true);

      await service.catchUp();
      expect(backedUp(), [ids[0]]);

      await settings.setMemoryWithheld(ids[1], withheld: false);
      cloud.calls.clear();
      await service.catchUp();
      expect(backedUp(), containsAll([ids[0], ids[1]]));
    });

    test('does nothing when off, or on mobile data', () async {
      await service.catchUp();
      expect(cloud.calls, isEmpty);

      await settings.setBackupEnabled('me', enabled: true);
      connectivity.wifi = false;
      await service.catchUp();
      expect(cloud.calls, isEmpty);
    });
  });

  group('consent belongs to one account', () {
    test('another account starts with backup off', () async {
      await settings.setBackupEnabled('me', enabled: true);

      expect(await settings.getBackupEnabled('someone-else'), isFalse);
    });
  });
}
