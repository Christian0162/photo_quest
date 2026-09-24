import 'package:flutter/material.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../domain/people/entities/person.dart';
import 'person_avatar.dart';

/// [PersonAvatar] inside a soft ring, like a photo in a round frame.
class RingedAvatar extends StatelessWidget {
  const RingedAvatar({super.key, 
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
      child: PersonAvatar(person: person, radius: radius),
    );
  }
}
