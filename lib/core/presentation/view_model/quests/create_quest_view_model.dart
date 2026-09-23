import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';

part 'create_quest_view_model.g.dart';

const _uuid = Uuid();

/// A single instruction/photo the creator wants captured. See CLAUDE.md
/// §17-19.
class DraftShot {
  const DraftShot({required this.instruction, this.shotType = 'group'});

  final String instruction;
  final String shotType;
}

/// The steps of the guided Create Quest flow, one question each.
enum CreateQuestStep { what, idea, who, shots, review }

/// The in-progress Quest a creator is building, and where they are in the
/// flow. See CLAUDE.md §33.
class CreateQuestDraft {
  const CreateQuestDraft({
    this.title = '',
    this.description = '',
    this.category = 'Memory',
    this.type = 'solo',
    this.participantIds = const [],
    this.shots = const [],
    this.step = CreateQuestStep.what,
    this.isSubmitting = false,
  });

  final String title;
  final String description;
  final String category;
  final String type; // solo, pair, group
  final List<String> participantIds;
  final List<DraftShot> shots;
  final CreateQuestStep step;
  final bool isSubmitting;

  bool get canCreate => title.trim().isNotEmpty && shots.isNotEmpty;
  bool get isFirstStep => step == CreateQuestStep.values.first;
  bool get isLastStep => step == CreateQuestStep.values.last;

  /// Whether leaving now would lose something the creator wrote.
  bool get hasWork => title.trim().isNotEmpty || shots.isNotEmpty;

  /// Why the current step can't move on yet, or null when it can.
  String? get blocker => switch (step) {
    CreateQuestStep.what when title.trim().isEmpty => 'Give your quest a name.',
    CreateQuestStep.shots when shots.isEmpty =>
      'Add at least one photo to take.',
    _ => null,
  };

  CreateQuestDraft copyWith({
    String? title,
    String? description,
    String? category,
    String? type,
    List<String>? participantIds,
    List<DraftShot>? shots,
    CreateQuestStep? step,
    bool? isSubmitting,
  }) {
    return CreateQuestDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      shots: shots ?? this.shots,
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

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
