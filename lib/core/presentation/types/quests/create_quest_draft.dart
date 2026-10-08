import '../../../domain/quests/enum/create_quest_step.dart';
import 'draft_shot.dart';

/// The in-progress Quest a creator is building, and where they are in the
/// flow.
class CreateQuestDraft {
  const CreateQuestDraft({
    this.title = '',
    this.description = '',
    this.category = 'Memory',
    this.type = 'solo',
    this.participantIds = const [],
    this.shots = const [],
    this.shotType = 'group',
    this.step = CreateQuestStep.what,
    this.isSubmitting = false,
  });

  final String title;
  final String description;
  final String category;
  final String type; // solo, pair, group
  final List<String> participantIds;
  final List<DraftShot> shots;

  final String shotType;
  final CreateQuestStep step;
  final bool isSubmitting;

  bool get canCreate => title.trim().isNotEmpty && shots.isNotEmpty;
  bool get isFirstStep => step == CreateQuestStep.values.first;
  bool get isLastStep => step == CreateQuestStep.values.last;

  bool get hasWork => title.trim().isNotEmpty || shots.isNotEmpty;

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
    String? shotType,
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
      shotType: shotType ?? this.shotType,
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
