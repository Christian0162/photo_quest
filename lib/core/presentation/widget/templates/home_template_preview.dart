import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/people/enum/mood.dart';
import '../molecules/md_app_widget_preview.dart';
import 'home_template.dart';
import 'preview_samples.dart';

HomeTemplate _home({
  bool withMemories = true,
  bool loading = false,
  bool withMoments = true,
}) {
  return HomeTemplate(
    greeting: 'Good morning',
    now: PreviewSamples.today,
    todayQuest: loading
        ? const AsyncLoading()
        : AsyncData(PreviewSamples.anniversary),
    pendingQuests: withMemories
        ? AsyncData(PreviewSamples.questsNeedingConfirmation)
        : const AsyncData([]),
    memories: loading
        ? const AsyncLoading()
        : AsyncData(withMemories ? PreviewSamples.memories : const []),
    mood: withMoments ? Mood.happy : null,
    avatarId: 'animals/fox',
    moments: AsyncData(withMoments ? PreviewSamples.dayMoments : const []),
    onRefresh: () async {},
    onOpenMood: () {},
    onOpenProfile: () {},
    onAddMoment: () {},
    onOpenMoment: (_) {},
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
Widget homeTemplatePreview() => MdAppWidgetPreview(child: _home());

@Preview(name: 'Home — first day', group: 'templates', size: previewPhoneSize)
Widget homeTemplateFirstDayPreview() =>
    MdAppWidgetPreview(child: _home(withMemories: false, withMoments: false));

@Preview(name: 'Home — loading', group: 'templates', size: previewPhoneSize)
Widget homeTemplateLoadingPreview() =>
    MdAppWidgetPreview(child: _home(loading: true));
