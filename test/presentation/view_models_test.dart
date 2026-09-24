import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/domain/memories/entities/memory.dart';
import 'package:photoquest/core/domain/people/entities/person.dart';
import 'package:photoquest/core/domain/quests/entities/quest.dart';
import 'package:photoquest/core/domain/quests/entities/quest_participant.dart';
import 'package:photoquest/core/domain/quests/entities/quest_shot.dart';
import 'package:photoquest/core/presentation/view_model/memories/memory_list_view_model.dart';
import 'package:photoquest/core/presentation/view_model/quests/create_quest_view_model.dart';
import 'package:photoquest/core/presentation/view_model/quests/quest_detail_view_model.dart';
import 'package:photoquest/core/presentation/view_model/quests/quest_intro_view_model.dart';
import 'package:photoquest/core/presentation/view_model/quests/quest_participants_view_model.dart';
import 'package:photoquest/core/domain/memories/enum/memory_filter.dart';
import 'package:photoquest/core/domain/quests/enum/create_quest_step.dart';
import 'package:photoquest/core/presentation/types/memories/memory_summary.dart';
import 'package:photoquest/core/presentation/types/memories/memory_box.dart';
import 'package:photoquest/core/presentation/types/quests/draft_shot.dart';
import 'package:photoquest/core/presentation/types/quests/create_quest_draft.dart';
import 'package:photoquest/core/presentation/types/quests/quest_detail.dart';
import 'package:photoquest/core/presentation/types/quests/quest_start_readiness.dart';
import 'package:photoquest/core/presentation/types/quests/quest_participant_with_person.dart';

final _now = DateTime(2026, 9, 17);

Quest _quest(String type) => Quest(
  id: 'q',
  title: 'Family Day',
  category: 'For Family',
  type: type,
  createdAt: _now,
  updatedAt: _now,
);

const _shot = QuestShot(
  id: 's1',
  questId: 'q',
  position: 0,
  instruction: 'Stand together and smile',
  shotType: 'group',
);

QuestParticipantWithPerson _participant(String status) =>
    QuestParticipantWithPerson(
      participant: QuestParticipant(
        id: 'qp-$status',
        questId: 'q',
        personId: 'p-$status',
        status: status,
        invitedAt: _now,
      ),
      person: Person(
        id: 'p-$status',
        name: 'Sam',
        type: 'friend',
        createdAt: _now,
        updatedAt: _now,
      ),
    );

class _FakeParticipants extends QuestParticipantsViewModel {
  _FakeParticipants(this._participants);

  final List<QuestParticipantWithPerson> _participants;

  @override
  Future<List<QuestParticipantWithPerson>> build(String questId) async =>
      _participants;
}

Future<QuestStartReadiness> _readiness({
  required String type,
  List<QuestShot> shots = const [_shot],
  List<QuestParticipantWithPerson> participants = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      questDetailProvider(
        'q',
      ).overrideWith((ref) => QuestDetail(quest: _quest(type), shots: shots)),
      questParticipantsViewModelProvider('q')
          .overrideWith(() => _FakeParticipants(participants)),
    ],
  );
  addTearDown(container.dispose);
  final sub = container.listen(questStartReadinessProvider('q'), (_, _) {});
  addTearDown(sub.close);
  await container.read(questDetailProvider('q').future);
  await container.read(questParticipantsViewModelProvider('q').future);
  return container.read(questStartReadinessProvider('q'));
}

