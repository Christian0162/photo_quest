/// What an invite code looks like and how forgiving we are typing one: spaces,
/// dashes and lowercase are fine. The server does the real checking.
abstract final class InviteCode {
  static const length = 10;

  static String normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

  static String? validate(String input) {
    final code = normalize(input);
    if (code.isEmpty) return 'Enter the code your friend sent you.';
    if (code.length != length) return 'A code has $length letters and numbers.';
    return null;
  }

  static String format(String code) {
    final plain = normalize(code);
    if (plain.length != length) return code;
    return '${plain.substring(0, 5)}-${plain.substring(5)}';
  }
}
