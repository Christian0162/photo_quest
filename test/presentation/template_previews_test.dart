import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/presentation/widget/template/capture_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/create_quest_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/home_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/keepsake_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/memories_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/memory_detail_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/memory_reveal_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/people_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/quest_intro_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/quest_selection_template_preview.dart';
import 'package:photoquest/core/presentation/widget/template/settings_template_preview.dart';

/// Every template renders from its preview sample data without providers —
/// catches a template or sample that no longer fits together.
void main() {
  final previews = <String, Widget Function()>{
    'home': homeTemplatePreview,
    'home first day': homeTemplateFirstDayPreview,
    'home loading': homeTemplateLoadingPreview,
    'quest selection': questSelectionTemplatePreview,
    'quest selection empty': questSelectionTemplateEmptyPreview,
    'quest selection error': questSelectionTemplateErrorPreview,
    'quest intro': questIntroTemplatePreview,
    'quest intro waiting': questIntroTemplateWaitingPreview,
    'quest intro starting': questIntroTemplateStartingPreview,
    'quest intro error': questIntroTemplateErrorPreview,
    'create quest': createQuestTemplatePreview,
    'create quest who': createQuestTemplateWhoPreview,
    'create quest shots': createQuestTemplateShotsPreview,
    'create quest review': createQuestTemplateReviewPreview,
    'capture instruction': captureTemplateInstructionPreview,
    'capture countdown': captureTemplateCountdownPreview,
    'capture pose idea': captureTemplatePoseIdeaPreview,
    'capture GIF burst': captureTemplateGifPreview,
    'capture 360 recording': captureTemplateOrbitPreview,
    'capture processing': captureTemplateProcessingPreview,
    'capture boomerang hold': captureTemplateBoomerangHoldPreview,
    'keepsake strip': keepsakeTemplatePreview,
    'keepsake grid': keepsakeTemplateGridPreview,
    'keepsake polaroid': keepsakeTemplatePolaroidPreview,
    'keepsake loading': keepsakeTemplateLoadingPreview,
    'capture captured': captureTemplateCapturedPreview,
    'capture permission': captureTemplatePermissionPreview,
    'memory reveal': memoryRevealTemplatePreview,
    'memory reveal loading': memoryRevealTemplateLoadingPreview,
    'memories': memoriesTemplatePreview,
    'memories empty': memoriesTemplateEmptyPreview,
    'memories loading': memoriesTemplateLoadingPreview,
    'memory detail': memoryDetailTemplatePreview,
    'memory detail error': memoryDetailTemplateErrorPreview,
    'people': peopleTemplatePreview,
    'people empty': peopleTemplateEmptyPreview,
    'settings': settingsTemplatePreview,
  };

  for (final MapEntry(key: name, value: preview) in previews.entries) {
    testWidgets('$name preview renders', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(preview());
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });
  }
}
