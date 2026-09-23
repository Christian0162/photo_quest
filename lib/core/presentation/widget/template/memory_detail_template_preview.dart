import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/memories/memory_detail_view_model.dart';
import '../molecules/app_widget_preview.dart';
import 'memory_detail_template.dart';
import 'preview_samples.dart';

Widget _detail(AsyncValue<MemoryDetail> detail) {
  return AppWidgetPreview(
    child: MemoryDetailTemplate(
      detail: detail,
      onRetry: () {},
      onShare: (_) {},
      onDoAgain: (_) {},
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
