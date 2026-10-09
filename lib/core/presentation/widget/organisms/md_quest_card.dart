import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../types/display_labels.dart';
import '../atoms/md_local_photo.dart';
import '../atoms/md_participant_avatar_stack.dart';
import '../molecules/md_app_card.dart';
import '../molecules/md_photobooth_print.dart';

/// A Quest as an inspiring, tappable card: cover, title, the real-life idea
/// in one or two lines, and who it's for. Participants show only for a
/// user-created pair/group Quest that has them. See design system §15.
class MdQuestCard extends StatelessWidget {
  const MdQuestCard({
    super.key,
    required this.quest,
    required this.onTap,
    this.people = const [],
  });

  final Quest quest;
  final VoidCallback onTap;

  /// Who's joining, shown as a small avatar stack when not empty.
  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      semanticLabel: [
        quest.title,
        questTypeLabel(quest.type),
        ?quest.description,
      ].join('. '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: quest.coverImagePath != null
                ? MdLocalPhoto(path: quest.coverImagePath)
                : MdQuestCoverArt(category: quest.category),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.ms),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: AppTypography.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      questTypeIcon(quest.type),
                      size: AppIconSizes.sm,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        questTypeLabel(quest.type),
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (people.isNotEmpty)
                      MdParticipantAvatarStack(people: people, radius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Illustrated stand-in cover for a Quest without a photo: a warm tint and
/// the category's icon, so cards still feel distinct. See CLAUDE.md §30.
class MdQuestCoverArt extends StatelessWidget {
  const MdQuestCoverArt({super.key, required this.category});

  final String category;

  static const _tints = [
    AppColors.filmYellow,
    AppColors.softPeach,
    AppColors.softGreen,
  ];

  @override
  Widget build(BuildContext context) {
    final tint = _tints[category.length % _tints.length];
    return ColoredBox(
      color: tint,
      child: Stack(
        children: [
          // A soft film-frame corner for a bit of photobooth character.
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.paper.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              questCategoryIcon(category),
              size: AppIconSizes.hero,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A Quest's hero image: its own cover photo if it has one, else an example
/// photobooth print of its category ("what this kind of memory looks like"), else the
/// illustrated art. For single, large heroes (Today's Quest, the intro) —
/// shelf cards keep the art so they don't repeat the category banner. See
/// design system §14.
class MdQuestHeroCover extends StatelessWidget {
  const MdQuestHeroCover({super.key, required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    if (quest.coverImagePath != null) {
      return MdLocalPhoto(path: quest.coverImagePath);
    }
    final example = questCategoryExample(quest.category);
    if (example == null) return MdQuestCoverArt(category: quest.category);

    return MdPhotoboothPrint(
      image: ResizeImage(AssetImage(example.asset), width: 640),
      focus: example.focus,
      note: example.tagline,
      date: DateTime.now(),
      semanticLabel: 'Example photobooth print for ${quest.title}',
    );
  }
}
