import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';
import '../../../domain/quests/enum/create_quest_step.dart';
import '../../types/quests/draft_shot.dart';
import '../../types/quests/create_quest_draft.dart';

part 'create_quest_view_model.g.dart';

const _uuid = Uuid();

/// Drives the guided Create Quest flow: what/description/participants/shots
/// -> review -> create. See CLAUDE.md §33, design system §17-19.
@riverpod
class CreateQuestViewModel extends _$CreateQuestViewModel {
  @override
  CreateQuestDraft build() => const CreateQuestDraft();

  void setTitle(String title) => state = state.copyWith(title: title);

  void setDescription(String description) =>
      state = state.copyWith(description: description);

  void setCategory(String category) =>
      state = state.copyWith(category: category);

  void setType(String type) {
    state = state.copyWith(
      type: type,
      participantIds: type == 'solo' ? const [] : state.participantIds,
    );
  }

  void toggleParticipant(String personId) {
    final current = state.participantIds;
    state = state.copyWith(
      participantIds: current.contains(personId)
          ? current.where((id) => id != personId).toList()
          : [...current, personId],
    );
  }

  /// Moves to the next step, unless this one still has a [blocker].
  void nextStep() {
    if (state.blocker != null || state.isLastStep) return;
    state = state.copyWith(step: CreateQuestStep.values[state.step.index + 1]);
  }

  /// Moves back one step. Returns false on the first step, where going
  /// back means leaving the flow.
  bool previousStep() {
    if (state.isFirstStep) return false;
    state = state.copyWith(step: CreateQuestStep.values[state.step.index - 1]);
    return true;
  }

  void addShot(DraftShot shot) {
    state = state.copyWith(shots: [...state.shots, shot]);
  }

  void removeShotAt(int index) {
    final shots = [...state.shots]..removeAt(index);
    state = state.copyWith(shots: shots);
  }

  /// Puts a shot back where it was — the "Undo" after removing one.
  void insertShotAt(int index, DraftShot shot) {
    final shots = [...state.shots]
      ..insert(index.clamp(0, state.shots.length), shot);
    state = state.copyWith(shots: shots);
  }

  /// Moves a shot so it's taken at [to] (its final position) instead.
  void moveShot(int from, int to) {
    if (from == to) return;
    final shots = [...state.shots];
    final shot = shots.removeAt(from);
    shots.insert(to.clamp(0, shots.length), shot);
    state = state.copyWith(shots: shots);
  }

  /// Creates the Quest, its shots, and invites the chosen participants.
  /// Returns the new Quest's id, or null if it's already being created.
  /// Throws on failure. See CLAUDE.md §16A, §59.
  Future<String?> submit() async {
    if (state.isSubmitting || !state.canCreate) return null;
    final draft = state;
    state = draft.copyWith(isSubmitting: true);

    try {
      final questRepo = ref.read(questRepositoryProvider);
      final peopleRepo = ref.read(peopleRepositoryProvider);
      final self = await peopleRepo.getSelfPerson();
      final now = DateTime.now();
      final questId = _uuid.v4();

      await questRepo.createQuest(
        Quest(
          id: questId,
          creatorId: self?.id,
          title: draft.title.trim(),
          description: draft.description.trim().isEmpty
              ? null
              : draft.description.trim(),
          category: draft.category,
          type: draft.type,
          status: 'published',
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (var i = 0; i < draft.shots.length; i++) {
        final shot = draft.shots[i];
        await questRepo.addShot(
          QuestShot(
            id: '',
            questId: questId,
            position: i + 1,
            instruction: shot.instruction,
            shotType: shot.shotType,
          ),
        );
      }

      for (final personId in draft.participantIds) {
        await questRepo.inviteParticipant(questId: questId, personId: personId);
      }

      // Stays "submitting" while the screen moves on to the new Quest; the
      // draft is discarded with the screen.
      return questId;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}
