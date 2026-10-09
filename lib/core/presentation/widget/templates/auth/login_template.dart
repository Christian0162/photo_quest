import 'package:flutter/material.dart';

import '../../../types/auth/auth_form_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import '../../organisms/auth/md_auth_layout.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// Log in. One obvious button; "forgot password" and "create account" stay
/// within reach but quiet.
class LoginTemplate extends StatelessWidget {
  const LoginTemplate({
    super.key,
    required this.form,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onToggleShowPassword,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onCreateAccount,
    required this.onBack,
  });

  final LoginFormState form;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onToggleShowPassword;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      safeArea: false,
      bottomAction: MdPrimaryButton(
        label: 'Log in',
        loading: form.busy,
        onPressed: form.busy ? null : onSubmit,
      ),
      body: MdAuthLayout(
        title: 'Welcome back',
        subtitle: 'Log in to pick up your quests and memories.',
        busy: form.busy,
        onBack: onBack,
        footer: Wrap(
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
          if (form.error != null) MdAuthMessage.error(form.error!),
        ],
      ),
    );
  }
}
