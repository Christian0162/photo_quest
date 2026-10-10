import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/auth/auth_validators.dart';
import '../../../types/auth/auth_form_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import 'md_auth_sheet.dart';

/// Create account, inside the welcome drawer: just an email and a password.
/// A name and photo come later, once they are inside.
class MdRegisterForm extends StatelessWidget {
  const MdRegisterForm({
    super.key,
    required this.scrollController,
    required this.form,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmationChanged,
    required this.onToggleShowPassword,
    required this.onSubmit,
    required this.onLogIn,
  });

  final ScrollController scrollController;
  final RegisterFormState form;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmationChanged;
  final VoidCallback onToggleShowPassword;
  final VoidCallback onSubmit;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    return MdAuthSheetPage(
      scrollController: scrollController,
      action: MdPrimaryButton(
        flat: true,
        foregroundColor: Colors.white,
        label: 'Create account',
        loading: form.busy,
        onPressed: form.busy ? null : onSubmit,
      ),
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Create your Photo Quest account',
            style: AppTypography.heading1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Just an email and a password. You can add a name and photo later.',
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
          helperText:
              'At least ${AuthValidators.minPasswordLength} characters, '
              'with letters and numbers.',
          enabled: !form.busy,
          obscured: !form.showPassword,
          onToggleObscured: onToggleShowPassword,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        MdAuthTextField(
          label: 'Confirm password',
          initialValue: form.confirmation,
          onChanged: onConfirmationChanged,
          errorText: form.confirmationError,
          enabled: !form.busy,
          obscured: !form.showPassword,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmit,
        ),
        if (form.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          MdAuthMessage.error(form.error!),
        ],
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Already have an account?'),
            TextButton(
              onPressed: form.busy ? null : onLogIn,
              child: const Text('Log in'),
            ),
          ],
        ),
      ],
    );
  }
}
