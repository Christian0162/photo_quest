import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../molecules/app_widget_preview.dart';
import 'preview_samples.dart';
import 'quest_selection_template.dart';
import '../../types/quests/quest_category_shelf.dart';

Widget _selection(AsyncValue<List<QuestCategoryShelf>> shelves) {
  return AppWidgetPreview(
    child: QuestSelectionTemplate(
      shelves: shelves,
      onRetry: () {},
      onCreateQuest: () {},
      onOpenQuest: (_) {},
    ),
  );
}

@Preview(
  name: 'Quest Selection — shelves',
  group: 'templates',
  size: previewPhoneSize,
)
Widget questSelectionTemplatePreview() =>
    _selection(AsyncData(PreviewSamples.questShelves));

@Preview(
  name: 'Quest Selection — empty',
  group: 'templates',
  size: previewPhoneSize,
)
Widget questSelectionTemplateEmptyPreview() => _selection(const AsyncData([]));

@Preview(
  name: 'Quest Selection — error',
  group: 'templates',
  size: previewPhoneSize,
)
Widget questSelectionTemplateErrorPreview() =>
    _selection(AsyncError(Exception('offline'), StackTrace.empty));
