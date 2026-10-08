import '../../../domain/auth/auth_validators.dart';

/// Sentinel so `copyWith(error: null)` can clear a message.
const _keep = Object();

/// Log in form. Errors show once the person has tried to submit.
class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.showPassword = false,
    this.showErrors = false,
    this.busy = false,
    this.error,
  });

  final String email;
  final String password;
  final bool showPassword;
  final bool showErrors;
  final bool busy;

  /// Something the server said, shown above the button.
  final String? error;

  String? get emailError => showErrors ? AuthValidators.email(email) : null;
  String? get passwordError =>
      showErrors && password.isEmpty ? 'Enter your password.' : null;
  bool get isValid =>
      AuthValidators.email(email) == null && password.isNotEmpty;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? showPassword,
    bool? showErrors,
    bool? busy,
    Object? error = _keep,
  }) => LoginFormState(
    email: email ?? this.email,
    password: password ?? this.password,
    showPassword: showPassword ?? this.showPassword,
    showErrors: showErrors ?? this.showErrors,
    busy: busy ?? this.busy,
    error: identical(error, _keep) ? this.error : error as String?,
  );
}

/// Create account form.
class RegisterFormState {
  const RegisterFormState({
    this.email = '',
    this.password = '',
    this.confirmation = '',
    this.showPassword = false,
    this.showErrors = false,
    this.busy = false,
    this.error,
  });

  final String email;
  final String password;
  final String confirmation;
  final bool showPassword;
  final bool showErrors;
  final bool busy;
  final String? error;

  String? get emailError => showErrors ? AuthValidators.email(email) : null;
  String? get passwordError =>
      showErrors ? AuthValidators.newPassword(password) : null;
  String? get confirmationError =>
      showErrors ? AuthValidators.passwordMatch(password, confirmation) : null;
  bool get isValid =>
      AuthValidators.email(email) == null &&
      AuthValidators.newPassword(password) == null &&
      AuthValidators.passwordMatch(password, confirmation) == null;

  RegisterFormState copyWith({
    String? email,
    String? password,
    String? confirmation,
    bool? showPassword,
    bool? showErrors,
    bool? busy,
    Object? error = _keep,
  }) => RegisterFormState(
    email: email ?? this.email,
    password: password ?? this.password,
    confirmation: confirmation ?? this.confirmation,
    showPassword: showPassword ?? this.showPassword,
    showErrors: showErrors ?? this.showErrors,
    busy: busy ?? this.busy,
    error: identical(error, _keep) ? this.error : error as String?,
  );
}

/// The "enter the code we emailed you" form, used to confirm a new email.
class VerifyFormState {
  const VerifyFormState({
    this.code = '',
    this.showErrors = false,
    this.busy = false,
    this.resending = false,
    this.notice,
    this.error,
  });

  final String code;
  final bool showErrors;
  final bool busy;
  final bool resending;

  /// A calm confirmation, e.g. "New code sent".
  final String? notice;
  final String? error;

  String? get codeError => showErrors ? AuthValidators.code(code) : null;
  bool get isValid => AuthValidators.code(code) == null;

  VerifyFormState copyWith({
    String? code,
    bool? showErrors,
    bool? busy,
    bool? resending,
    Object? notice = _keep,
    Object? error = _keep,
  }) => VerifyFormState(
    code: code ?? this.code,
    showErrors: showErrors ?? this.showErrors,
    busy: busy ?? this.busy,
    resending: resending ?? this.resending,
    notice: identical(notice, _keep) ? this.notice : notice as String?,
    error: identical(error, _keep) ? this.error : error as String?,
  );
}

/// "Forgot password": just the email.
class ForgotFormState {
  const ForgotFormState({
    this.email = '',
    this.showErrors = false,
    this.busy = false,
    this.error,
  });

  final String email;
  final bool showErrors;
  final bool busy;
  final String? error;

  String? get emailError => showErrors ? AuthValidators.email(email) : null;
  bool get isValid => AuthValidators.email(email) == null;

  ForgotFormState copyWith({
    String? email,
    bool? showErrors,
    bool? busy,
    Object? error = _keep,
  }) => ForgotFormState(
    email: email ?? this.email,
    showErrors: showErrors ?? this.showErrors,
    busy: busy ?? this.busy,
    error: identical(error, _keep) ? this.error : error as String?,
  );
}

/// Code + new password.
class ResetFormState {
  const ResetFormState({
    this.code = '',
    this.password = '',
    this.confirmation = '',
    this.showPassword = false,
    this.showErrors = false,
    this.busy = false,
    this.resending = false,
    this.notice,
    this.error,
  });

  final String code;
  final String password;
  final String confirmation;
  final bool showPassword;
  final bool showErrors;
  final bool busy;
  final bool resending;
  final String? notice;
  final String? error;

  String? get codeError => showErrors ? AuthValidators.code(code) : null;
  String? get passwordError =>
      showErrors ? AuthValidators.newPassword(password) : null;
  String? get confirmationError =>
      showErrors ? AuthValidators.passwordMatch(password, confirmation) : null;
  bool get isValid =>
      AuthValidators.code(code) == null &&
      AuthValidators.newPassword(password) == null &&
      AuthValidators.passwordMatch(password, confirmation) == null;

  ResetFormState copyWith({
    String? code,
    String? password,
    String? confirmation,
    bool? showPassword,
    bool? showErrors,
    bool? busy,
    bool? resending,
    Object? notice = _keep,
    Object? error = _keep,
  }) => ResetFormState(
    code: code ?? this.code,
    password: password ?? this.password,
    confirmation: confirmation ?? this.confirmation,
    showPassword: showPassword ?? this.showPassword,
    showErrors: showErrors ?? this.showErrors,
    busy: busy ?? this.busy,
    resending: resending ?? this.resending,
    notice: identical(notice, _keep) ? this.notice : notice as String?,
    error: identical(error, _keep) ? this.error : error as String?,
  );
}
