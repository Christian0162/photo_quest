/// What an invite code looks like and how forgiving we are typing one: spaces,
/// dashes and lowercase are fine. The server does the real checking.
abstract final class InviteCode {
  static const length = 10;

  /// Uppercase, with spaces and dashes removed.
  static String normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

  /// A friendly hint, or null when the code is complete.
  static String? validate(String input) {
    final code = normalize(input);
    if (code.isEmpty) return 'Enter the code your friend sent you.';
    if (code.length != length) return 'A code has $length letters and numbers.';
    return null;
  }

  /// `ABCDE-FGHJK`, easier to read and to say aloud.
  static String format(String code) {
    final plain = normalize(code);
    if (plain.length != length) return code;
    return '${plain.substring(0, 5)}-${plain.substring(5)}';
  }
}
