import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/auth/auth_form_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import 'md_auth_sheet.dart';

/// Log in, inside the welcome drawer. One obvious button; "forgot password"
/// and "create account" stay within reach but quiet.
class MdLoginForm extends StatelessWidget {
  const MdLoginForm({
    super.key,
    required this.scrollController,
    required this.form,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onToggleShowPassword,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  final ScrollController scrollController;
  final LoginFormState form;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onToggleShowPassword;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return MdAuthSheetPage(
      scrollController: scrollController,
      action: MdPrimaryButton(
        flat: true,
        foregroundColor: Colors.white,
        label: 'Log in',
        loading: form.busy,
        onPressed: form.busy ? null : onSubmit,
      ),
      children: [
        Semantics(
          header: true,
          child: const Text('Welcome back', style: AppTypography.heading1),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Log in to pick up your quests and memories.',
          style: AppTypography.bodyMuted,
        ),
        const SizedBox(height: AppSpacing.lg),
        MdAuthTextField(
          label: 'Email',
          initialValue: form.email,
          onChanged: onEmailChanged,
          errorText: form.emailError,
          enabled: !form.busy,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        MdAuthTextField(
          label: 'Password',
          initialValue: form.password,
          onChanged: onPasswordChanged,
          errorText: form.passwordError,
          enabled: !form.busy,
          obscured: !form.showPassword,
          onToggleObscured: onToggleShowPassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmit,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: form.busy ? null : onForgotPassword,
            child: const Text('Forgot your password?'),
          ),
        ),
        if (form.error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          MdAuthMessage.error(form.error!),
        ],
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('New here?'),
            TextButton(
              onPressed: form.busy ? null : onCreateAccount,
              child: const Text('Create account'),
            ),
          ],
        ),
      ],
    );
  }
}
