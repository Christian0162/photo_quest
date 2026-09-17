import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/preview/app_widget_preview.dart';
import '../../domain/entities/person.dart';
import '../view_models/people_list_view_model.dart';
import 'people_screen.dart';

@Preview(name: 'People — with people', group: 'screens', size: Size(390, 844))
Widget peopleScreenPreview() {
  final now = DateTime.now();
  final people = [
    Person(
      id: 'p1',
      name: 'Christian',
      type: 'self',
      createdAt: now,
      updatedAt: now,
    ),
    Person(
      id: 'p2',
      name: 'Jamie',
      type: 'partner',
      createdAt: now,
      updatedAt: now,
    ),
    Person(
      id: 'p3',
      name: 'Mom',
      type: 'family',
      createdAt: now,
      updatedAt: now,
    ),
    Person(
      id: 'p4',
      name: 'Buddy',
      type: 'pet',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  return ProviderScope(
    overrides: [peopleListProvider.overrideWith((ref) => people)],
    child: const AppWidgetPreview(child: PeopleScreen()),
  );
}

@Preview(name: 'People — empty', group: 'screens', size: Size(390, 844))
Widget peopleScreenEmptyPreview() {
  return ProviderScope(
    overrides: [peopleListProvider.overrideWith((ref) => const [])],
    child: const AppWidgetPreview(child: PeopleScreen()),
  );
}
