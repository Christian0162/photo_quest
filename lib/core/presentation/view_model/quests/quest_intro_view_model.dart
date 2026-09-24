import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import 'quest_detail_view_model.dart';
import 'quest_participants_view_model.dart';
import '../../types/quests/quest_start_readiness.dart';

part 'quest_intro_view_model.g.dart';

@riverpod
QuestStartReadiness questStartReadiness(Ref ref, String questId) {
  final detail = ref.watch(questDetailProvider(questId)).value;
  if (detail == null) return const QuestStartReadiness(canStart: false);

  final people =
      ref.watch(questParticipantsViewModelProvider(questId)).value ?? const [];
  final solo = detail.quest.type == 'solo';
  final pending = people.any((p) => p.participant.status == 'invited');
  final everyoneIn = !solo && !pending && people.isNotEmpty;

  return QuestStartReadiness(
    everyoneIn: everyoneIn,
    // A pair/group Quest waits until everyone invited has said they're in.
    canStart: (solo || !pending) && detail.shots.isNotEmpty,
    hint: solo
        ? null
        : pending
        ? 'Everyone taps "I\'m in" before you start.'
        : people.isEmpty
        ? "Tip: invite the people you're doing this with."
        : "Everyone's in — let's go!",
  );
}

/// Starts a Quest from its introduction. State is true while starting.
/// See CLAUDE.md §21, §59.
@riverpod
class QuestIntroViewModel extends _$QuestIntroViewModel {
  @override
  bool build(String questId) => false;

  /// Opens a new Quest Session and its Memory with the confirmed
  /// participants, and returns the session id — or null if a start is
  /// already underway. Every start is a fresh session; earlier ones are
  /// never overwritten. Throws on failure.
  Future<String?> startQuest() async {
    if (state) return null;
    state = true;

    try {
      final memoryRepo = ref.read(memoryRepositoryProvider);
      final detail = await ref.read(questDetailProvider(questId).future);
      final participants = await ref.read(
        questParticipantsViewModelProvider(questId).future,
      );
      final sessionId = await memoryRepo.startQuestSession(questId);
      await memoryRepo.createMemory(
        questSessionId: sessionId,
        title: detail.quest.title,
        capturedAt: DateTime.now(),
        personIds: [
          for (final p in participants)
            if (p.participant.status == 'accepted') p.person.id,
        ],
      );
      return sessionId;
    } catch (error, stack) {
      developer.log(
        'Starting quest failed',
        name: 'photoquest.quest',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    } finally {
      if (ref.mounted) state = false;
    }
  }
}
