// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_form_view_models.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The log in form.

@ProviderFor(LoginViewModel)
final loginViewModelProvider = LoginViewModelProvider._();

/// The log in form.
final class LoginViewModelProvider
    extends $NotifierProvider<LoginViewModel, LoginFormState> {
  /// The log in form.
  LoginViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginViewModelHash();

  @$internal
  @override
  LoginViewModel create() => LoginViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginFormState>(value),
    );
  }
}

String _$loginViewModelHash() => r'7b3107be7c3c08c8cc47372a46ff938bc322341c';

/// The log in form.

abstract class _$LoginViewModel extends $Notifier<LoginFormState> {
  LoginFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LoginFormState, LoginFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginFormState, LoginFormState>,
              LoginFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The create account form.

@ProviderFor(RegisterViewModel)
final registerViewModelProvider = RegisterViewModelProvider._();

/// The create account form.
final class RegisterViewModelProvider
    extends $NotifierProvider<RegisterViewModel, RegisterFormState> {
  /// The create account form.
  RegisterViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerViewModelHash();

  @$internal
  @override
  RegisterViewModel create() => RegisterViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterFormState>(value),
    );
  }
}

String _$registerViewModelHash() => r'39b004affa2ccddadeb475e87dcc39d1910697c3';

/// The create account form.

abstract class _$RegisterViewModel extends $Notifier<RegisterFormState> {
  RegisterFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RegisterFormState, RegisterFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RegisterFormState, RegisterFormState>,
              RegisterFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Confirming a new email with the code Supabase sent.

@ProviderFor(VerifyEmailViewModel)
final verifyEmailViewModelProvider = VerifyEmailViewModelProvider._();

/// Confirming a new email with the code Supabase sent.
final class VerifyEmailViewModelProvider
    extends $NotifierProvider<VerifyEmailViewModel, VerifyFormState> {
  /// Confirming a new email with the code Supabase sent.
  VerifyEmailViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyEmailViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyEmailViewModelHash();

  @$internal
  @override
  VerifyEmailViewModel create() => VerifyEmailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyFormState>(value),
    );
  }
}

String _$verifyEmailViewModelHash() =>
    r'55f38550e04c8188d3608f5190f0806b3d121b16';

/// Confirming a new email with the code Supabase sent.

abstract class _$VerifyEmailViewModel extends $Notifier<VerifyFormState> {
  VerifyFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VerifyFormState, VerifyFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VerifyFormState, VerifyFormState>,
              VerifyFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Asking for a password reset code.

@ProviderFor(ForgotPasswordViewModel)
final forgotPasswordViewModelProvider = ForgotPasswordViewModelProvider._();

/// Asking for a password reset code.
final class ForgotPasswordViewModelProvider
    extends $NotifierProvider<ForgotPasswordViewModel, ForgotFormState> {
  /// Asking for a password reset code.
  ForgotPasswordViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordViewModelHash();

  @$internal
  @override
  ForgotPasswordViewModel create() => ForgotPasswordViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgotFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgotFormState>(value),
    );
  }
}

String _$forgotPasswordViewModelHash() =>
    r'1a9c4490ac2d92c3afcc3b61c84a9e10623ad3e3';

/// Asking for a password reset code.

abstract class _$ForgotPasswordViewModel extends $Notifier<ForgotFormState> {
  ForgotFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ForgotFormState, ForgotFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForgotFormState, ForgotFormState>,
              ForgotFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Choosing a new password with the emailed code.

@ProviderFor(ResetPasswordViewModel)
final resetPasswordViewModelProvider = ResetPasswordViewModelProvider._();

/// Choosing a new password with the emailed code.
final class ResetPasswordViewModelProvider
    extends $NotifierProvider<ResetPasswordViewModel, ResetFormState> {
  /// Choosing a new password with the emailed code.
  ResetPasswordViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetPasswordViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetPasswordViewModelHash();

  @$internal
  @override
  ResetPasswordViewModel create() => ResetPasswordViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetFormState>(value),
    );
  }
}

String _$resetPasswordViewModelHash() =>
    r'599659851ee44c0e928440dd33e91682b54d6044';

/// Choosing a new password with the emailed code.

abstract class _$ResetPasswordViewModel extends $Notifier<ResetFormState> {
  ResetFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ResetFormState, ResetFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ResetFormState, ResetFormState>,
              ResetFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
