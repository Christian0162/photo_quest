import 'package:flutter_test/flutter_test.dart';

extension SettleAfterMotion on WidgetTester {
  /// Lets transitions finish without waiting for every animation to stop:
  /// the welcome card's sparkle twinkles for as long as it is on screen, so
  /// [pumpAndSettle] would never return.
  Future<void> settle() async {
    await pump();
    for (var i = 0; i < 30; i++) {
      await pump(const Duration(milliseconds: 100));
    }
  }
}
