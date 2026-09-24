import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_constants.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest_shot.dart';
import '../../../domain/quests/enum/create_quest_step.dart';
import '../../../utils/app_haptics.dart';
import '../../types/display_labels.dart';
import '../../types/quests/create_quest_draft.dart';
import '../../types/quests/draft_shot.dart';
import '../atoms/md_person_avatar.dart';
import '../atoms/md_primary_button.dart';
import '../atoms/md_skeleton_box.dart';
import '../molecules/md_app_card.dart';
import '../molecules/md_choice_card.dart';
import '../molecules/md_step_progress.dart';
import '../organisms/md_app_scaffold.dart';
import '../organisms/md_quest_card.dart';
import '../organisms/md_quest_shot_list.dart';

const _categorySuggestions = [
  'Birthday',
  'Family',
  'Friends',
  'Date',
  'Adventure',
  'Funny',
  'Memory',
];

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
                _WhatStep(
                  controller: _titleController,
                  draft: draft,
                  onTitleChanged: widget.onTitleChanged,
                  onCategoryChanged: widget.onCategoryChanged,
                ),
                _IdeaStep(
                  controller: _descriptionController,
                  onChanged: widget.onDescriptionChanged,
                ),
                _WhoStep(
                  draft: draft,
                  people: widget.people,
                  onTypeChanged: widget.onTypeChanged,
                  onToggleParticipant: widget.onToggleParticipant,
                ),
                _ShotsStep(
                  controller: _shotController,
                  draft: draft,
                  onAdd: widget.onAddShot,
                  onRemove: widget.onRemoveShot,
                  onMove: widget.onMoveShot,
                ),
                _ReviewStep(
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

/// Shared shell for a step: one big question, optional helper, content.
class _StepPage extends StatelessWidget {
  const _StepPage({
    required this.question,
    this.helper,
    required this.children,
  });

  final String question;
  final String? helper;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.lg,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        Semantics(
          header: true,
          child: Text(question, style: AppTypography.heading1),
        ),
        if (helper != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(helper!, style: AppTypography.bodyMuted),
        ],
        const SizedBox(height: AppSpacing.lg),
        ...children,
      ],
    );
  }
}

class _WhatStep extends StatelessWidget {
  const _WhatStep({
    required this.controller,
    required this.draft,
    required this.onTitleChanged,
    required this.onCategoryChanged,
  });

