import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/person.dart';

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.person, this.radius = 28});

  final Person person;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = person.name.isNotEmpty ? person.name[0].toUpperCase() : '?';

    if (person.avatarPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(person.avatarPath!)),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.softPeach,
      child: Text(
        initial,
        style: AppTypography.heading3.copyWith(color: AppColors.warmCharcoal),
      ),
    );
  }
}
