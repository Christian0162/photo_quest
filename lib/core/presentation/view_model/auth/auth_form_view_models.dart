import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/auth_repository_provider.dart';
import '../../../domain/auth/enum/auth_status.dart';
import '../../../errors/app_failure.dart';
import '../../types/auth/auth_form_states.dart';
import 'auth_session_view_model.dart';

part 'auth_form_view_models.g.dart';

const _genericError = 'Something went wrong. Please try again.';

String _messageFor(Object error) =>
    error is AppFailure ? error.message : _genericError;

/// The log in form. See CLAUDE.md §42.
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginFormState build() => const LoginFormState();

  void setEmail(String value) =>
      state = state.copyWith(email: value, error: null);

  void setPassword(String value) =>
      state = state.copyWith(password: value, error: null);

  void toggleShowPassword() =>
      state = state.copyWith(showPassword: !state.showPassword);

  Future<void> submit() async {
    if (state.busy) return;
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(busy: true, error: null);
    final repository = ref.read(authRepositoryProvider);
    final session = ref.read(authSessionViewModelProvider.notifier);
    final email = state.email.trim();
    try {
      await repository.signIn(email: email, password: state.password);
      session.completeSignIn();
    } on AuthFailure catch (failure) {
      if (failure.kind == AuthFailureKind.emailNotConfirmed) {
        // They registered but never confirmed: send a fresh code and move on.
        try {
          await repository.resendSignupCode(email);
        } on AuthFailure {
          // They can ask again on the code screen.
        }
        state = state.copyWith(busy: false);
        session.awaitVerification(email);
        return;
      }
      state = state.copyWith(busy: false, error: failure.message);
    } on Object {
      state = state.copyWith(busy: false, error: _genericError);
    }
  }
}

/// The create account form.
@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  RegisterFormState build() => const RegisterFormState();

  void setEmail(String value) =>
      state = state.copyWith(email: value, error: null);

  void setPassword(String value) =>
      state = state.copyWith(password: value, error: null);

  void setConfirmation(String value) =>
      state = state.copyWith(confirmation: value, error: null);

  void toggleShowPassword() =>
      state = state.copyWith(showPassword: !state.showPassword);

  Future<void> submit() async {
    if (state.busy) return;
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(busy: true, error: null);
    final session = ref.read(authSessionViewModelProvider.notifier);
    final email = state.email.trim();
    try {
      final outcome = await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: state.password);
      state = state.copyWith(busy: false);
      switch (outcome) {
        case SignUpOutcome.needsVerification:
          session.awaitVerification(email);
        case SignUpOutcome.signedIn:
          session.completeSignIn();
      }
    } on Object catch (error) {
      state = state.copyWith(busy: false, error: _messageFor(error));
    }
  }
}

/// Confirming a new email with the code Supabase sent.
@riverpod
class VerifyEmailViewModel extends _$VerifyEmailViewModel {
  @override
  VerifyFormState build() => const VerifyFormState();

  String? get _email {
    final status = ref.read(authSessionViewModelProvider);
    return status is AuthAwaitingVerification ? status.email : null;
  }

  void setCode(String value) =>
      state = state.copyWith(code: value, error: null, notice: null);

  Future<void> submit() async {
    final email = _email;
    if (state.busy || email == null) return;
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(busy: true, error: null, notice: null);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifySignupCode(email: email, code: state.code);
      ref.read(authSessionViewModelProvider.notifier).completeSignIn();
    } on Object catch (error) {
      state = state.copyWith(busy: false, error: _messageFor(error));
    }
  }

  Future<void> resend() async {
    final email = _email;
    if (state.resending || email == null) return;
    state = state.copyWith(resending: true, error: null, notice: null);
    try {
      await ref.read(authRepositoryProvider).resendSignupCode(email);
      state = state.copyWith(
        resending: false,
        notice: 'A new code is on its way.',
      );
    } on Object catch (error) {
      state = state.copyWith(resending: false, error: _messageFor(error));
    }
  }

  Future<void> useDifferentEmail() =>
      ref.read(authSessionViewModelProvider.notifier).cancelPending();
}

/// Asking for a password reset code.
@riverpod
class ForgotPasswordViewModel extends _$ForgotPasswordViewModel {
  @override
  ForgotFormState build() => const ForgotFormState();

  void setEmail(String value) =>
      state = state.copyWith(email: value, error: null);

  Future<void> submit() async {
    if (state.busy) return;
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(busy: true, error: null);
    final email = state.email.trim();
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetCode(email);
      state = state.copyWith(busy: false);
      ref.read(authSessionViewModelProvider.notifier).beginRecovery(email);
    } on Object catch (error) {
      state = state.copyWith(busy: false, error: _messageFor(error));
    }
  }
}

/// Choosing a new password with the emailed code.
@riverpod
class ResetPasswordViewModel extends _$ResetPasswordViewModel {
  /// A reset code works once. If the code was accepted but the new password
  /// was refused, a retry must not spend the code again.
  bool _codeAccepted = false;

  @override
  ResetFormState build() => const ResetFormState();

  String? get _email {
    final status = ref.read(authSessionViewModelProvider);
    return status is AuthRecovering ? status.email : null;
  }

  void setCode(String value) =>
      state = state.copyWith(code: value, error: null, notice: null);

  void setPassword(String value) =>
      state = state.copyWith(password: value, error: null);

  void setConfirmation(String value) =>
      state = state.copyWith(confirmation: value, error: null);

  void toggleShowPassword() =>
      state = state.copyWith(showPassword: !state.showPassword);

  Future<void> submit() async {
    final email = _email;
    if (state.busy || email == null) return;
    if (!state.isValid) {
      state = state.copyWith(showErrors: true);
      return;
    }
    state = state.copyWith(busy: true, error: null, notice: null);
    final repository = ref.read(authRepositoryProvider);
    try {
      if (!_codeAccepted) {
        await repository.verifyRecoveryCode(email: email, code: state.code);
        _codeAccepted = true;
      }
      await repository.updatePassword(state.password);
      ref.read(authSessionViewModelProvider.notifier).completeSignIn();
    } on Object catch (error) {
      state = state.copyWith(busy: false, error: _messageFor(error));
    }
  }

  Future<void> resend() async {
    final email = _email;
    if (state.resending || email == null) return;
    state = state.copyWith(resending: true, error: null, notice: null);
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetCode(email);
      _codeAccepted = false;
      state = state.copyWith(
        resending: false,
        notice: 'A new code is on its way.',
      );
    } on Object catch (error) {
      state = state.copyWith(resending: false, error: _messageFor(error));
    }
  }

  Future<void> cancel() =>
      ref.read(authSessionViewModelProvider.notifier).cancelPending();
}
