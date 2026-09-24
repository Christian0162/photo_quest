import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../types/quests/quest_detail.dart';
import '../../types/quests/quest_participant_with_person.dart';
import '../../types/quests/quest_start_readiness.dart';
import '../molecules/md_app_widget_preview.dart';
import 'preview_samples.dart';
import 'quest_intro_template.dart';

Widget _intro({
  required AsyncValue<QuestDetail> detail,
  List<QuestParticipantWithPerson> participants = const [],
  QuestStartReadiness readiness = const QuestStartReadiness(canStart: true),
  bool isStarting = false,
}) {
  return MdAppWidgetPreview(
    child: QuestIntroTemplate(
      detail: detail,
      participants: AsyncData(participants),
      readiness: readiness,
      isStarting: isStarting,
      onRetry: () {},
      onStart: () {},
      onInvite: () {},
      onConfirmParticipant: (_) {},
      onRemoveParticipant: (_) {},
    ),
  );
}

@Preview(
  name: 'Quest Intro — pair, ready',
  group: 'templates',
  size: previewPhoneSize,
)
Widget questIntroTemplatePreview() =>
    _intro(detail: AsyncData(PreviewSamples.questDetail));

@Preview(
  name: 'Quest Intro — group, waiting on Dad',
  group: 'templates',
  size: previewPhoneSize,
)
Widget questIntroTemplateWaitingPreview() => _intro(
  detail: AsyncData(PreviewSamples.groupQuestDetail),
  participants: PreviewSamples.familyParticipants,
  readiness: const QuestStartReadiness(
    canStart: false,
    hint: 'Everyone taps "I\'m in" before you start.',
  ),
);

@Preview(
  name: 'Quest Intro — starting',
  group: 'templates',
  size: previewPhoneSize,
)
Widget questIntroTemplateStartingPreview() =>
    _intro(detail: AsyncData(PreviewSamples.questDetail), isStarting: true);

@Preview(
  name: 'Quest Intro — unavailable',
  group: 'templates',
  size: previewPhoneSize,
)
Widget questIntroTemplateErrorPreview() =>
    _intro(detail: AsyncError(Exception('missing'), StackTrace.empty));
