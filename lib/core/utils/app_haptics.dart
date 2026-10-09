import 'package:flutter/services.dart';

/// Named, consistent haptic moments so the app feels physical — like
/// pressing a real photobooth button — without buzzing on every tap. Each
/// method maps to one meaning; never call [HapticFeedback] directly. The OS
/// silences these when the person has turned vibration off. See design
/// system §29, §48.
abstract final class AppHaptics {
  /// Choosing between options: chips, cards, tabs, reordering.
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// A primary action was pressed.
  static Future<void> tap() => HapticFeedback.lightImpact();

  /// Each 3-2-1 countdown beat.
  static Future<void> tick() => HapticFeedback.selectionClick();

  /// The shutter fired.
  static Future<void> shutter() => HapticFeedback.mediumImpact();

  /// Something was removed (and can be undone).
  static Future<void> remove() => HapticFeedback.lightImpact();

  /// The emotional payoff: a quest is complete, everyone is in.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    await HapticFeedback.lightImpact();
  }
}
