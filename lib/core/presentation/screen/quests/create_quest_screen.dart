import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../view_model/people/people_list_view_model.dart';
import '../../view_model/quests/create_quest_view_model.dart';
import '../../widget/atoms/loading_indicator.dart';
import '../../widget/atoms/person_avatar.dart';
import '../../widget/atoms/primary_button.dart';
import '../../widget/molecules/app_card.dart';
import '../../widget/molecules/section_header.dart';

const _categorySuggestions = [
  'Birthday',
  'Family',
  'Friends',
  'Date',
  'Adventure',
  'Funny',
  'Memory',
];

const _questTypes = [
  ('solo', 'Just me', Icons.person_rounded),
  ('pair', 'The two of us', Icons.favorite_rounded),
  ('group', 'A group', Icons.groups_rounded),
];

const _shotTypes = [
  ('group', 'Group'),
  ('solo', 'Solo'),
  ('candid', 'Candid'),
  ('close_up', 'Close-up'),
  ('wide', 'Wide'),
];

/// A muted "Step X of N" caption above each step's heading, so the guided
/// flow always orients the person. See design system §31.
class _StepCaption extends StatelessWidget {
  const _StepCaption({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        'Step $step of $total',
        style: AppTypography.bodyMuted.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// A guided, step-at-a-time flow for creating a Quest, instead of one long
/// form. See design system §17-19.
class CreateQuestScreen extends ConsumerStatefulWidget {
  const CreateQuestScreen({super.key});

  @override
  ConsumerState<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends ConsumerState<CreateQuestScreen> {
  final _pageController = PageController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shotController = TextEditingController();
  int _step = 0;
  bool _creating = false;

  static const _totalSteps = 4;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _shotController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  bool _canContinue(CreateQuestDraft draft) {
    switch (_step) {
      case 0:
        return draft.title.trim().isNotEmpty;
      case 2:
        return draft.shots.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final questId = await ref
          .read(createQuestViewModelProvider.notifier)
          .submit();
      if (!mounted) return;
      context.pushReplacement('/quests/$questId');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createQuestViewModelProvider);
    final notifier = ref.read(createQuestViewModelProvider.notifier);
    final lastStep = _step == _totalSteps - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Quest'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  for (var i = 0; i < _totalSteps; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs / 2,
                        ),
                        child: SizedBox(
                          height: 4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: i <= _step
                                  ? AppColors.warmCoral
                                  : AppColors.softPeach,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                    onTitleChanged: notifier.setTitle,
                    onCategoryChanged: notifier.setCategory,
                    onTypeChanged: notifier.setType,
                  ),
                  _DescriptionStep(
                    controller: _descriptionController,
                    onChanged: notifier.setDescription,
                  ),
                  _ShotsStep(
                    controller: _shotController,
                    draft: draft,
                    onAdd: notifier.addShot,
                    onRemove: notifier.removeShotAt,
                  ),
                  _ReviewStep(
                    draft: draft,
                    onToggleParticipant: notifier.toggleParticipant,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    TextButton(
                      onPressed: () => _goTo(_step - 1),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: PrimaryButton(
                      label: lastStep
                          ? (_creating ? 'Creating…' : 'Create Quest')
                          : 'Continue',
                      onPressed: !_canContinue(draft) || _creating
                          ? null
                          : () => lastStep ? _create() : _goTo(_step + 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatStep extends StatelessWidget {
  const _WhatStep({
    required this.controller,
    required this.draft,
    required this.onTitleChanged,
    required this.onCategoryChanged,
    required this.onTypeChanged,
  });

  final TextEditingController controller;
  final CreateQuestDraft draft;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const _StepCaption(step: 1, total: 4),
        Text('What should we do?', style: AppTypography.heading2),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Recreate our childhood photo',
          ),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final suggestion in _categorySuggestions)
              ChoiceChip(
                label: Text(suggestion),
                selected: draft.category == suggestion,
                onSelected: (_) => onCategoryChanged(suggestion),
                selectedColor: AppColors.softPeach,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Who should join?', style: AppTypography.heading3),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final (value, label, icon) in _questTypes) ...[
              Expanded(
                child: _QuestTypeCard(
                  label: label,
                  icon: icon,
                  selected: draft.type == value,
                  onTap: () => onTypeChanged(value),
                ),
              ),
              if (value != _questTypes.last.$1)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ],
    );
  }
}

/// A visual, tappable quest-type option — favored over a generic radio
/// list per design system §17 ("creating a quest should feel creative").
class _QuestTypeCard extends StatelessWidget {
  const _QuestTypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.md + AppSpacing.xs),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.softPeach : AppColors.warmCream,
          borderRadius: BorderRadius.circular(AppSpacing.md + AppSpacing.xs),
          border: Border.all(
            color: selected ? AppColors.warmCoral : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.warmCoral : AppColors.warmCharcoal,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted.copyWith(
                color: AppColors.warmCharcoal,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionStep extends StatelessWidget {
  const _DescriptionStep({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const _StepCaption(step: 2, total: 4),
        Text("What's the idea?", style: AppTypography.heading2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Find an old photo and recreate the pose together, wherever '
          "you're free.",
          style: AppTypography.bodyMuted,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: controller,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Describe the real-life activity…',
          ),
          onChanged: onChanged,
        ),
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
  });

  final TextEditingController controller;
  final CreateQuestDraft draft;
  final ValueChanged<DraftShot> onAdd;
  final ValueChanged<int> onRemove;

  @override
  State<_ShotsStep> createState() => _ShotsStepState();
}

class _ShotsStepState extends State<_ShotsStep> {
  String _shotType = _shotTypes.first.$1;

  void _submit() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(DraftShot(instruction: text, shotType: _shotType));
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const _StepCaption(step: 3, total: 4),
        Text('What pictures should we take?', style: AppTypography.heading2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Add at least one shot everyone needs to capture together.',
          style: AppTypography.bodyMuted,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (value, label) in _shotTypes)
              ChoiceChip(
                label: Text(label),
                selected: _shotType == value,
                onSelected: (_) => setState(() => _shotType = value),
                selectedColor: AppColors.softPeach,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Everyone squeeze together and smile',
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.warmCoral,
                foregroundColor: AppColors.warmCream,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < draft.shots.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.softPeach,
                    child: Text('${i + 1}', style: AppTypography.bodyMuted),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      draft.shots[i].instruction,
                      style: AppTypography.body,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => widget.onRemove(i),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep({required this.draft, required this.onToggleParticipant});

  final CreateQuestDraft draft;
  final ValueChanged<String> onToggleParticipant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleListProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const _StepCaption(step: 4, total: 4),
        Text('Review', style: AppTypography.heading2),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _questTypes.firstWhere((t) => t.$1 == draft.type).$3,
                    color: AppColors.warmCoral,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(draft.title, style: AppTypography.heading3),
                  ),
                ],
              ),
              if (draft.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(draft.description, style: AppTypography.bodyMuted),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text('${draft.shots.length} shots', style: AppTypography.body),
            ],
          ),
        ),
        if (draft.type != 'solo') ...[
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Invite people now (optional)'),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "You can also invite people from the Quest once it's created.",
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          people.when(
            loading: () => const LoadingIndicator(),
            error: (error, stack) => const SizedBox.shrink(),
            data: (list) {
              if (list.isEmpty) return const SizedBox.shrink();
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final person in list)
                    FilterChip(
                      avatar: PersonAvatar(person: person, radius: 14),
                      label: Text(person.name),
                      selected: draft.participantIds.contains(person.id),
                      onSelected: (_) => onToggleParticipant(person.id),
                      selectedColor: AppColors.softGreen.withValues(
                        alpha: 0.35,
                      ),
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
