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

/// The in-progress Quest a creator is building. See CLAUDE.md §33.
class CreateQuestDraft {
  const CreateQuestDraft({
    this.title = '',
    this.description = '',
    this.category = 'Memory',
    this.type = 'solo',
    this.participantIds = const [],
    this.shots = const [],
  });

  final String title;
  final String description;
  final String category;
  final String type; // solo, pair, group
  final List<String> participantIds;
  final List<DraftShot> shots;

  bool get canCreate => title.trim().isNotEmpty && shots.isNotEmpty;

  CreateQuestDraft copyWith({
    String? title,
    String? description,
    String? category,
    String? type,
    List<String>? participantIds,
    List<DraftShot>? shots,
  }) {
    return CreateQuestDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      shots: shots ?? this.shots,
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

  void addShot(DraftShot shot) {
    state = state.copyWith(shots: [...state.shots, shot]);
  }

  void removeShotAt(int index) {
    final shots = [...state.shots]..removeAt(index);
    state = state.copyWith(shots: shots);
  }

  /// Creates the Quest, its shots, and invites the chosen participants.
  /// Returns the new Quest's id. See CLAUDE.md §16A, §59.
  Future<String> submit() async {
    final draft = state;
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

    state = const CreateQuestDraft();
    return questId;
  }
}
