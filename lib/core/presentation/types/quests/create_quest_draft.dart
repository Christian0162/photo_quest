import '../../../domain/quests/enum/create_quest_step.dart';
import 'draft_shot.dart';

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
