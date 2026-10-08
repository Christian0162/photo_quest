import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/sharing/invite_code.dart';
import '../../../types/sharing/sharing_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// "Got a code?": type the code a friend sent and see the memory they shared.
class JoinMemoryTemplate extends StatelessWidget {
  const JoinMemoryTemplate({
    super.key,
    required this.form,
    required this.onCodeChanged,
    required this.onSubmit,
  });

  final JoinFormState form;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      showAppBar: true,
      bottomAction: MdPrimaryButton(
        label: 'See the memory',
        icon: Icons.photo_library_outlined,
        loading: form.busy,
        onPressed: form.busy ? null : onSubmit,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xxl,
        ),
        children: [
          Semantics(
            header: true,
            child: Text('Got a code?', style: AppTypography.heading1),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the code a friend sent you to see the memory they shared.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          MdAuthTextField(
            label: 'Invite code',
            initialValue: form.code,
            onChanged: onCodeChanged,
            errorText: form.codeError,
            enabled: !form.busy,
            autofocus: true,
            textAlign: TextAlign.center,
            style: AppTypography.heading2.copyWith(
              letterSpacing: AppSpacing.xs,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: onSubmit,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 -]')),
              LengthLimitingTextInputFormatter(InviteCode.length + 3),
              _UpperCaseFormatter(),
            ],
          ),
          if (form.error != null) ...[
            const SizedBox(height: AppSpacing.md),
            MdAuthMessage.error(form.error!),
          ],
        ],
      ),
    );
  }
}

/// Codes are shown in capitals, so type them that way.
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
