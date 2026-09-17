import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/preview/app_widget_preview.dart';
import '../../domain/entities/quest.dart';
import '../view_models/quest_list_view_model.dart';
import 'quest_selection_screen.dart';

@Preview(
  name: 'Quest Selection — with quests',
  group: 'screens',
  size: Size(390, 844),
)
Widget questSelectionScreenPreview() {
  final now = DateTime.now();
  final quests = [
    Quest(
      id: 'quest-1',
      title: 'Anniversary',
      category: 'For Us',
      createdAt: now,
      updatedAt: now,
    ),
    Quest(
      id: 'quest-2',
      title: 'Date Night',
      category: 'For Us',
      createdAt: now,
      updatedAt: now,
    ),
    Quest(
      id: 'quest-3',
      title: 'Family Day',
      category: 'For Family',
      createdAt: now,
      updatedAt: now,
    ),
    Quest(
      id: 'quest-4',
      title: 'Just Me',
      category: 'For Me',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  return ProviderScope(
    overrides: [questListProvider.overrideWith((ref) => quests)],
    child: const AppWidgetPreview(child: QuestSelectionScreen()),
  );
}

@Preview(
  name: 'Quest Selection — empty',
  group: 'screens',
  size: Size(390, 844),
)
Widget questSelectionScreenEmptyPreview() {
  return ProviderScope(
    overrides: [questListProvider.overrideWith((ref) => const [])],
    child: const AppWidgetPreview(child: QuestSelectionScreen()),
  );
}
