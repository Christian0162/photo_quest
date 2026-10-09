import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/people/entities/person.dart';
import '../../atoms/people/md_ringed_avatar.dart';
import '../../molecules/common/md_app_card.dart';
import '../../atoms/common/md_icon_chip.dart';

/// The device owner, shown as the centre of the circle rather than one
/// more tile.
class MdSelfCard extends StatelessWidget {
  const MdSelfCard({super.key, required this.person, required this.circleSize});

  final Person person;
  final int circleSize;

  @override
  Widget build(BuildContext context) {
    final circle = switch (circleSize) {
      0 => 'Just you, for now',
      1 => '1 person in your circle',
      _ => '$circleSize people in your circle',
    };

    return MdAppCard(
      color: AppColors.softPeach,
      elevated: false,
      radius: AppRadius.xl,
      semanticLabel: '${person.name}, you. $circle',
      child: Row(
        children: [
          MdRingedAvatar(person: person, radius: 30, ring: AppColors.paper),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: AppTypography.heading2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(circle, style: AppTypography.bodyMuted),
              ],
            ),
          ),
          const MdIconChip(label: "That's you", icon: Icons.favorite_rounded),
        ],
      ),
    );
  }
}
