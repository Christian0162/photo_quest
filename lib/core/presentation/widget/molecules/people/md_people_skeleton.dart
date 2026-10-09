import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../atoms/common/md_skeleton_box.dart';
import '../../molecules/common/md_tile_grid.dart';

/// Placeholder shapes that match the loaded layout, so nothing jumps.
class MdPeopleSkeleton extends StatelessWidget {
  const MdPeopleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MdSkeletonBox(height: 96, radius: AppRadius.xl),
          const SizedBox(height: AppSpacing.xl),
          const MdSkeletonBox(width: 120, height: 20),
          const SizedBox(height: AppSpacing.ms),
          MdTileGrid(
            children: [
              for (var i = 0; i < 6; i++) const MdSkeletonBox(height: 124),
            ],
          ),
        ],
      ),
    );
  }
}
