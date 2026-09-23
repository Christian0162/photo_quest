import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest_participant.dart';

part 'quest_participants_view_model.g.dart';

/// A Quest Participant paired with the Person it refers to, for display.
/// See CLAUDE.md §16A, §20.
class QuestParticipantWithPerson {
  const QuestParticipantWithPerson({
    required this.participant,
    required this.person,
  });

  final QuestParticipant participant;
  final Person person;
}

/// Drives the participant list on the Quest Introduction screen: who's
/// invited, who's confirmed, and inviting more People. See CLAUDE.md §33,
/// §40-41, §60.
///
/// V1 is local-only and single-device (CLAUDE.md §54A): everyone doing the
/// quest is physically present and shares this phone, so "accepting an
/// invitation" means tapping your own name on the shared screen before the
/// quest starts, rather than a remote push notification.
@riverpod
class QuestParticipantsViewModel extends _$QuestParticipantsViewModel {
  @override
  Future<List<QuestParticipantWithPerson>> build(String questId) async {
    return _load();
  }

  Future<List<QuestParticipantWithPerson>> _load() async {
    final questRepo = ref.watch(questRepositoryProvider);
    final peopleRepo = ref.watch(peopleRepositoryProvider);

    final participants = await questRepo.getParticipants(questId);
    final result = <QuestParticipantWithPerson>[];
    for (final participant in participants) {
      final person = await peopleRepo.getPerson(participant.personId);
      if (person != null) {
        result.add(
          QuestParticipantWithPerson(participant: participant, person: person),
        );
      }
    }
    return result;
  }

  /// People who could still be invited: everyone not already on this Quest.
  Future<List<Person>> invitablePeople() async {
    final current = await future;
    final currentIds = current.map((p) => p.person.id).toSet();
    final people = await ref.read(peopleRepositoryProvider).getPeople();
    return people.where((p) => !currentIds.contains(p.id)).toList();
  }

  Future<void> addParticipant(String personId) async {
    final questRepo = ref.read(questRepositoryProvider);
    final current = state.value ?? const [];
    if (current.any((p) => p.person.id == personId)) return;

    await questRepo.inviteParticipant(questId: questId, personId: personId);
    state = AsyncData(await _load());
  }

  /// Records whether this participant confirmed (`accepted`) or won't be
  /// joining (`declined`). See CLAUDE.md §16A.
  Future<void> respond({
    required String participantId,
    required bool accepted,
  }) async {
    await ref
        .read(questRepositoryProvider)
        .respondToInvitation(participantId: participantId, accepted: accepted);
    state = AsyncData(await _load());
  }

  Future<void> removeParticipant(String participantId) async {
    await ref.read(questRepositoryProvider).removeParticipant(participantId);
    state = AsyncData(await _load());
  }
}
