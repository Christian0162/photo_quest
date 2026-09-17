import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../domain/entities/quest.dart';

class QuestCard extends StatelessWidget {
  const QuestCard({super.key, required this.quest, required this.onTap});

  final Quest quest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            child: Text(quest.title, style: AppTypography.heading3),
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
