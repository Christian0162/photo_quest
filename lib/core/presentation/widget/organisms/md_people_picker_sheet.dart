import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/entities/person.dart';
import '../../types/display_labels.dart';
import '../atoms/md_person_avatar.dart';

/// Bottom sheet for inviting one Person to a Quest. Resolves to the chosen
/// Person, or null if dismissed. See CLAUDE.md §40, design system §20, §44.
Future<Person?> showPeoplePickerSheet(
  BuildContext context, {
  required List<Person> people,
}) {
  return showModalBottomSheet<Person>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.sm,
              ),
              child: Text(
                'Invite someone to join',
                style: AppTypography.heading2,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                children: [
                  for (final person in people)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      leading: MdPersonAvatar(person: person, radius: 22),
                      title: Text(person.name),
                      subtitle: Text(personTypeLabel(person.type)),
                      trailing: const Icon(Icons.add_circle_outline_rounded),
                      onTap: () => Navigator.of(context).pop(person),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