void main() {
  group('Create Quest flow', () {
    late ProviderContainer container;
    late CreateQuestViewModel viewModel;

    setUp(() {
      container = ProviderContainer();
      // Keep the auto-dispose view model alive for the whole test.
      container.listen(createQuestViewModelProvider, (_, _) {});
      viewModel = container.read(createQuestViewModelProvider.notifier);
    });
    tearDown(() => container.dispose());

    CreateQuestDraft draft() => container.read(createQuestViewModelProvider);

    test('shots can be reordered and a removed shot put back', () {
      const a = DraftShot(instruction: 'A');
      const b = DraftShot(instruction: 'B');
      const c = DraftShot(instruction: 'C');
      viewModel
        ..addShot(a)
        ..addShot(b)
        ..addShot(c)
        ..moveShot(0, 2);
      expect([for (final s in draft().shots) s.instruction], ['B', 'C', 'A']);

      viewModel.removeShotAt(1);
      expect([for (final s in draft().shots) s.instruction], ['B', 'A']);

      viewModel.insertShotAt(1, c);
      expect([for (final s in draft().shots) s.instruction], ['B', 'C', 'A']);
    });

    test('a quest needs a name before moving on', () {
      expect(draft().blocker, 'Give your quest a name.');
      viewModel.nextStep();
      expect(draft().step, CreateQuestStep.what);

      viewModel.setTitle('Recreate our childhood photo');
      viewModel.nextStep();
      expect(draft().step, CreateQuestStep.idea);
    });

    test('a quest needs at least one photo to take', () {
      viewModel
        ..setTitle('Beach day')
        ..nextStep()
        ..nextStep()
        ..nextStep();
      expect(draft().step, CreateQuestStep.shots);
      expect(draft().blocker, 'Add at least one photo to take.');

      viewModel.nextStep();
      expect(draft().step, CreateQuestStep.shots);

      viewModel
        ..addShot(const DraftShot(instruction: 'Jump together'))
        ..nextStep();
      expect(draft().step, CreateQuestStep.review);
    });

    test('going back from the first step means leaving the flow', () {
      expect(viewModel.previousStep(), isFalse);

      viewModel
        ..setTitle('Game night')
        ..nextStep();
      expect(viewModel.previousStep(), isTrue);
      expect(draft().step, CreateQuestStep.what);
    });

    test('switching to solo drops invited participants', () {
      viewModel
        ..setType('group')
        ..toggleParticipant('p1');
      expect(draft().participantIds, ['p1']);

      viewModel.setType('solo');
      expect(draft().participantIds, isEmpty);
    });
  });

  group('Quest start readiness', () {
    test('a solo quest can start straight away', () async {
      final readiness = await _readiness(type: 'solo');
      expect(readiness.canStart, isTrue);
      expect(readiness.hint, isNull);
    });

    test(
      'a group quest waits for everyone invited to say they are in',
      () async {
        final readiness = await _readiness(
          type: 'group',
          participants: [_participant('accepted'), _participant('invited')],
        );
        expect(readiness.canStart, isFalse);
        expect(readiness.hint, contains("I'm in"));
      },
    );

    test('a group quest can start once everyone confirmed', () async {
      final readiness = await _readiness(
        type: 'group',
        participants: [_participant('accepted')],
      );
      expect(readiness.canStart, isTrue);
    });

    test('everyone being in is called out, not just allowed', () async {
      final readiness = await _readiness(
        type: 'group',
        participants: [_participant('accepted')],
      );
      expect(readiness.everyoneIn, isTrue);
      expect(readiness.hint, contains("Everyone's in"));

      final waiting = await _readiness(
        type: 'group',
        participants: [_participant('invited')],
      );
      expect(waiting.everyoneIn, isFalse);
    });

    test('a quest without shots cannot start', () async {
      final readiness = await _readiness(type: 'solo', shots: const []);
      expect(readiness.canStart, isFalse);
    });
  });

  test('memories are grouped by month, newest first', () {
    MemorySummary summary(String id, DateTime at) => MemorySummary(
      memory: Memory(
        id: id,
        questSessionId: 'session-$id',
        title: id,
        capturedAt: at,
        createdAt: at,
        updatedAt: at,
      ),
      coverPhoto: null,
      people: const [],
    );

    final months = groupByMonth([
      summary('a', DateTime(2026, 9, 20)),
      summary('b', DateTime(2026, 9, 2)),
      summary('c', DateTime(2025, 12, 24)),
    ]);

    expect(
      [for (final m in months) m.month],
      [DateTime(2026, 9), DateTime(2025, 12)],
    );
    expect([for (final s in months.first.memories) s.memory.id], ['a', 'b']);
  });

  test('the memory box filters by this day, this month, or all', () async {
    final now = DateTime.now();
    MemorySummary summary(String id, DateTime at) => MemorySummary(
      memory: Memory(
        id: id,
        questSessionId: 'session-$id',
        title: id,
        capturedAt: at,
        createdAt: at,
        updatedAt: at,
      ),
      coverPhoto: null,
      people: const [],
    );
    // Earlier today, this day last year, and two months ago.
    final memories = [
      summary('today', now),
      summary('last-year', DateTime(now.year - 1, now.month, now.day)),
      summary(
        'earlier',
        DateTime(now.year - 1, now.month, 1).subtract(const Duration(days: 40)),
      ),
    ];
    final container = ProviderContainer(
      overrides: [memoryListProvider.overrideWith((ref) => memories)],
    );
    addTearDown(container.dispose);
    await container.read(memoryListProvider.future);

    MemoryBox box() => container.read(memoryBoxProvider).requireValue;
    List<String> ids() => [
      for (final month in box().months)
        for (final s in month.memories) s.memory.id,
    ];

    expect(box().filter, MemoryFilter.allJourney);
    expect(ids(), ['today', 'last-year', 'earlier']);

    container
        .read(memoryFilterSelectionProvider.notifier)
        .select(MemoryFilter.thisDay);
    expect(ids(), ['today', 'last-year']);

    container
        .read(memoryFilterSelectionProvider.notifier)
        .select(MemoryFilter.thisMonth);
    expect(ids(), ['today']);

    expect(box().counts, {
      MemoryFilter.thisDay: 2,
      MemoryFilter.thisMonth: 1,
      MemoryFilter.allJourney: 3,
    });
  });

  test(
    'on this day resurfaces a memory from this date in a past year',
    () async {
      final today = DateTime.now();
      MemorySummary summary(String id, DateTime at) => MemorySummary(
        memory: Memory(
          id: id,
          questSessionId: 'session-$id',
          title: id,
          capturedAt: at,
          createdAt: at,
          updatedAt: at,
        ),
        coverPhoto: null,
        people: const [],
      );

      ProviderContainer containerWith(List<MemorySummary> memories) {
        final container = ProviderContainer(
          overrides: [memoryListProvider.overrideWith((ref) => memories)],
        );
        addTearDown(container.dispose);
        return container;
      }

      final lastYear = DateTime(today.year - 1, today.month, today.day);
      final found = await containerWith([
        summary('today', today),
        summary('last-year', lastYear),
      ]).read(onThisDayMemoryProvider.future);
      expect(found?.memory.id, 'last-year');

      final none = await containerWith([summary('today', today)])
          .read(onThisDayMemoryProvider.future);
      expect(none, isNull);
    },
  );
}
