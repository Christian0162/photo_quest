import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/people/entities/person.dart';
import '../../../../domain/quests/enum/create_quest_step.dart';
import '../../../types/quests/create_quest_draft.dart';
import '../../../types/quests/draft_shot.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/common/md_step_progress.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/quests/md_quest_what_step.dart';
import '../../organisms/quests/md_quest_idea_step.dart';
import '../../organisms/quests/md_quest_who_step.dart';
import '../../organisms/quests/md_quest_shots_step.dart';
import '../../organisms/quests/md_quest_review_step.dart';

/// A guided, one-question-per-step flow for creating a Quest instead of a
/// long form: what → the idea → who → which photos → review. The step and
/// its validation come from [CreateQuestDraft]; this only draws them.
/// See CLAUDE.md §33, design system §17-20.
class CreateQuestTemplate extends StatefulWidget {
  const CreateQuestTemplate({
    super.key,
    required this.draft,
    required this.people,
    required this.onClose,
    required this.onBack,
    required this.onContinue,
    required this.onCreate,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onCategoryChanged,
    required this.onTypeChanged,
    required this.onToggleParticipant,
    required this.onAddShot,
    required this.onShotTypeChanged,
    required this.onRemoveShot,
    required this.onMoveShot,
  });

  final CreateQuestDraft draft;

  /// The People who can be invited (everyone except the device owner).
  final AsyncValue<List<Person>> people;
  final VoidCallback onClose;

  /// Back one step — also what system back does, via [MdAppScaffold].
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onCreate;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onToggleParticipant;
  final ValueChanged<DraftShot> onAddShot;
  final ValueChanged<String> onShotTypeChanged;
  final ValueChanged<int> onRemoveShot;

  /// Moves a shot from one position to its final new position.
  final void Function(int from, int to) onMoveShot;

  @override
  State<CreateQuestTemplate> createState() => _CreateQuestTemplateState();
}

class _CreateQuestTemplateState extends State<CreateQuestTemplate> {
  late final _pageController = PageController(
    initialPage: widget.draft.step.index,
  );
  late final _titleController = TextEditingController(text: widget.draft.title);
  late final _descriptionController = TextEditingController(
    text: widget.draft.description,
  );
  final _shotController = TextEditingController();

  @override
  void didUpdateWidget(covariant CreateQuestTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    final step = widget.draft.step;
    if (step != oldWidget.draft.step) {
      FocusScope.of(context).unfocus();
      _pageController.animateToPage(
        step.index,
        duration: AppMotion.of(context, AppMotion.medium),
        curve: AppMotion.standard,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _shotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final blocker = draft.blocker;
    final isLast = draft.isLastStep;

    return MdAppScaffold(
      showAppBar: true,
      title: 'New quest',
      leading: IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.close_rounded),
        onPressed: widget.onClose,
      ),
      onBackBlocked: widget.onBack,
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (blocker != null) ...[
            Text(
              blocker,
              style: AppTypography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              if (!draft.isFirstStep) ...[
                MdSecondaryButton(
                  label: 'Back',
                  expand: false,
                  onPressed: widget.onBack,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: MdPrimaryButton(
                  label: isLast ? 'Create quest' : 'Continue',
                  icon: isLast ? Icons.auto_awesome_rounded : null,
                  loading: draft.isSubmitting,
                  onPressed: blocker != null
                      ? null
                      : isLast
                      ? widget.onCreate
                      : widget.onContinue,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: MdStepProgress(
              label: 'Step',
              current: draft.step.index,
              total: CreateQuestStep.values.length,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MdQuestWhatStep(
                  controller: _titleController,
                  draft: draft,
                  onTitleChanged: widget.onTitleChanged,
                  onCategoryChanged: widget.onCategoryChanged,
                ),
                MdQuestIdeaStep(
                  controller: _descriptionController,
                  onChanged: widget.onDescriptionChanged,
                ),
                MdQuestWhoStep(
                  draft: draft,
                  people: widget.people,
                  onTypeChanged: widget.onTypeChanged,
                  onToggleParticipant: widget.onToggleParticipant,
                ),
                MdQuestShotsStep(
                  controller: _shotController,
                  draft: draft,
                  onAdd: widget.onAddShot,
                  onShotTypeChanged: widget.onShotTypeChanged,
                  onRemove: widget.onRemoveShot,
                  onMove: widget.onMoveShot,
                ),
                MdQuestReviewStep(
                  draft: draft,
                  people: widget.people.value ?? const [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
