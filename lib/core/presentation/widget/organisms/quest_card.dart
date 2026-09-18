import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../view_model/quests/quest_participants_view_model.dart';
import '../atoms/participant_avatar_stack.dart';
import '../molecules/app_card.dart';
import '../../../domain/quests/entities/quest.dart';

/// A Quest template/instance card. Shows participants only for a
/// user-created pair/group Quest that actually has them — built-in
/// templates stay simple. See design system §15.
class QuestCard extends ConsumerWidget {
  const QuestCard({super.key, required this.quest, required this.onTap});

  final Quest quest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showsParticipants = quest.type != 'solo' && quest.creatorId != null;
    final participants = showsParticipants
        ? ref.watch(questParticipantsViewModelProvider(quest.id))
        : null;

    return AppCard(
      onTap: onTap,
      color: AppColors.softPeach,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: quest.coverImagePath != null
                ? Image.file(File(quest.coverImagePath!), fit: BoxFit.cover)
                : const _QuestCoverPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: AppTypography.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                participants?.maybeWhen(
                      data: (people) => people.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: ParticipantAvatarStack(
                                people: people.map((p) => p.person).toList(),
                                radius: 12,
                              ),
                            ),
                      orElse: () => const SizedBox.shrink(),
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCoverPlaceholder extends StatelessWidget {
  const _QuestCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.filmYellow,
      child: Center(
        child: Icon(
          Icons.camera_alt_rounded,
          size: 32,
          color: AppColors.warmCharcoal,
        ),
      ),
    );
  }
}
