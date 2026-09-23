import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/quests/create_quest_view_model.dart';
import '../molecules/app_widget_preview.dart';
import 'create_quest_template.dart';
import 'preview_samples.dart';

final _filledDraft = CreateQuestDraft(
  title: 'Sunday at Mom & Dad’s',
  description: 'Lunch, a walk, and one big family photo on the porch.',
  category: 'Family',
  type: 'group',
  participantIds: [PreviewSamples.mom.id, PreviewSamples.dad.id],
  shots: const [
    DraftShot(instruction: 'Everyone squeeze onto the porch'),
    DraftShot(
      instruction: 'Mom and Dad, just the two of you',
      shotType: 'candid',
    ),
  ],
);

Widget _create(CreateQuestDraft draft) {
  return AppWidgetPreview(
    child: CreateQuestTemplate(
      draft: draft,
      people: AsyncData(PreviewSamples.invitable),
      onClose: () {},
      onBack: () {},
      onContinue: () {},
      onCreate: () {},
      onTitleChanged: (_) {},
      onDescriptionChanged: (_) {},
      onCategoryChanged: (_) {},
      onTypeChanged: (_) {},
      onToggleParticipant: (_) {},
      onAddShot: (_) {},
      onRemoveShot: (_) {},
    ),
  );
}

@Preview(
  name: 'Create Quest — name it',
  group: 'templates',
  size: previewPhoneSize,
)
Widget createQuestTemplatePreview() => _create(const CreateQuestDraft());

@Preview(
  name: 'Create Quest — who joins',
  group: 'templates',
  size: previewPhoneSize,
)
Widget createQuestTemplateWhoPreview() =>
    _create(_filledDraft.copyWith(step: CreateQuestStep.who));

@Preview(
  name: 'Create Quest — photos',
  group: 'templates',
  size: previewPhoneSize,
)
Widget createQuestTemplateShotsPreview() =>
    _create(_filledDraft.copyWith(step: CreateQuestStep.shots));

@Preview(
  name: 'Create Quest — review',
  group: 'templates',
  size: previewPhoneSize,
)
Widget createQuestTemplateReviewPreview() =>
    _create(_filledDraft.copyWith(step: CreateQuestStep.review));
