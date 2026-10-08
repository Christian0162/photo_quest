import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/presentation/widget/organisms/memories/md_memory_journal_card.dart';
import 'package:photoquest/core/presentation/widget/templates/preview_samples.dart';

void main() {
  testWidgets('a journal card with many photos swipes, and the pill opens '
      'the photo in view', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final summary = [
      for (final month in PreviewSamples.memoryBox().months) ...month.memories,
    ].firstWhere((s) => s.photos.length > 1);

    int? viewed;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MdMemoryJournalCard(
            summary: summary,
            onOpen: () {},
            onViewPhoto: (index) => viewed = index,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('shots'));
    expect(viewed, 1);
  });
}
