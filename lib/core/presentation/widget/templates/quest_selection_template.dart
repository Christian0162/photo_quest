import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../view_model/quests/quest_list_view_model.dart';
import '../atoms/fade_slide_in.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/empty_state.dart';
import '../organisms/app_scaffold.dart';
import '../organisms/quest_card.dart';
import '../organisms/quest_category_banner.dart';

/// Inspirational Quest picker: large visual cards on one shelf per
/// category ("For Us", "For Family" …), not a dense list. See CLAUDE.md §33.
class QuestSelectionTemplate extends StatelessWidget {
  const QuestSelectionTemplate({
    super.key,
    required this.shelves,
    required this.onRetry,
    required this.onCreateQuest,
    required this.onOpenQuest,
  });

  static const _cardWidth = 216.0;

  final AsyncValue<List<QuestCategoryShelf>> shelves;
  final VoidCallback onRetry;
  final VoidCallback onCreateQuest;
  final ValueChanged<Quest> onOpenQuest;

  /// Cover (4:3) + padding, plus room for the title and type line that
  /// grows with the person's text size.
  static double _shelfHeight(BuildContext context) =>
      _cardWidth * 3 / 4 +
      AppSpacing.xl +
      MediaQuery.textScalerOf(context).scale(76);

  /// Opens a random quest — for when "anything!" is the answer.
  void _surprise(List<QuestCategoryShelf> shelves) {
    final all = [
      for (final shelf in shelves)
        for (final item in shelf.quests) item.quest,
    ];
    if (all.isEmpty) return;
    onOpenQuest(all[math.Random().nextInt(all.length)]);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: true,
      actions: [
        TextButton.icon(
          onPressed: onCreateQuest,
          icon: const Icon(Icons.edit_rounded, size: AppIconSizes.md),
          label: const Text('Make your own'),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      body: shelves.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SkeletonBox(width: 220, height: 36),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 276),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(height: 276),
          ],
        ),
        error: (error, stack) => EmptyState.error(
          title: "We couldn't load quests",
          onRetry: onRetry,
        ),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.auto_awesome_rounded,
              title: 'No quests yet',
              message: 'Create something fun and invite someone to join you.',
              action: PrimaryButton(
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
                  child: Text('Choose a quest', style: AppTypography.heading1),
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SecondaryButton(
                    label: "Can't decide? Surprise me",
                    icon: Icons.casino_rounded,
                    expand: false,
                    onPressed: () => _surprise(list),
                  ),
                ),
              ),
              for (final (index, shelf) in list.indexed) ...[
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: QuestCategoryBanner(
                    category: shelf.category,
                    questCount: shelf.quests.length,
                    index: index,
                  ),
                ),
                const SizedBox(height: AppSpacing.ms),
                FadeSlideIn(
                  order: index + 1,
                  child: SizedBox(
                    height: _shelfHeight(context),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      itemCount: shelf.quests.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.ms),
                      itemBuilder: (context, index) {
                        final item = shelf.quests[index];
                        // Top-aligned so a card is only as tall as its
                        // content, not the whole shelf.
                        return Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: _cardWidth,
                            child: QuestCard(
                              quest: item.quest,
                              people: item.participants,
                              onTap: () => onOpenQuest(item.quest),
                            ),
                          ),
                        );
                      },
                    ),
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
