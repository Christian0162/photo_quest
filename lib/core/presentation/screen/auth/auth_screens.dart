import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../domain/auth/enum/auth_status.dart';
import '../../view_model/auth/auth_form_view_models.dart';
import '../../view_model/auth/auth_sheet_view_model.dart';
import '../../view_model/auth/auth_session_view_model.dart';
import '../../widget/organisms/auth/md_login_form.dart';
import '../../widget/organisms/auth/md_register_form.dart';
import '../../widget/templates/auth/forgot_password_template.dart';
import '../../widget/templates/auth/reset_password_template.dart';
import '../../widget/templates/auth/verify_email_template.dart';
import '../../widget/templates/auth/welcome_template.dart';

/// Welcome, with log in and create account in its drawer. Design lives in
/// [WelcomeTemplate].
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(authSheetViewModelProvider);
    final sheet = ref.read(authSheetViewModelProvider.notifier);

    return WelcomeTemplate(
      mode: mode,
      onCreateAccount: () => sheet.open(AuthSheetMode.register),
      onLogIn: () => sheet.open(AuthSheetMode.login),
      onClose: sheet.close,
      onExpandedChanged: sheet.setExpanded,
      formBuilder: (context, scrollController) => switch (mode) {
        AuthSheetMode.login => _LoginForm(scrollController: scrollController),
        _ => _RegisterForm(scrollController: scrollController),
      },
    );
  }
}

/// Log in form for the welcome drawer. Only watches its view model while
/// shown, so closing the drawer clears it.
class _LoginForm extends ConsumerWidget {
  const _LoginForm({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(loginViewModelProvider);
    final viewModel = ref.read(loginViewModelProvider.notifier);

    return MdLoginForm(
      scrollController: scrollController,
      form: form,
      onEmailChanged: viewModel.setEmail,
      onPasswordChanged: viewModel.setPassword,
      onToggleShowPassword: viewModel.toggleShowPassword,
      onSubmit: viewModel.submit,
      onForgotPassword: () => context.push(AppRoutes.forgotPassword),
      onCreateAccount: () => ref
          .read(authSheetViewModelProvider.notifier)
          .open(AuthSheetMode.register),
    );
  }
}

/// Create account form for the welcome drawer.
class _RegisterForm extends ConsumerWidget {
  const _RegisterForm({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registerViewModelProvider);
    final viewModel = ref.read(registerViewModelProvider.notifier);

    return MdRegisterForm(
      scrollController: scrollController,
      form: form,
      onEmailChanged: viewModel.setEmail,
      onPasswordChanged: viewModel.setPassword,
      onConfirmationChanged: viewModel.setConfirmation,
      onToggleShowPassword: viewModel.toggleShowPassword,
      onSubmit: viewModel.submit,
      onLogIn: () => ref
          .read(authSheetViewModelProvider.notifier)
          .open(AuthSheetMode.login),
    );
  }
}

/// Confirm email with the emailed code. Design lives in
/// [VerifyEmailTemplate].
class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authSessionViewModelProvider);
    final form = ref.watch(verifyEmailViewModelProvider);
    final viewModel = ref.read(verifyEmailViewModelProvider.notifier);

    return VerifyEmailTemplate(
      email: status is AuthAwaitingVerification ? status.email : '',
      form: form,
      onCodeChanged: viewModel.setCode,
      onSubmit: viewModel.submit,
      onResend: viewModel.resend,
      onUseDifferentEmail: viewModel.useDifferentEmail,
    );
  }
}

/// Ask for a password reset code. Design lives in [ForgotPasswordTemplate].
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(forgotPasswordViewModelProvider);
    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);

    return ForgotPasswordTemplate(
      form: form,
      onEmailChanged: viewModel.setEmail,
      onSubmit: viewModel.submit,
      onBack: () => context.pop(),
    );
  }
}

/// Choose a new password. Design lives in [ResetPasswordTemplate].
class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authSessionViewModelProvider);
    final form = ref.watch(resetPasswordViewModelProvider);
    final viewModel = ref.read(resetPasswordViewModelProvider.notifier);

    return ResetPasswordTemplate(
      email: status is AuthRecovering ? status.email : '',
      form: form,
      onCodeChanged: viewModel.setCode,
      onPasswordChanged: viewModel.setPassword,
      onConfirmationChanged: viewModel.setConfirmation,
      onToggleShowPassword: viewModel.toggleShowPassword,
      onSubmit: viewModel.submit,
      onResend: viewModel.resend,
      onCancel: viewModel.cancel,
    );
  }
}
