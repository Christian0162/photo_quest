import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../molecules/app_widget_preview.dart';
import 'memory_detail_template.dart';
import 'preview_samples.dart';
import '../../types/memories/memory_detail.dart';

Widget _detail(AsyncValue<MemoryDetail> detail) {
  return AppWidgetPreview(
    child: MemoryDetailTemplate(
      memoryId: 'memory-1',
      detail: detail,
      onOpenPhoto: (_, _) {},
      onRetry: () {},
      onShare: (_) {},
      onDoAgain: (_) {},
      onDecorate: () {},
      onDownloadStrip: () {},
    ),
  );
}

@Preview(name: 'Memory Detail', group: 'templates', size: previewPhoneSize)
Widget memoryDetailTemplatePreview() =>
    _detail(AsyncData(PreviewSamples.memoryDetail));

@Preview(
  name: 'Memory Detail — error',
  group: 'templates',
  size: previewPhoneSize,
)
Widget memoryDetailTemplateErrorPreview() =>
    _detail(AsyncError(Exception('missing'), StackTrace.empty));
