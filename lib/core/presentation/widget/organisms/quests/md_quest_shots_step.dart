import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../utils/app_haptics.dart';
import '../../../types/display_labels.dart';
import '../../../types/quests/create_quest_draft.dart';
import '../../../types/quests/draft_shot.dart';
import '../../molecules/quests/md_quest_step_page.dart';
import '../../molecules/quests/md_quest_shot_row.dart';

/// Ready-made, playful shot instructions: tap one instead of typing.
const _shotIdeas = [
  ('Everyone squeeze together!', 'group'),
  ('Give your funniest face', 'candid'),
  ('Copy the pose', 'group'),
  ('Laugh at something real', 'candid'),
  ('A close-up of your hands', 'close_up'),
  ('Show where you are', 'wide'),
];

class MdQuestShotsStep extends StatelessWidget {
  const MdQuestShotsStep({
    super.key,
    required this.controller,
    required this.draft,
    required this.onAdd,
    required this.onShotTypeChanged,
    required this.onRemove,
    required this.onMove,
  });

  final TextEditingController controller;
  final CreateQuestDraft draft;
  final ValueChanged<DraftShot> onAdd;
  final ValueChanged<String> onShotTypeChanged;
  final ValueChanged<int> onRemove;
  final void Function(int from, int to) onMove;

  void _submit() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    AppHaptics.selection();
    onAdd(DraftShot(instruction: text, shotType: draft.shotType));
    controller.clear();
  }

  void _addIdea((String, String) idea) {
    AppHaptics.selection();
    onAdd(DraftShot(instruction: idea.$1, shotType: idea.$2));
  }

  @override
  Widget build(BuildContext context) {
    // The typed text decides whether "add" is enabled, so rebuild with it.
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _buildStep(),
    );
  }

  Widget _buildStep() {
    final shots = draft.shots;
    final canAdd = controller.text.trim().isNotEmpty;
    final taken = {for (final shot in shots) shot.instruction};
    final ideas = [
      for (final idea in _shotIdeas)
        if (!taken.contains(idea.$1)) idea,
    ];

    return MdQuestStepPage(
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
                selected: draft.shotType == value,
                onSelected: (_) {
                  AppHaptics.selection();
                  onShotTypeChanged(value);
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
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Everyone squeeze together and smile',
                ),
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
            onReorderItem: onMove,
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
                onDismissed: (_) => onRemove(i),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(AppRadius.base),
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
                child: MdQuestShotRow(
                  index: i,
                  shot: shots[i],
                  reorderable: shots.length > 1,
                  onRemove: () => onRemove(i),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
