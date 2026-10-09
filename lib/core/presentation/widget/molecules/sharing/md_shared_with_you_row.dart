import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../common/md_app_card.dart';

/// A way into the memories friends have shared, under the Memories header.
class MdSharedWithYouRow extends StatelessWidget {
  const MdSharedWithYouRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      onTap: onTap,
      elevated: false,
      semanticLabel: 'Shared with you. Memories friends invited you to.',
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.ms,
      ),
      child: Row(
        children: [
          const Icon(Icons.group_outlined),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shared with you', style: AppTypography.label),
                Text(
                  'Memories friends invited you to',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
