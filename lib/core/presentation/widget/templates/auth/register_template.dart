import 'package:flutter/material.dart';

import '../../../../domain/auth/auth_validators.dart';
import '../../../types/auth/auth_form_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import '../../organisms/auth/md_auth_layout.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// Create account: just an email and a password. A name and photo come later,
/// once they are inside.
class RegisterTemplate extends StatelessWidget {
  const RegisterTemplate({
    super.key,
    required this.form,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmationChanged,
    required this.onToggleShowPassword,
    required this.onSubmit,
    required this.onLogIn,
    required this.onBack,
  });

  final RegisterFormState form;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmationChanged;
  final VoidCallback onToggleShowPassword;
  final VoidCallback onSubmit;
  final VoidCallback onLogIn;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      safeArea: false,
      bottomAction: MdPrimaryButton(
        label: 'Create account',
        loading: form.busy,
        onPressed: form.busy ? null : onSubmit,
      ),
      body: MdAuthLayout(
        title: 'Create your Photo Quest account',
        subtitle:
            'Just an email and a password. You can add a name and photo '
            'later.',
        busy: form.busy,
        onBack: onBack,
        footer: Wrap(
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
        children: [
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
          if (form.error != null) MdAuthMessage.error(form.error!),
        ],
      ),
    );
  }
}