  final TextEditingController controller;
  final CreateQuestDraft draft;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return _StepPage(
      question: 'What should we do?',
      helper: 'Give it a name you’ll smile at next year.',
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          style: AppTypography.bodyLarge,
          decoration: const InputDecoration(
            hintText: 'Recreate our childhood photo',
          ),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text("What kind of moment is it?", style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final suggestion in _categorySuggestions)
              ChoiceChip(
                avatar: Icon(
                  questCategoryIcon(suggestion),
                  size: AppIconSizes.sm,
                ),
                label: Text(suggestion),
                showCheckmark: false,
                selected: draft.category == suggestion,
                onSelected: (_) {
                  AppHaptics.selection();
                  onCategoryChanged(suggestion);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _IdeaStep extends StatelessWidget {
  const _IdeaStep({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepPage(
      question: "What's the idea?",
      helper:
          'Describe what you’ll do together in real life. Keep it short '
          'and fun — this part is optional.',
      children: [
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          style: AppTypography.bodyLarge,
          decoration: const InputDecoration(
            hintText:
                'Find an old childhood photo and recreate the pose together.',
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _WhoStep extends StatelessWidget {
  const _WhoStep({
    required this.draft,
    required this.people,
    required this.onTypeChanged,
    required this.onToggleParticipant,
  });

  final CreateQuestDraft draft;
  final AsyncValue<List<Person>> people;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onToggleParticipant;

  @override
  Widget build(BuildContext context) {
    const limit = AppConstants.defaultGroupQuestParticipantLimit;
    final full = draft.participantIds.length >= limit;

    return _StepPage(
      question: 'Who should join?',
      children: [
        Row(
          children: [
            for (final (value, label, icon) in questTypes) ...[
              Expanded(
                child: MdChoiceCard(
                  label: label,
                  icon: icon,
                  selected: draft.type == value,
                  onTap: () {
                    AppHaptics.selection();
                    onTypeChanged(value);
                  },
                ),
              ),
              if (value != questTypes.last.$1)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        if (draft.type != 'solo') ...[
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text('Invite your people', style: AppTypography.label),
              ),
              Text(
                '${draft.participantIds.length} of $limit',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Optional — you can invite people from the quest later, too.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.ms),
          people.when(
            loading: () => const MdSkeletonBox(height: 48),
            error: (error, stack) => const SizedBox.shrink(),
            data: (others) {
              if (others.isEmpty) {
                return Text(
                  'Add people in the People tab to invite them here.',
                  style: AppTypography.bodyMuted,
                );
              }
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final person in others)
                    Builder(
                      builder: (context) {
                        final selected = draft.participantIds.contains(
                          person.id,
                        );
                        return FilterChip(
                          avatar: selected
                              ? null
                              : MdPersonAvatar(person: person, radius: 12),
                          label: Text(person.name),
                          selected: selected,
                          onSelected: selected || !full
                              ? (_) {
                                  AppHaptics.selection();
                                  onToggleParticipant(person.id);
                                }
                              : null,
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

class _ShotsStep extends StatefulWidget {
  const _ShotsStep({
    required this.controller,
    required this.draft,
    required this.onAdd,
    required this.onRemove,
    required this.onMove,
  });

  final TextEditingController controller;
  final CreateQuestDraft draft;
  final ValueChanged<DraftShot> onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int from, int to) onMove;

  @override
  State<_ShotsStep> createState() => _ShotsStepState();
}

class _ShotsStepState extends State<_ShotsStep> {
  String _shotType = shotTypes.first.$1;

  void _submit() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;
    AppHaptics.selection();
    widget.onAdd(DraftShot(instruction: text, shotType: _shotType));
    widget.controller.clear();
    setState(() {});
  }

  void _addIdea((String, String) idea) {
    AppHaptics.selection();
    widget.onAdd(DraftShot(instruction: idea.$1, shotType: idea.$2));
  }

  @override
  Widget build(BuildContext context) {
    final shots = widget.draft.shots;
    final canAdd = widget.controller.text.trim().isNotEmpty;
    final taken = {for (final shot in shots) shot.instruction};
    final ideas = [
      for (final idea in _shotIdeas)
        if (!taken.contains(idea.$1)) idea,
    ];

    return _StepPage(
      question: 'What pictures should we take?',
      helper:
          'Each one becomes a shot in the photobooth. Short and playful works '
          'best — “Everyone squeeze together!”',
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (value, label, icon) in shotTypes)
              ChoiceChip(
                avatar: Icon(icon, size: AppIconSizes.sm),
                label: Text(label),
                showCheckmark: false,
                selected: _shotType == value,
                onSelected: (_) {
                  AppHaptics.selection();
                  setState(() => _shotType = value);
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.ms),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Everyone squeeze together and smile',
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              tooltip: 'Add this shot',
              onPressed: canAdd ? _submit : null,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.warmCoral,
                foregroundColor: AppColors.onCoral,
                disabledBackgroundColor: AppColors.sunken,
                fixedSize: const Size.square(56),
              ),
            ),
          ],
        ),
        if (ideas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Need ideas? Tap to add', style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
          // One scrolling row, so ideas help without pushing your own shots
          // below the fold.
          SizedBox(
            height: AppTouch.minTarget,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: ideas.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final idea = ideas[index];
                return ActionChip(
                  avatar: Icon(shotTypeIcon(idea.$2), size: AppIconSizes.sm),
                  label: Text(idea.$1),
                  onPressed: () => _addIdea(idea),
                );
              },
            ),
          ),
        ],
        if (shots.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  shots.length == 1
                      ? 'Your shot'
                      : 'Your ${shots.length} shots',
                  style: AppTypography.label,
                ),
              ),
              if (shots.length > 1)
                Text('Drag to reorder', style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: shots.length,
            onReorderStart: (_) => AppHaptics.selection(),
            onReorderItem: widget.onMove,
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Transform.scale(
                scale: 1 + 0.03 * Curves.easeOut.transform(animation.value),
                child: child,
              ),
              child: Material(color: Colors.transparent, child: child),
            ),
            itemBuilder: (context, i) => Padding(
              key: ObjectKey(shots[i]),
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Dismissible(
                key: ObjectKey(shots[i]),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => widget.onRemove(i),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Remove',
                        style: AppTypography.label.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                child: _ShotRow(
                  index: i,
                  shot: shots[i],
                  reorderable: shots.length > 1,
                  onRemove: () => widget.onRemove(i),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Ready-made, playful shot instructions: tap one instead of typing. See
/// design system §27 ("short, playful, actionable").
const _shotIdeas = [
  ('Everyone squeeze together!', 'group'),
  ('Give your funniest face', 'candid'),
  ('Copy the pose', 'group'),
  ('Laugh at something real', 'candid'),
  ('A close-up of your hands', 'close_up'),
  ('Show where you are', 'wide'),
];

/// One shot in the list: its number, instruction and framing, a drag
/// handle, and a remove button (swiping left removes it too).
class _ShotRow extends StatelessWidget {
  const _ShotRow({
    required this.index,
    required this.shot,
    required this.reorderable,
    required this.onRemove,
  });

  final int index;
  final DraftShot shot;
  final bool reorderable;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          if (reorderable)
            ReorderableDragStartListener(
              index: index,
              child: const Tooltip(
                message: 'Drag to reorder',
                child: SizedBox.square(
                  dimension: AppTouch.minTarget,
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.softPeach,
            child: Text('${index + 1}', style: AppTypography.label),
          ),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shot.instruction, style: AppTypography.body),
                Text(
                  shotTypeLabel(shot.shotType),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove shot ${index + 1}',
            icon: const Icon(Icons.close_rounded, size: AppIconSizes.md),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.draft, required this.people});

  final CreateQuestDraft draft;
  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final invited = people
        .where((p) => draft.participantIds.contains(p.id))
        .toList();

    return _StepPage(
      question: 'Looking good?',
      helper: 'You can start it right away once it’s created.',
      children: [
        MdAppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 7,
                child: MdQuestCoverArt(category: draft.category),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.category.toUpperCase(),
                      style: AppTypography.overline,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(draft.title, style: AppTypography.heading2),
                    if (draft.description.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(draft.description, style: AppTypography.bodyMuted),
                    ],
                    const SizedBox(height: AppSpacing.ms),
                    Row(
                      children: [
                        Icon(
                          questTypeIcon(draft.type),
                          size: AppIconSizes.sm,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            invited.isEmpty
                                ? questTypeLabel(draft.type)
                                : 'With ${invited.map((p) => p.name).join(', ')}',
                            style: AppTypography.caption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('The photos', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        MdQuestShotList(
          shots: [
            for (var i = 0; i < draft.shots.length; i++)
              QuestShot(
                id: '$i',
                questId: '',
                position: i,
                instruction: draft.shots[i].instruction,
                shotType: draft.shots[i].shotType,
              ),
          ],
        ),
      ],
    );
  }
}
