import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/people/entities/person.dart';
import '../../../types/display_labels.dart';
import '../../atoms/people/md_ringed_avatar.dart';
import '../../molecules/common/md_app_card.dart';

/// A small photo-print: the face first, the name written underneath.
class MdPersonTile extends StatelessWidget {
  const MdPersonTile({super.key, required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.ms,
      ),
      semanticLabel: '${person.name}, ${personTypeLabel(person.type)}',
      child: Column(
        children: [
          MdRingedAvatar(person: person, radius: 32, ring: AppColors.sunken),
          const SizedBox(height: AppSpacing.sm),
          Text(
            person.name,
            style: AppTypography.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
