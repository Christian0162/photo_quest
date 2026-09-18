import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/entities/person.dart';
import 'person_avatar.dart';

/// Overlapping "👤 👤 👤 +2" avatar row used to show quest participants at
/// a glance. See design system §15, §21.
class ParticipantAvatarStack extends StatelessWidget {
  const ParticipantAvatarStack({
    super.key,
    required this.people,
    this.radius = 16,
    this.max = 4,
  });

  final List<Person> people;
  final double radius;
  final int max;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    final shown = people.take(max).toList();
    final overflow = people.length - shown.length;
    final overlap = radius * 0.9;

    return SizedBox(
      height: radius * 2,
      width: radius * 2 + overlap * shown.length + (overflow > 0 ? overlap : 0),
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: overlap * i,
              child: _ringed(PersonAvatar(person: shown[i], radius: radius)),
            ),
          if (overflow > 0)
            Positioned(
              left: overlap * shown.length,
              child: _ringed(
                CircleAvatar(
                  radius: radius,
                  backgroundColor: AppColors.warmCharcoal,
                  child: Text(
                    '+$overflow',
                    style: AppTypography.bodyMuted.copyWith(
                      color: AppColors.warmCream,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ringed(Widget avatar) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.warmCream, width: 2),
      ),
      child: avatar,
    );
  }
}
