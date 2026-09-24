import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/presentation/view_model/memories/keepsake_view_model.dart';
import 'package:photoquest/core/presentation/view_model/memories/memory_detail_view_model.dart';
import 'package:photoquest/core/presentation/widget/molecules/app_widget_preview.dart';
import 'package:photoquest/core/presentation/widget/organisms/keepsake_canvas.dart';
import 'package:photoquest/core/presentation/widget/templates/memory_detail_template.dart';
import 'package:photoquest/core/presentation/widget/templates/preview_samples.dart';

void main() {
  final sample = PreviewSamples.memoryDetail;
  final withPrint = MemoryDetail(
    memory: sample.memory,
    photos: sample.photos,
    people: sample.people,
    questId: sample.questId,
    // The print that was kept, e.g. a grid.
    stripPath: 'kept-grid.jpg',
  );

  Future<void> show(WidgetTester tester, KeepsakeDesign keepsake) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AppWidgetPreview(
        child: MemoryDetailTemplate(
          memoryId: sample.memory.id,
          detail: AsyncData(withPrint),
          keepsake: keepsake,
          onOpenPhoto: (_, _) {},
          onRetry: () {},
          onShare: (_) {},
          onDoAgain: (_) {},
          onDecorate: () {},
          onDownloadStrip: () {},
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a print kept before designs were saved shows as kept', (
    tester,
  ) async {
    // No saved design: the live print would be a default strip, not the
    // grid that was actually kept.
    await show(tester, PreviewSamples.keepsake.copyWith(isSaved: false));
    expect(find.byType(KeepsakeCanvas), findsNothing);
  });

  testWidgets('a saved design plays live in its own layout', (tester) async {
    await show(tester, PreviewSamples.gridKeepsake.copyWith(isSaved: true));
    final canvas = tester.widget<KeepsakeCanvas>(find.byType(KeepsakeCanvas));
    expect(canvas.design.layout, KeepsakeLayout.grid);
    expect(canvas.live, isTrue);
  });
}
