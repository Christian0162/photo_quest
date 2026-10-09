import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:photoquest/core/presentation/widget/atoms/common/md_sticker.dart';

void main() {
  testWidgets('a swaying sticker starts rocking after it pops in', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: MdSticker(
            label: 'Hello',
            delay: Duration(milliseconds: 100),
            sway: true,
          ),
        ),
      ),
    );

    // Let the entrance finish so the sway controller is created.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Hello'), findsOneWidget);

    // Removing it must dispose both controllers without leaking a ticker.
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
