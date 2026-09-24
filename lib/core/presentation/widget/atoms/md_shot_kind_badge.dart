import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/memories/entities/photo.dart';

/// "GIF", "Boomerang", "360°" — a small label over a moving shot so it's
/// clear what it is. Icon + word, never color alone. Shows nothing for a
/// plain photo. See CLAUDE.md §65.
class MdShotKindBadge extends StatelessWidget {
  const MdShotKindBadge({super.key, required this.kind});

  /// A [PhotoKind].
  final String kind;

  static (IconData, String)? describe(String kind) => switch (kind) {
    PhotoKind.gif => (Icons.gif_box_rounded, 'GIF'),
    PhotoKind.boomerang => (Icons.all_inclusive_rounded, 'Boomerang'),
    PhotoKind.video => (Icons.threesixty_rounded, '360°'),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final described = describe(kind);
    if (described == null) return const SizedBox.shrink();
    final (icon, label) = described;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.cameraScrim,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.sm, color: AppColors.onCamera),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.onCamera),
          ),
        ],
      ),
    );
  }
}
