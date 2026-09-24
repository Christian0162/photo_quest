import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../molecules/app_widget_preview.dart';
import 'memory_reveal_template.dart';
import 'preview_samples.dart';
import '../../types/camera/memory_reveal_result.dart';
import '../../types/memories/keepsake_design.dart';

Widget _reveal(
  AsyncValue<MemoryRevealResult> reveal, {
  KeepsakeDesign? keepsake,
}) {
  return AppWidgetPreview(
    child: MemoryRevealTemplate(
      reveal: reveal,
      keepsake: keepsake,
      onRetry: () {},
      onKeep: (_, _) {},
      onDecorate: (_) {},
    ),
  );
}

final _result = MemoryRevealResult(
  memoryId: 'm-anniversary',
  title: 'Our Anniversary',
  capturedAt: PreviewSamples.today,
  people: [PreviewSamples.me, PreviewSamples.jamie],
  // No such file in the previewer; the strip renders as a placeholder.
  stripPath: '',
);

@Preview(name: 'Memory Reveal', group: 'templates', size: previewPhoneSize)
Widget memoryRevealTemplatePreview() => _reveal(
  AsyncData(_result),
  keepsake: PreviewSamples.keepsake.copyWith(clearSelection: true),
);

@Preview(
  name: 'Memory Reveal — printing',
  group: 'templates',
  size: previewPhoneSize,
)
Widget memoryRevealTemplateLoadingPreview() => _reveal(const AsyncLoading());
