import 'package:flutter/material.dart';

import '../../../types/auth/auth_form_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import '../../organisms/auth/md_auth_layout.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// "Forgot your password?": ask for the email, send a code.
class ForgotPasswordTemplate extends StatelessWidget {
  const ForgotPasswordTemplate({
    super.key,
    required this.form,
    required this.onEmailChanged,
    required this.onSubmit,
    required this.onBack,
  });

  final ForgotFormState form;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      safeArea: false,
      bottomAction: MdPrimaryButton(
        label: 'Send me a code',
        loading: form.busy,
        onPressed: form.busy ? null : onSubmit,
      ),
      body: MdAuthLayout(
        title: 'Forgot your password?',
        subtitle:
            "No problem. Enter your email and we'll send you a code to "
            'choose a new one.',
        busy: form.busy,
        onBack: onBack,
        children: [
          MdAuthTextField(
            label: 'Email',
            initialValue: form.email,
            onChanged: onEmailChanged,
            errorText: form.emailError,
            enabled: !form.busy,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmit,
          ),
          if (form.error != null) MdAuthMessage.error(form.error!),
        ],
      ),
    );
  }
}
