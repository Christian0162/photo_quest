import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/presentation/view_model/camera/capture_view_model.dart';
import 'package:photoquest/core/presentation/view_model/quests/create_quest_view_model.dart';
import 'package:photoquest/core/presentation/widget/molecules/app_widget_preview.dart';
import 'package:photoquest/core/presentation/widget/template/capture_template.dart';
import 'package:photoquest/core/presentation/widget/template/create_quest_template.dart';
import 'package:photoquest/core/presentation/widget/template/preview_samples.dart';

CaptureState _captureState(CapturePhase phase) => CaptureState(
  quest: PreviewSamples.anniversary,
  shots: PreviewSamples.shots,
  memoryId: 'm',
  participants: const [],
  currentIndex: 0,
  phase: phase,
  countdownValue: 3,
);

Widget _capture(CapturePhase phase, {VoidCallback? onCancel}) {
  return AppWidgetPreview(
    child: CaptureTemplate(
      capture: AsyncData(_captureState(phase)),
      onLeave: () {},
      onClose: () {},
      onRetry: () {},
      onCapture: () {},
      onCancelCountdown: onCancel ?? () {},
      onSwitchCamera: () {},
      onKeep: () {},
      onRetake: () {},
      onModeChanged: (_) {},
      onLookChanged: (_) {},
      onPoseIdea: () {},
      onHidePoseIdea: () {},
      onHoldStart: () {},
      onHoldEnd: () {},
      onOpenSettings: () {},
    ),
  );
}

Widget _shots({
  List<DraftShot> shots = const [],
  ValueChanged<DraftShot>? onAdd,
  ValueChanged<int>? onRemove,
}) {
  return AppWidgetPreview(
    child: CreateQuestTemplate(
      draft: CreateQuestDraft(
        title: 'Beach day',
        step: CreateQuestStep.shots,
        shots: shots,
      ),
      people: const AsyncData([]),
      onClose: () {},
      onBack: () {},
      onContinue: () {},
      onCreate: () {},
      onTitleChanged: (_) {},
      onDescriptionChanged: (_) {},
      onCategoryChanged: (_) {},
      onTypeChanged: (_) {},
      onToggleParticipant: (_) {},
      onAddShot: onAdd ?? (_) {},
      onRemoveShot: onRemove ?? (_) {},
      onMoveShot: (_, _) {},
    ),
  );
}

void main() {
  group('Photobooth countdown', () {
    testWidgets('keeps the instruction on screen and can be stopped', (
      tester,
    ) async {
      var cancelled = 0;
      await tester.pumpWidget(
        _capture(CapturePhase.countdown, onCancel: () => cancelled++),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text(PreviewSamples.shots.first.instruction), findsOneWidget);
      expect(find.text('Not ready? Tap anywhere to stop'), findsOneWidget);

      await tester.tap(find.text('3'));
      expect(cancelled, 1);
    });
  });

  group('Create quest shots', () {
    testWidgets('tapping a shot idea adds it without typing', (tester) async {
      final added = <DraftShot>[];
      await tester.pumpWidget(_shots(onAdd: added.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Everyone squeeze together!'));
      expect(added.single.instruction, 'Everyone squeeze together!');
      expect(added.single.shotType, 'group');
    });

    testWidgets('ideas already added are not offered again', (tester) async {
      await tester.pumpWidget(
        _shots(
          shots: const [DraftShot(instruction: 'Give your funniest face')],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ActionChip, 'Give your funniest face'),
        findsNothing,
      );
      expect(find.text('Drag to reorder'), findsNothing);
    });

    testWidgets('swiping a shot away removes it', (tester) async {
      final removed = <int>[];
      await tester.pumpWidget(
        _shots(
          shots: const [
            DraftShot(instruction: 'First'),
            DraftShot(instruction: 'Second'),
          ],
          onRemove: removed.add,
        ),
      );
      await tester.pumpAndSettle();
      // The list sits below the ideas: scroll to it like a person would.
      await tester.dragUntilVisible(
        find.text('Second'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      // …and clear of the pinned Continue bar.
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Drag to reorder'), findsOneWidget);

      await tester.fling(find.text('Second'), const Offset(-300, 0), 1500);
      await tester.pumpAndSettle();
      expect(removed, [1]);
    });
  });
}
