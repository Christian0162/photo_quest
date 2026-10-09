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

/// "Check your email": the person types the short code we sent to confirm the
/// address is theirs.
class VerifyEmailTemplate extends StatelessWidget {
  const VerifyEmailTemplate({
    super.key,
    required this.email,
    required this.form,
    required this.onCodeChanged,
    required this.onSubmit,
    required this.onResend,
    required this.onUseDifferentEmail,
  });

  final String email;
  final VerifyFormState form;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final VoidCallback onUseDifferentEmail;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      safeArea: false,
      onBackBlocked: onUseDifferentEmail,
      bottomAction: MdPrimaryButton(
        label: 'Confirm email',
        loading: form.busy,
        onPressed: form.busy ? null : onSubmit,
      ),
      body: MdAuthLayout(
        title: 'Check your email',
        subtitle:
            'We sent a ${AuthValidators.codeLength}-digit code to $email. '
            "Enter it below to confirm it's you. Can't see it? Look in spam.",
        busy: form.busy,
        onBack: onUseDifferentEmail,
        footer: Column(
          children: [
            TextButton(
              onPressed: form.resending || form.busy ? null : onResend,
              child: Text(
                form.resending ? 'Sending a new code…' : 'Send a new code',
              ),
            ),
            TextButton(
              onPressed: form.busy ? null : onUseDifferentEmail,
              child: const Text('Use a different email'),
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
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmit,
            textAlign: TextAlign.center,
            style: AppTypography.heading2.copyWith(
              letterSpacing: AppSpacing.sm,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(AuthValidators.codeLength),
            ],
          ),
          if (form.notice != null) MdAuthMessage.notice(form.notice!),
          if (form.error != null) MdAuthMessage.error(form.error!),
        ],
      ),
    );
  }
}
