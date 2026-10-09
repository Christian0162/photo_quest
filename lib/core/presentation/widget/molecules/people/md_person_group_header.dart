import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/display_labels.dart';

class MdPersonGroupHeader extends StatelessWidget {
  const MdPersonGroupHeader({
    super.key,
    required this.type,
    required this.count,
  });

  final String type;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Icon(
            personTypeIcon(type),
            size: AppIconSizes.md,
            color: AppColors.coralInk,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              personGroupLabel(type),
              style: AppTypography.heading3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('$count', style: AppTypography.caption),
        ],
      ),
    );
  }
}
