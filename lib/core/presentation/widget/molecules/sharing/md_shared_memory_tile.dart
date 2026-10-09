import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/sharing/entities/shared_memory.dart';
import '../../atoms/sharing/md_network_photo.dart';
import '../common/md_app_card.dart';

/// A memory a friend shared: its picture, title, and who it came from.
class MdSharedMemoryTile extends StatelessWidget {
  const MdSharedMemoryTile({
    super.key,
    required this.memory,
    required this.onTap,
  });

  final SharedMemorySummary memory;
  final VoidCallback onTap;

  static const _pictureSize = 72.0;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMMd().format(memory.capturedAt);
    final cover = memory.coverUrl;

    return MdAppCard(
      onTap: onTap,
      semanticLabel: '${memory.title}, shared by ${memory.ownerName}, $date',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox.square(
              dimension: _pictureSize,
              child: cover == null
                  ? const ColoredBox(
                      color: AppColors.sunken,
                      child: Icon(Icons.photo_outlined),
                    )
                  : MdNetworkPhoto(url: cover),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: AppTypography.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'From ${memory.ownerName}',
                  style: AppTypography.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(date, style: AppTypography.bodyMuted),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
