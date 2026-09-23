import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../molecules/app_widget_preview.dart';
import 'home_template.dart';
import 'preview_samples.dart';

HomeTemplate _home({bool withMemories = true, bool loading = false}) {
  return HomeTemplate(
    greeting: 'Good morning',
    todayQuest: loading
        ? const AsyncLoading()
        : AsyncData(PreviewSamples.anniversary),
    pendingQuests: withMemories
        ? AsyncData(PreviewSamples.questsNeedingConfirmation)
        : const AsyncData([]),
    memories: loading
        ? const AsyncLoading()
        : AsyncData(withMemories ? PreviewSamples.memories : const []),
    onRefresh: () async {},
    onOpenSettings: () {},
    onOpenQuest: (_) {},
    onOpenMemory: (_) {},
    onSeeAllMemories: () {},
    onBrowseQuests: () {},
    onCreateQuest: () {},
  );
}

@Preview(
  name: 'Home — with memories',
  group: 'templates',
  size: previewPhoneSize,
)
Widget homeTemplatePreview() => AppWidgetPreview(child: _home());

@Preview(name: 'Home — first day', group: 'templates', size: previewPhoneSize)
Widget homeTemplateFirstDayPreview() =>
    AppWidgetPreview(child: _home(withMemories: false));

@Preview(name: 'Home — loading', group: 'templates', size: previewPhoneSize)
Widget homeTemplateLoadingPreview() =>
    AppWidgetPreview(child: _home(loading: true));
