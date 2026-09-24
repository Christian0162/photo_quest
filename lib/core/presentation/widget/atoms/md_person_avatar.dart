import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/entities/person.dart';

/// A Person's photo, or their initial on a warm tint. The tint is stable
/// per person so faces are easier to tell apart at a glance; the initial
/// still carries identity on its own. Decorative for screen readers —
/// callers show the name next to it. See CLAUDE.md §40.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.person, this.radius = 28});

  final Person person;
  final double radius;

  static const _tints = [
    AppColors.softPeach,
    AppColors.filmYellow,
    AppColors.softGreen,
  ];

  @override
  Widget build(BuildContext context) {
    final avatarPath = person.avatarPath;
    final initial = person.name.trim().isNotEmpty
        ? person.name.trim()[0].toUpperCase()
        : '?';

    return ExcludeSemantics(
      child: avatarPath != null
          ? CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.softPeach,
              backgroundImage: ResizeImage(
                FileImage(File(avatarPath)),
                width: (radius * 2 * MediaQuery.devicePixelRatioOf(context))
                    .round(),
              ),
            )
          : CircleAvatar(
              radius: radius,
              backgroundColor:
                  _tints[person.id.codeUnits.fold(0, (a, b) => a + b) %
                      _tints.length],
              child: Text(
                initial,
                style: AppTypography.heading3.copyWith(fontSize: radius * 0.8),
              ),
            ),
    );
  }
}
