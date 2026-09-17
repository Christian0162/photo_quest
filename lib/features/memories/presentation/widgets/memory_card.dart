import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/photo.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.memory,
    required this.coverPhoto,
    required this.onTap,
  });

  final Memory memory;
  final Photo? coverPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: coverPhoto != null
                ? Image.file(File(coverPhoto!.thumbnailPath), fit: BoxFit.cover)
                : const _MemoryCoverPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat.yMMMd().format(memory.capturedAt),
                  style: AppTypography.bodyMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryCoverPlaceholder extends StatelessWidget {
  const _MemoryCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.softPeach,
      child: Center(
        child: Icon(
          Icons.photo_rounded,
          size: 28,
          color: AppColors.warmCharcoal,
        ),
      ),
    );
  }
}
