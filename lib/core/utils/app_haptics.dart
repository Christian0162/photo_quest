import 'package:flutter/services.dart';

/// Named, consistent haptic moments so the app feels physical — like
/// pressing a real photobooth button — without buzzing on every tap. Each
/// method maps to one meaning; never call [HapticFeedback] directly. The OS
/// silences these when the person has turned vibration off.
abstract final class AppHaptics {
  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> tap() => HapticFeedback.lightImpact();

  static Future<void> tick() => HapticFeedback.selectionClick();

  static Future<void> shutter() => HapticFeedback.mediumImpact();

  static Future<void> remove() => HapticFeedback.lightImpact();

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    await HapticFeedback.lightImpact();
  }
}
