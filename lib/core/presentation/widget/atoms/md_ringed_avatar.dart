import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../domain/people/entities/person.dart';
import 'md_person_avatar.dart';

/// [MdPersonAvatar] inside a soft ring, like a photo in a round frame.
class MdRingedAvatar extends StatelessWidget {
  const MdRingedAvatar({
    super.key,
    required this.person,
    required this.radius,
    required this.ring,
  });

  final Person person;
  final double radius;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
      child: MdPersonAvatar(person: person, radius: radius),
    );
  }
}
