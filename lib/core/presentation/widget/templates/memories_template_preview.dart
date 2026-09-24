import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/memories/enum/memory_filter.dart';
import '../../types/memories/memory_box.dart';
import '../molecules/md_app_widget_preview.dart';
import 'memories_template.dart';
import 'preview_samples.dart';

Widget _memories(AsyncValue<MemoryBox> box) {
  return MdAppWidgetPreview(
    child: MemoriesTemplate(
      box: box,
      now: PreviewSamples.today,
      onFilterChanged: (_) {},
      onRetry: () {},
      onStartQuest: () {},
      onOpenMemory: (_) {},
      onViewPhoto: (_, _) {},
    ),
  );
}

@Preview(name: 'Memories — album', group: 'templates', size: previewPhoneSize)
Widget memoriesTemplatePreview() =>
    _memories(AsyncData(PreviewSamples.memoryBox()));

@Preview(
  name: 'Memories — this day',
  group: 'templates',
  size: previewPhoneSize,
)
Widget memoriesTemplateThisDayPreview() =>
    _memories(AsyncData(PreviewSamples.memoryBox(MemoryFilter.thisDay)));

@Preview(name: 'Memories — empty', group: 'templates', size: previewPhoneSize)
Widget memoriesTemplateEmptyPreview() => _memories(
  AsyncData(MemoryBox.from(const [], MemoryFilter.allJourney, DateTime(2026))),
);

@Preview(name: 'Memories — loading', group: 'templates', size: previewPhoneSize)
Widget memoriesTemplateLoadingPreview() => _memories(const AsyncLoading());
