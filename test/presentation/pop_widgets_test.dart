import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/presentation/widget/atoms/common/md_confetti_burst.dart';
import 'package:photoquest/core/presentation/widget/atoms/common/md_primary_button.dart';
import 'package:photoquest/core/presentation/widget/atoms/common/md_sticker.dart';
import 'package:photoquest/core/presentation/widget/atoms/people/md_story_ring.dart';
import 'package:photoquest/core/presentation/widget/molecules/quests/md_surprise_card.dart';

Widget _app(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: AppTheme.light,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: app!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('a sticker pops in, settles and keeps its words', (tester) async {
    await tester.pumpWidget(_app(const MdSticker(label: 'No likes')));
    expect(find.text('No likes'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('No likes'), findsOneWidget);
  });

  testWidgets('a sticker shows at once under reduced motion', (tester) async {
    await tester.pumpWidget(
      _app(const MdSticker(label: 'No likes'), reduceMotion: true),
    );
    // No animation to wait for: one frame is enough.
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('No likes'), findsOneWidget);
  });

  testWidgets('an active story ring turns; a resting one does not', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const MdStoryRing(size: 80, child: SizedBox.expand())),
    );
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(
      _app(
        const MdStoryRing(size: 80, active: false, child: SizedBox.shrink()),
      ),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the story ring stands still under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const MdStoryRing(size: 80, child: SizedBox.expand()),
        reduceMotion: true,
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('confetti flies once and then goes away', (tester) async {
    await tester.pumpWidget(
      _app(const SizedBox.square(dimension: 300, child: MdConfettiBurst())),
    );
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('confetti draws nothing under reduced motion', (tester) async {
    await tester.pumpWidget(
      _app(
        const SizedBox.square(dimension: 300, child: MdConfettiBurst()),
        reduceMotion: true,
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the dice rolls first and only then hands over the surprise', (
    tester,
  ) async {
    var rolled = 0;
    await tester.pumpWidget(_app(MdSurpriseCard(onRoll: () => rolled++)));

    await tester.tap(find.text("Can't decide? Surprise me"));
    await tester.pump(const Duration(milliseconds: 300));
    expect(rolled, 0);

    await tester.pumpAndSettle();
    expect(rolled, 1);
  });

  testWidgets('the dice answers straight away under reduced motion', (
    tester,
  ) async {
    var rolled = 0;
    await tester.pumpWidget(
      _app(MdSurpriseCard(onRoll: () => rolled++), reduceMotion: true),
    );

    await tester.tap(find.text("Can't decide? Surprise me"));
    expect(rolled, 1);
  });

  testWidgets(
    'the primary button taps through and ignores taps while loading',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(MdPrimaryButton(label: "Let's do it", onPressed: () => taps++)),
      );
      await tester.tap(find.text("Let's do it"));
      await tester.pumpAndSettle();
      expect(taps, 1);

      await tester.pumpWidget(
        _app(
          MdPrimaryButton(
            label: "Let's do it",
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(taps, 1);
    },
  );
}
