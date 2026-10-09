import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/entities/person.dart';
import 'md_person_avatar.dart';

/// Overlapping "👤 👤 👤 +2" avatar row used to show quest participants at
/// a glance. Reads as "With Sam, Mom and 2 others" to screen readers. See
/// design system §15, §21.
class MdParticipantAvatarStack extends StatelessWidget {
  const MdParticipantAvatarStack({
    super.key,
    required this.people,
    this.radius = 16,
    this.max = 4,
    this.ringColor = AppColors.paper,
  });

  final List<Person> people;
  final double radius;
  final int max;

  /// Should match the surface the stack sits on.
  final Color ringColor;

  static String describe(List<Person> people) {
    final names = people.map((p) => p.name).toList();
    return switch (names.length) {
      0 => '',
      1 => 'With ${names[0]}',
      2 => 'With ${names[0]} and ${names[1]}',
      3 => 'With ${names[0]}, ${names[1]} and ${names[2]}',
      _ => 'With ${names[0]}, ${names[1]} and ${names.length - 2} others',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    final shown = people.take(max).toList();
    final overflow = people.length - shown.length;
    final ring = radius * 0.15;
    final size = (radius + ring) * 2;
    final step = size * 0.65;
    final count = shown.length + (overflow > 0 ? 1 : 0);

    return Semantics(
      label: describe(people),
      excludeSemantics: true,
      child: SizedBox(
        height: size,
        width: size + step * (count - 1),
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(
                left: step * i,
                child: _ringed(
                  MdPersonAvatar(person: shown[i], radius: radius),
                ),
              ),
            if (overflow > 0)
              Positioned(
                left: step * shown.length,
                child: _ringed(
                  CircleAvatar(
                    radius: radius,
                    backgroundColor: AppColors.warmCharcoal,
                    child: Text(
                      '+$overflow',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmCream,
                        fontWeight: FontWeight.w600,
                        fontSize: radius * 0.7,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _ringed(Widget avatar) {
    return Container(
      padding: EdgeInsets.all(radius * 0.15),
      decoration: BoxDecoration(color: ringColor, shape: BoxShape.circle),
      child: avatar,
    );
  }
}
