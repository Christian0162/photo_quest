/// Client-side checks that give instant, friendly feedback. They mirror the
/// rules configured on the Supabase project; the server stays the authority.
abstract final class AuthValidators {
  static const minPasswordLength = 8;
  static const codeLength = 6;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  static String? email(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Enter your email address.';
    if (!_email.hasMatch(email)) return "That doesn't look like an email yet.";
    return null;
  }

  static String? newPassword(String value) {
    if (value.isEmpty) return 'Choose a password.';
    if (value.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters.';
    }
    if (!value.contains(RegExp('[A-Za-z]')) ||
        !value.contains(RegExp('[0-9]'))) {
      return 'Mix letters and numbers.';
    }
    return null;
  }

  static String? passwordMatch(String password, String confirmation) {
    if (confirmation.isEmpty) return 'Type your password once more.';
    if (confirmation != password) return "The passwords don't match yet.";
    return null;
  }

  static String? code(String value) {
    final code = value.trim();
    if (code.isEmpty) return 'Enter the code from your email.';
    if (!RegExp('^[0-9]{$codeLength}\$').hasMatch(code)) {
      return 'The code is $codeLength digits.';
    }
    return null;
  }
}
