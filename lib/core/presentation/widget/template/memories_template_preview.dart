import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/memories/memory_list_view_model.dart';
import '../molecules/app_widget_preview.dart';
import 'memories_template.dart';
import 'preview_samples.dart';

Widget _memories(AsyncValue<List<MemoryMonth>> months) {
  return AppWidgetPreview(
    child: MemoriesTemplate(
      months: months,
      onRetry: () {},
      onStartQuest: () {},
      onOpenMemory: (_) {},
    ),
  );
}

@Preview(name: 'Memories — album', group: 'templates', size: previewPhoneSize)
Widget memoriesTemplatePreview() =>
    _memories(AsyncData(PreviewSamples.memoryMonths));

@Preview(name: 'Memories — empty', group: 'templates', size: previewPhoneSize)
Widget memoriesTemplateEmptyPreview() => _memories(const AsyncData([]));

@Preview(name: 'Memories — loading', group: 'templates', size: previewPhoneSize)
Widget memoriesTemplateLoadingPreview() => _memories(const AsyncLoading());
