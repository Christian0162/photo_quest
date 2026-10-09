import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/auth/auth_validators.dart';
import '../../../types/auth/auth_form_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import '../../organisms/auth/md_auth_layout.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// Choose a new password with the code from the email.
class ResetPasswordTemplate extends StatelessWidget {
  const ResetPasswordTemplate({
    super.key,
    required this.email,
    required this.form,
    required this.onCodeChanged,
    required this.onPasswordChanged,
    required this.onConfirmationChanged,
    required this.onToggleShowPassword,
    required this.onSubmit,
    required this.onResend,
    required this.onCancel,
  });

  final String email;
  final ResetFormState form;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmationChanged;
  final VoidCallback onToggleShowPassword;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      safeArea: false,
      onBackBlocked: onCancel,
      bottomAction: MdPrimaryButton(
        label: 'Save new password',
        loading: form.busy,
        onPressed: form.busy ? null : onSubmit,
      ),
      body: MdAuthLayout(
        title: 'Choose a new password',
        subtitle:
            'Enter the ${AuthValidators.codeLength}-digit code we sent to '
            '$email, then pick a new password.',
        busy: form.busy,
        onBack: onCancel,
        footer: Column(
          children: [
            TextButton(
              onPressed: form.resending || form.busy ? null : onResend,
              child: Text(
                form.resending ? 'Sending a new code…' : 'Send a new code',
              ),
            ),
            TextButton(
              onPressed: form.busy ? null : onCancel,
              child: const Text('Back to log in'),
            ),
          ],
        ),
        children: [
          MdAuthTextField(
            label: 'Code',
            initialValue: form.code,
            onChanged: onCodeChanged,
            errorText: form.codeError,
            enabled: !form.busy,
            autofocus: true,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            style: AppTypography.heading2.copyWith(
              letterSpacing: AppSpacing.sm,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(AuthValidators.codeLength),
            ],
          ),
          MdAuthTextField(
            label: 'New password',
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
          MdAuthTextField(
            label: 'Confirm new password',
            initialValue: form.confirmation,
            onChanged: onConfirmationChanged,
            errorText: form.confirmationError,
            enabled: !form.busy,
            obscured: !form.showPassword,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmit,
          ),
          if (form.notice != null) MdAuthMessage.notice(form.notice!),
          if (form.error != null) MdAuthMessage.error(form.error!),
        ],
      ),
    );
  }
}
