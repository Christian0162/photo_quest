import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/sharing/invite_code.dart';
import '../../../types/friends/friends_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import '../../molecules/sharing/md_invite_code_card.dart';

/// Adding a real friend: swap friend codes. Your own code on top (to copy or
/// send, or replace), and a box for theirs underneath. They get a request and
/// choose whether to accept, so nobody can add you without your OK.
class MdAddFriendSheet extends StatelessWidget {
  const MdAddFriendSheet({
    super.key,
    required this.code,
    required this.form,
    required this.onCopy,
    required this.onSend,
    required this.onReset,
    required this.onRetryCode,
    required this.onCodeChanged,
    required this.onSubmit,
  });

  final FriendCodeState code;
  final AddFriendState form;
  final VoidCallback onCopy;
  final VoidCallback onSend;
  final VoidCallback onReset;
  final VoidCallback onRetryCode;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final mine = code.code;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.sm,
          AppSpacing.gutter,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text('Add a friend', style: AppTypography.heading1),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Swap friend codes. They get a request and choose whether to '
              'accept, so nobody can add you without your OK.',
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Your friend code', style: AppTypography.heading3),
            const SizedBox(height: AppSpacing.sm),
            if (mine != null)
              MdInviteCodeCard(
                code: mine,
                caption: 'Only people you give it to can find you.',
                onCopy: onCopy,
                onSend: onSend,
              )
            else if (code.loading)
              const LinearProgressIndicator(
                color: AppColors.warmCoral,
                backgroundColor: AppColors.sunken,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      code.error ?? "We couldn't load your code.",
                      style: AppTypography.body.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onRetryCode,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            if (mine != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: code.resetting ? null : onReset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    code.resetting ? 'Getting a new code…' : 'Get a new code',
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Text('Add someone', style: AppTypography.heading3),
            const SizedBox(height: AppSpacing.sm),
            MdAuthTextField(
              label: 'Their friend code',
              initialValue: form.code,
              onChanged: onCodeChanged,
              errorText: form.codeError,
              enabled: !form.busy,
              textAlign: TextAlign.center,
              style: AppTypography.heading2.copyWith(
                letterSpacing: AppSpacing.xs,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmit,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 -]')),
                LengthLimitingTextInputFormatter(InviteCode.length + 3),
                TextInputFormatter.withFunction(
                  (old, value) =>
                      value.copyWith(text: value.text.toUpperCase()),
                ),
              ],
            ),
            if (form.error != null) ...[
              const SizedBox(height: AppSpacing.md),
              MdAuthMessage.error(form.error!),
            ],
            if (form.notice != null) ...[
              const SizedBox(height: AppSpacing.md),
              MdAuthMessage.notice(form.notice!),
            ],
            const SizedBox(height: AppSpacing.md),
            MdPrimaryButton(
              label: 'Send request',
              icon: Icons.person_add_alt_1_rounded,
              loading: form.busy,
              onPressed: form.busy ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
