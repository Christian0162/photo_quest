import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/quests/entities/quest.dart';
import '../../../types/quests/quest_category_shelf.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_skeleton_box.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../molecules/quests/md_surprise_card.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/quests/md_quest_category_banner.dart';

/// Inspirational Quest picker: large visual cards on one shelf per
/// category ("For Us", "For Family" …), not a dense list.
class QuestSelectionTemplate extends StatelessWidget {
  const QuestSelectionTemplate({
    super.key,
    required this.shelves,
    required this.onRetry,
    required this.onCreateQuest,
    required this.onOpenQuest,
  });

  final AsyncValue<List<QuestCategoryShelf>> shelves;
  final VoidCallback onRetry;
  final VoidCallback onCreateQuest;
  final ValueChanged<Quest> onOpenQuest;

  void _surprise(List<QuestCategoryShelf> shelves) {
    final all = [
      for (final shelf in shelves)
        for (final item in shelf.quests) item.quest,
    ];
    if (all.isEmpty) return;
    onOpenQuest(all[math.Random().nextInt(all.length)]);
  }

  Future<void> _openShelf(
    BuildContext context,
    QuestCategoryShelf shelf,
  ) async {
    if (shelf.quests.length == 1) {
      onOpenQuest(shelf.quests.single.quest);
      return;
    }
    final picked = await showModalBottomSheet<Quest>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in shelf.quests)
              ListTile(
                title: Text(item.quest.title, style: AppTypography.heading3),
                subtitle: item.quest.description == null
                    ? null
                    : Text(
                        item.quest.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                onTap: () => Navigator.of(sheetContext).pop(item.quest),
              ),
          ],
        ),
      ),
    );
    if (picked != null) onOpenQuest(picked);
  }

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      showAppBar: true,
      actions: [
        TextButton.icon(
          onPressed: onCreateQuest,
          icon: const Icon(Icons.edit_rounded, size: AppIconSizes.md),
          label: const Text('Make your own'),
        ),
      ],
      body: shelves.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            MdSkeletonBox(width: 220, height: 36),
            SizedBox(height: AppSpacing.lg),
            MdSkeletonBox(height: 276),
            SizedBox(height: AppSpacing.lg),
            MdSkeletonBox(height: 276),
          ],
        ),
        error: (error, stack) => MdEmptyState.error(
          title: "We couldn't load quests",
          onRetry: onRetry,
        ),
        data: (list) {
          if (list.isEmpty) {
            return MdEmptyState(
              icon: Icons.auto_awesome_rounded,
              title: 'No quests yet',
              message: 'Create something fun and invite someone to join you.',
              action: MdPrimaryButton(
                label: 'Create a quest',
                expand: false,
                onPressed: onCreateQuest,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0,
                  AppSpacing.gutter,
                  AppSpacing.xs,
                ),
                child: Semantics(
                  header: true,
                  child: Text(
                    'Choose a quest',
                    style: AppTypography.display.copyWith(
                      fontSize: 40,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: Text(
                  'Pick something to do together — the photos come after.',
                  style: AppTypography.body.copyWith(
                    color: AppTypography.bodyMuted.color,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: MdSurpriseCard(onRoll: () => _surprise(list)),
              ),
              for (final (index, shelf) in list.indexed) ...[
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: MdQuestCategoryBanner(
                    category: shelf.category,
                    questCount: shelf.quests.length,
                    index: index,
                    onTap: () => _openShelf(context, shelf),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
