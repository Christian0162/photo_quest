import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/repositories/cloud_friends_repository.dart';
import 'package:photoquest/core/data/repositories/cloud_memory_repository.dart';
import 'package:photoquest/core/data/repositories/cloud_quest_repository.dart';
import 'package:photoquest/core/data/repositories/memory_repository.dart';
import 'package:photoquest/core/data/repositories/quest_repository.dart';
import 'package:photoquest/core/data/services/image/image_processing_service.dart';
import 'package:photoquest/core/data/services/storage/photo_storage_service.dart';
import 'package:photoquest/core/errors/app_failure.dart';

import '../support/fake_supabase_server.dart';

const _me = 'a0000000-0000-0000-0000-00000000000a';

Matcher _failure(SharingFailureKind kind) =>
    throwsA(isA<SharingFailure>().having((f) => f.kind, 'kind', kind));

void main() {
  late FakeSupabaseServer server;
  late SupabaseCloudFriendsRepository friends;

  setUp(() {
    server = FakeSupabaseServer();
    friends = SupabaseCloudFriendsRepository(
      client: server.client,
      currentUserId: () => _me,
    );
  });

  group('my friend code', () {
    test('is read from the server', () async {
      server.rpcResults['my_friend_code'] = 'ABCDEFGHJK';
      expect(await friends.getMyFriendCode(), 'ABCDEFGHJK');
    });

    test('can be replaced', () async {
      server.rpcResults['reset_friend_code'] = 'MNPQRSTVWX';
      expect(await friends.resetFriendCode(), 'MNPQRSTVWX');
      expect(server.log, ['rpc reset_friend_code']);
    });

    test('offline is explained', () async {
      server.offline = true;
      await expectLater(
        friends.getMyFriendCode(),
        _failure(SharingFailureKind.offline),
      );
    });
  });

  group('adding someone by their code', () {
    test(
      'a code that works sends a request and names who it was for',
      () async {
        server.rpcResults['request_friend'] = {
          'user_id': 'bo',
          'name': 'Bo',
          'status': 'pending',
        };

        final result = await friends.addByCode('ABCDEFGHJK');

        expect(result?.userId, 'bo');
        expect(result?.name, 'Bo');
        expect(result?.accepted, isFalse);
        expect(server.rpcParams['request_friend'], {'p_code': 'ABCDEFGHJK'});
      },
    );

    test('someone who had already asked you means you are friends', () async {
      server.rpcResults['request_friend'] = {
        'user_id': 'bo',
        'name': 'Bo',
        'status': 'accepted',
      };

      expect((await friends.addByCode('ABCDEFGHJK'))?.accepted, isTrue);
    });

    test('a name that is missing becomes "A friend"', () async {
      server.rpcResults['request_friend'] = {
        'user_id': 'bo',
        'name': null,
        'status': 'pending',
      };

      expect((await friends.addByCode('ABCDEFGHJK'))?.name, 'A friend');
    });

    test('a wrong code is null, not an error', () async {
      server.rpcResults['request_friend'] = null;
      expect(await friends.addByCode('ZZZZZZZZZZ'), isNull);
    });

    test('guessing too often asks the person to wait', () async {
      server.rpcResults['request_friend'] = const RpcError(
        '54000',
        'too_many_attempts',
      );

      await expectLater(
        friends.addByCode('ZZZZZZZZZZ'),
        _failure(SharingFailureKind.tooManyTries),
      );
    });
  });

  group('the friends list', () {
    void seed() {
      server.table('friendships')
        ..add({
          'requester_id': 'bo',
          'addressee_id': _me,
          'status': 'pending',
          'created_at': '2026-10-03T00:00:00Z',
        })
        ..add({
          'requester_id': _me,
          'addressee_id': 'cass',
          'status': 'accepted',
          'created_at': '2026-10-02T00:00:00Z',
        })
        ..add({
          'requester_id': 'dee',
          'addressee_id': _me,
          'status': 'accepted',
          'created_at': '2026-10-01T00:00:00Z',
        })
        ..add({
          'requester_id': _me,
          'addressee_id': 'eli',
          'status': 'pending',
          'created_at': '2026-09-30T00:00:00Z',
        })
        ..add({
          'requester_id': 'fay',
          'addressee_id': _me,
          'status': 'declined',
          'created_at': '2026-09-29T00:00:00Z',
        });
      server.table('profiles')
        ..add({'id': 'bo', 'display_name': 'Bo', 'avatar_path': null})
        ..add({
          'id': 'cass',
          'display_name': 'Cass',
          'avatar_path': 'cass/a.jpg',
        })
        ..add({'id': 'dee', 'display_name': 'Dee', 'avatar_path': null})
        ..add({'id': 'eli', 'display_name': '', 'avatar_path': null})
        ..add({'id': 'fay', 'display_name': 'Fay', 'avatar_path': null});
    }

    test(
      'tells friends, requests to answer, and requests waiting apart',
      () async {
        seed();

        final list = await friends.getFriends();

        expect(list.map((f) => '${f.name}: ${f.status.name}'), [
          'Bo: requestedMe',
          'Cass: friend',
          'Dee: friend',
          'A friend: requestedByMe',
        ]);
      },
    );

    test('a request I declined is not shown', () async {
      seed();
      final list = await friends.getFriends();
      expect(list.any((f) => f.name == 'Fay'), isFalse);
    });

    test('friends get a signed link to their photo', () async {
      seed();
      final list = await friends.getFriends();
      expect(list[1].avatarUrl, contains('cass/a.jpg'));
      expect(list[0].avatarUrl, isNull);
    });

    test('nobody yet is an empty list', () async {
      expect(await friends.getFriends(), isEmpty);
    });
  });

  group('answering and removing', () {
    test('answers go to the server', () async {
      await friends.respond('bo', accept: true);
      await friends.respond('bo', accept: false);

      expect(server.rpcParams['respond_to_friend_request'], {
        'p_user': 'bo',
        'p_accept': false,
      });
      expect(server.log.where((e) => e.startsWith('rpc')), hasLength(2));
    });

    test('a request that is no longer open is explained', () async {
      server.rpcResults['respond_to_friend_request'] = const RpcError(
        '55000',
        'request_not_pending',
      );

      await expectLater(
        friends.respond('bo', accept: true),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.message,
            'message',
            contains('no longer open'),
          ),
        ),
      );
    });

    test('removing a friend deletes only that friendship', () async {
      server.table('friendships')
        ..add({'id': '1', 'requester_id': _me, 'addressee_id': 'bo'})
        ..add({'id': '2', 'requester_id': 'cass', 'addressee_id': _me})
        ..add({'id': '3', 'requester_id': 'bo', 'addressee_id': 'cass'});

      await friends.remove('bo');

      expect(server.table('friendships').map((f) => f['id']), ['2', '3']);
    });

    test('removing someone who is not a friend does nothing', () async {
      server.table('friendships').add({
        'id': '1',
        'requester_id': _me,
        'addressee_id': 'bo',
      });

      await friends.remove('stranger');

      expect(server.table('friendships'), hasLength(1));
    });
  });

  group('inviting a friend straight to something', () {
    late AppDatabase db;
    late MemoryRepository memories;
    late QuestRepository quests;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      memories = MemoryRepository(db.memoryDao);
      quests = QuestRepository(db.questDao);
    });

    tearDown(() => db.close());

    test('a quest is put online first, then the friend is invited', () async {
      final questId = (await quests.getQuests()).first.id;
      final repo = SupabaseCloudQuestRepository(
        client: server.client,
        quests: quests,
        currentUserId: () => _me,
      );

      await repo.inviteFriend(questId, 'bo');

      expect(server.log, [
        'insert quests',
        'insert quest_shots',
        'rpc invite_friend_to_quest',
      ]);
      expect(server.rpcParams['invite_friend_to_quest'], {
        'p_quest': questId,
        'p_friend': 'bo',
      });
    });

    test('a quest that no longer exists is a friendly not-found', () async {
      final repo = SupabaseCloudQuestRepository(
        client: server.client,
        quests: quests,
        currentUserId: () => _me,
      );

      await expectLater(
        repo.inviteFriend('gone', 'bo'),
        _failure(SharingFailureKind.notFound),
      );
    });

    test('a memory is put online first, then shared with the friend', () async {
      final quest = (await quests.getQuests()).first;
      final session = await memories.startQuestSession(quest.id);
      final memory = await memories.createMemory(
        questSessionId: session,
        title: 'Our day',
        capturedAt: DateTime(2026, 9, 17),
        personIds: const [],
      );
      final repo = SupabaseCloudMemoryRepository(
        client: server.client,
        memories: memories,
        quests: quests,
        images: ImageProcessingService(),
        storage: PhotoStorageService(),
        currentUserId: () => _me,
      );

      await repo.shareWithFriend(memory.id, 'bo');

      expect(
        server.log.indexOf('insert memories'),
        lessThan(server.log.indexOf('rpc share_memory_with_friend')),
      );
      expect(server.rpcParams['share_memory_with_friend'], {
        'p_memory': memory.id,
        'p_friend': 'bo',
      });
    });

    test('someone who is not (or no longer) a friend is explained', () async {
      server.rpcResults['invite_friend_to_quest'] = const RpcError(
        '42501',
        'not_friends',
      );
      final repo = SupabaseCloudQuestRepository(
        client: server.client,
        quests: quests,
        currentUserId: () => _me,
      );
      final questId = (await quests.getQuests()).first.id;

      await expectLater(
        repo.inviteFriend(questId, 'bo'),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.message,
            'message',
            contains("not friends with them yet"),
          ),
        ),
      );
    });

    test('a full quest turns a friend away too', () async {
      server.rpcResults['invite_friend_to_quest'] = const RpcError(
        '53400',
        'quest_full',
      );
      final repo = SupabaseCloudQuestRepository(
        client: server.client,
        quests: quests,
        currentUserId: () => _me,
      );
      final questId = (await quests.getQuests()).first.id;

      await expectLater(
        repo.inviteFriend(questId, 'bo'),
        _failure(SharingFailureKind.questFull),
      );
    });
  });
}
