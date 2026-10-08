import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/errors/app_failure.dart';
import 'package:photoquest/core/presentation/view_model/camera/moment_capture_view_model.dart';
import 'package:photoquest/core/presentation/widget/templates/moment_capture_template.dart';
import 'package:photoquest/core/presentation/widget/templates/moment_viewer_template.dart';
import 'package:photoquest/core/presentation/widget/templates/preview_samples.dart';

// A 1x1 transparent PNG, enough for Image.memory to decode.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

MomentCaptureTemplate _capture(
  AsyncValue<MomentCaptureState> state, {
  ValueChanged<String>? onAdd,
  VoidCallback? onRetake,
  VoidCallback? onRetry,
}) {
  return MomentCaptureTemplate(
    capture: state,
    onClose: () {},
    onRetry: onRetry ?? () {},
    onTakePhoto: () {},
    onSwitchCamera: () {},
    onRetake: onRetake ?? () {},
    onAdd: onAdd ?? (_) {},
  );
}

void main() {
  testWidgets('after the photo, a few words and "Add to Your Day"', (
    tester,
  ) async {
    String? added;
    var retook = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: _capture(
          AsyncData(MomentCaptureState(photo: _png)),
          onAdd: (caption) => added = caption,
          onRetake: () => retook = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Sunset walk');
    await tester.tap(find.text('Add to Your Day'));
    expect(added, 'Sunset walk');

    await tester.tap(find.text('Retake'));
    expect(retook, isTrue);
  });

  testWidgets('a camera that cannot start says so kindly and offers a retry', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: _capture(
          AsyncError(const CameraPermissionFailure(), StackTrace.empty),
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camera access needed'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);

    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });

  testWidgets('a moment shows its words and how long it has left', (
    tester,
  ) async {
    final removed = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MomentViewerTemplate(
          moments: PreviewSamples.dayMoments,
          initialIndex: 0,
          now: PreviewSamples.today,
          onClose: () {},
          onDelete: (moment) => removed.add(moment.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coffee with Jamie'), findsOneWidget);
    expect(find.text('19h left'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove this moment'));
    expect(removed, ['m-coffee']);
  });
}
