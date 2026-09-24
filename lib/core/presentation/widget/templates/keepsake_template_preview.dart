import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../types/memories/keepsake_design.dart';
import '../molecules/md_app_widget_preview.dart';
import 'keepsake_template.dart';
import 'preview_samples.dart';

Widget _keepsake(AsyncValue<KeepsakeDesign> design) {
  return MdAppWidgetPreview(
    child: KeepsakeTemplate(
      design: design,
      doneLabel: 'Save keepsake',
      onClose: () {},
      onRetry: () {},
      onDone: (_) {},
      onLayoutChanged: (_) {},
      onFrameChanged: (_) {},
      onAddSticker: (_) {},
      onSelectSticker: (_) {},
      onTransformSticker: (
        _, {
        required x,
        required y,
        required scale,
        required rotation,
      }) {},
      onRemoveSticker: (_) {},
    ),
  );
}

@Preview(
  name: 'Keepsake — strip with stickers',
  group: 'templates',
  size: previewPhoneSize,
)
Widget keepsakeTemplatePreview() =>
    _keepsake(AsyncData(PreviewSamples.keepsake));

@Preview(
  name: 'Keepsake — grid on film',
  group: 'templates',
  size: previewPhoneSize,
)
Widget keepsakeTemplateGridPreview() =>
    _keepsake(AsyncData(PreviewSamples.gridKeepsake));

@Preview(
  name: 'Keepsake — coral polaroid',
  group: 'templates',
  size: previewPhoneSize,
)
Widget keepsakeTemplatePolaroidPreview() =>
    _keepsake(AsyncData(PreviewSamples.polaroidKeepsake));

@Preview(name: 'Keepsake — loading', group: 'templates', size: previewPhoneSize)
Widget keepsakeTemplateLoadingPreview() => _keepsake(const AsyncLoading());
