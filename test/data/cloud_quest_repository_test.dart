import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/repositories/cloud_quest_repository.dart';
import 'package:photoquest/core/data/repositories/quest_repository.dart';
import 'package:photoquest/core/data/repositories/quest_uploader.dart';
import 'package:photoquest/core/domain/quests/entities/quest.dart';
import 'package:photoquest/core/domain/sharing/entities/shared_quest.dart';
import 'package:photoquest/core/errors/app_failure.dart';

import '../support/fake_supabase_server.dart';

const _me = 'b0000000-0000-0000-0000-00000000000b';
const _owner = 'a0000000-0000-0000-0000-00000000000a';

Matcher _failure(SharingFailureKind kind) =>
    throwsA(isA<SharingFailure>().having((f) => f.kind, 'kind', kind));

void main() {
  late AppDatabase db;
  late QuestRepository quests;
  late FakeSupabaseServer server;
  late String questId;

  SupabaseCloudQuestRepository build({String? userId = _me}) =>
      SupabaseCloudQuestRepository(
        client: server.client,
        quests: quests,
        currentUserId: () => userId,
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    quests = QuestRepository(db.questDao);
    server = FakeSupabaseServer();
    questId = (await quests.getQuests()).first.id;
  });

  tearDown(() => db.close());

  group('how many people a quest holds', () {
    Quest quest(String type, {int? max}) => Quest(
      id: 'q',
      title: 'q',
      category: 'c',
      type: type,
      maxParticipants: max,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    test('a solo quest has room for nobody else', () {
      expect(QuestUploader.participantLimit(quest('solo')), isNull);
    });

    test('a pair holds two', () {
      expect(QuestUploader.participantLimit(quest('pair')), 2);
      expect(QuestUploader.participantLimit(quest('pair', max: 9)), 2);
    });

    test('a group holds the usual group size unless chosen', () {
      expect(QuestUploader.participantLimit(quest('group')), 5);
      expect(QuestUploader.participantLimit(quest('group', max: 4)), 4);
    });

    test('a group is kept between two and twenty', () {
      expect(QuestUploader.participantLimit(quest('group', max: 1)), 2);
      expect(QuestUploader.participantLimit(quest('group', max: 99)), 20);
    });
  });

  group('inviting friends to a quest', () {
    test('puts the quest and its shots online, then asks for a code', () async {
      server.rpcResults['create_quest_invite'] = 'QUEST-CODE1';

      final code = await build().createInvite(questId);

      expect(code, 'QUEST-CODE1');
      expect(server.log, [
        'insert quests',
        'insert quest_shots',
        'rpc create_quest_invite',
      ]);
      final row = server.table('quests').single;
      expect(row['id'], questId);
      expect(row['owner_id'], _me);
      expect(
        row['max_participants'],
        QuestUploader.participantLimit((await quests.getQuest(questId))!),
      );
      expect(
        row['max_participants'],
        isNotNull,
        reason: 'a shared quest has a size',
      );
      expect(server.table('quest_shots'), isNotEmpty);
      expect(
        server.table('quest_shots').every((shot) => shot['owner_id'] == _me),
        isTrue,
      );
      expect(server.rpcParams['create_quest_invite'], {
        'p_quest_id': questId,
        'p_valid_days': 7,
        'p_max_uses': 5,
      });
    });

    test('inviting again does not upload the quest twice', () async {
      server.rpcResults['create_quest_invite'] = 'QUEST-CODE1';
      final repo = build();
      await repo.createInvite(questId);
      server.log.clear();

      await repo.createInvite(questId);

      expect(server.log, ['rpc create_quest_invite']);
      expect(server.table('quests'), hasLength(1));
    });

    test('a quest you do alone cannot be shared, and it says why', () async {
      server.rpcResults['create_quest_invite'] = const RpcError(
        '22023',
        'quest_not_shareable',
      );

      await expectLater(
        build().createInvite(questId),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.message,
            'message',
            contains('on your own'),
          ),
        ),
      );
    });

    test('a quest that no longer exists is a friendly not-found', () async {
      await expectLater(
        build().createInvite('gone'),
        _failure(SharingFailureKind.notFound),
      );
      expect(server.log, isEmpty);
    });

    test('offline is explained', () async {
      server.offline = true;
      await expectLater(
        build().createInvite(questId),
        _failure(SharingFailureKind.offline),
      );
    });
  });

  group('seeing my quests', () {
    void seed() {
      server.table('quest_participants')
        ..add({
          'quest_id': 'q1',
          'user_id': _me,
          'status': 'invited',
          'invited_at': '2026-10-02T00:00:00Z',
        })
        ..add({
          'quest_id': 'q2',
          'user_id': _me,
          'status': 'accepted',
          'invited_at': '2026-10-01T00:00:00Z',
        })
        ..add({
          'quest_id': 'q3',
          'user_id': _me,
          'status': 'declined',
          'invited_at': '2026-09-30T00:00:00Z',
        });
      server.table('quests')
        ..add({
          'id': 'q1',
          'owner_id': _owner,
          'title': 'Date night',
          'description': 'Dinner and a photo',
        })
        ..add({'id': 'q2', 'owner_id': _owner, 'title': 'Family day'})
        ..add({'id': 'q3', 'owner_id': _owner, 'title': 'Old one'});
      server.table('profiles').add({
        'id': _owner,
        'display_name': 'Sam',
        'avatar_path': null,
      });
    }

    test(
      'lists invitations and joined quests, newest first, not declined',
      () async {
        seed();

        final list = await build().getMyQuests();

        expect(list.map((q) => q.id), ['q1', 'q2']);
        expect(list.first.status, ParticipationStatus.invited);
        expect(list.first.ownerName, 'Sam');
        expect(list.first.description, 'Dinner and a photo');
        expect(list.last.status, ParticipationStatus.accepted);
      },
    );

    test('no quests is an empty list', () async {
      expect(await build().getMyQuests(), isEmpty);
    });

    test('someone else\'s rows are never mine', () async {
      seed();
      server.table('quest_participants').add({
        'quest_id': 'q9',
        'user_id': 'someone-else',
        'status': 'accepted',
        'invited_at': '2026-10-03T00:00:00Z',
      });

      expect((await build().getMyQuests()).map((q) => q.id), ['q1', 'q2']);
    });
  });

  group('opening a quest', () {
    void seed({required String status}) {
      server.table('quests').add({
        'id': 'q1',
        'owner_id': _owner,
        'title': 'Family day',
        'description': 'Everyone squeezes in',
      });
      server.table('profiles')
        ..add({'id': _owner, 'display_name': 'Sam', 'avatar_path': null})
        ..add({'id': 'friend-1', 'display_name': 'Cass', 'avatar_path': null})
        ..add({'id': 'friend-2', 'display_name': '', 'avatar_path': null});
      server.table('quest_participants')
        ..add({
          'quest_id': 'q1',
          'owner_id': _owner,
          'user_id': _me,
          'status': status,
          'invited_at': '2026-10-01T00:00:00Z',
        })
        ..add({
          'quest_id': 'q1',
          'owner_id': _owner,
          'user_id': 'friend-1',
          'status': 'accepted',
          'invited_at': '2026-10-02T00:00:00Z',
        })
        ..add({
          'quest_id': 'q1',
          'owner_id': _owner,
          'user_id': 'friend-2',
          'status': 'invited',
          'invited_at': '2026-10-03T00:00:00Z',
        });
      server.table('quest_shots')
        ..add({'quest_id': 'q1', 'position': 1, 'instruction': 'Squeeze in'})
        ..add({'quest_id': 'q1', 'position': 0, 'instruction': 'Say cheese'});
      server.table('quest_sessions').add({'id': 's1', 'quest_id': 'q1'});
      server.table('memories').add({
        'id': 'm1',
        'owner_id': _owner,
        'quest_session_id': 's1',
        'title': 'Family day',
        'captured_at': '2026-10-04T10:00:00Z',
      });
    }

    test(
      'an invitation shows the quest and who is in, but no memories',
      () async {
        seed(status: 'invited');

        final detail = await build().getQuest('q1');

        expect(detail.status, ParticipationStatus.invited);
        expect(detail.title, 'Family day');
        expect(detail.ownerName, 'Sam');
        expect(detail.shots, ['Say cheese', 'Squeeze in']);
        expect(detail.participants.map((p) => p.name), ['Cass', 'A friend']);
        expect(detail.participants.map((p) => p.status), ['Joined', 'Invited']);
        expect(detail.memories, isEmpty);
        expect(
          server.log.where((e) => e.contains('memories')),
          isEmpty,
          reason: 'not even asked for until they accept',
        );
      },
    );

    test('once joined, the quest\'s memories show', () async {
      seed(status: 'accepted');

      final detail = await build().getQuest('q1');

      expect(detail.status, ParticipationStatus.accepted);
      expect(detail.memories.map((m) => m.id), ['m1']);
      expect(detail.memories.single.ownerName, 'Sam');
    });

    test('I am not listed among the others', () async {
      seed(status: 'accepted');

      final detail = await build().getQuest('q1');

      expect(detail.participants.where((p) => p.id == _me), isEmpty);
    });

    test('a quest that is gone is a friendly not-found', () async {
      await expectLater(
        build().getQuest('nope'),
        _failure(SharingFailureKind.notFound),
      );
    });
  });

  group('answering and leaving', () {
    test(
      'accepting and declining ask the server, never decide locally',
      () async {
        final repo = build();

        await repo.respond('q1', accept: true);
        await repo.respond('q1', accept: false);

        expect(server.log, [
          'rpc respond_to_quest_invitation',
          'rpc respond_to_quest_invitation',
        ]);
        expect(server.rpcParams['respond_to_quest_invitation'], {
          'p_quest_id': 'q1',
          'p_accept': false,
        });
      },
    );

    test('an invitation that is no longer open is explained', () async {
      server.rpcResults['respond_to_quest_invitation'] = const RpcError(
        '55000',
        'invitation_not_pending',
      );

      await expectLater(
        build().respond('q1', accept: true),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.message,
            'message',
            contains('no longer open'),
          ),
        ),
      );
    });

    test('leaving removes only my own place', () async {
      server.table('quest_participants')
        ..add({'quest_id': 'q1', 'user_id': _me})
        ..add({'quest_id': 'q1', 'user_id': 'friend-1'})
        ..add({'quest_id': 'q2', 'user_id': _me});

      await build().leave('q1');

      expect(
        server
            .table('quest_participants')
            .map((p) => '${p['quest_id']}:${p['user_id']}'),
        ['q1:friend-1', 'q2:$_me'],
      );
    });

    test('the owner can remove a friend from the quest', () async {
      server.table('quest_participants')
        ..add({'quest_id': 'q1', 'user_id': 'friend-1', 'status': 'accepted'})
        ..add({'quest_id': 'q1', 'user_id': 'friend-2', 'status': 'invited'});

      await build(userId: _owner).removeParticipant('q1', 'friend-1');

      expect(server.table('quest_participants').map((p) => p['user_id']), [
        'friend-2',
      ]);
    });

    test(
      'the owner sees who has said yes, who is waiting and who declined',
      () async {
        server.table('profiles')
          ..add({'id': 'f1', 'display_name': 'Bo', 'avatar_path': null})
          ..add({'id': 'f2', 'display_name': 'Cass', 'avatar_path': null})
          ..add({'id': 'f3', 'display_name': 'Dee', 'avatar_path': null});
        server.table('quest_participants')
          ..add({
            'quest_id': 'q1',
            'user_id': 'f1',
            'status': 'accepted',
            'invited_at': '2026-10-01T00:00:00Z',
          })
          ..add({
            'quest_id': 'q1',
            'user_id': 'f2',
            'status': 'invited',
            'invited_at': '2026-10-02T00:00:00Z',
          })
          ..add({
            'quest_id': 'q1',
            'user_id': 'f3',
            'status': 'declined',
            'invited_at': '2026-10-03T00:00:00Z',
          });

        final people = await build(userId: _owner).getParticipants('q1');

        expect(people.map((p) => '${p.name}: ${p.status}'), [
          'Bo: Joined',
          'Cass: Invited',
          'Dee: Declined',
        ]);
      },
    );
  });
}
