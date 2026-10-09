import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/auth/account_data.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_text_field.dart';
import '../../molecules/common/md_app_card.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// The signed-in person's account: photo, name, email, and a way out. Their
/// photos and memories are not part of the account — they stay on the phone.
class AccountTemplate extends StatelessWidget {
  const AccountTemplate({
    super.key,
    required this.account,
    required this.draft,
    required this.loggingOut,
    required this.deleting,
    required this.onNameChanged,
    required this.onSaveName,
    required this.onChangeAvatar,
    required this.onLogOut,
    required this.onDeleteAccount,
  });

  final AccountData account;
  final AccountNameDraft draft;
  final bool loggingOut;
  final bool deleting;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onSaveName;
  final VoidCallback onChangeAvatar;
  final VoidCallback onLogOut;
  final VoidCallback onDeleteAccount;

  static const _avatarRadius = 48.0;

  bool get _nameChanged {
    final text = draft.text;
    return text != null && text.trim() != (account.displayName ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      showAppBar: true,
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
            child: Text('Your account', style: AppTypography.heading1),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Semantics(
              button: true,
              label: 'Change your profile photo',
              child: GestureDetector(
                onTap: onChangeAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ExcludeSemantics(child: _Avatar(account: account)),
                    Positioned(
                      right: -AppSpacing.xs,
                      bottom: -AppSpacing.xs,
                      child: const CircleAvatar(
                        radius: AppIconSizes.md,
                        backgroundColor: AppColors.warmCharcoal,
                        child: Icon(
                          Icons.photo_camera_rounded,
                          size: AppIconSizes.sm,
                          color: AppColors.warmCream,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MdAuthTextField(
            label: 'Your name',
            initialValue: account.displayName ?? '',
            onChanged: onNameChanged,
            helperText: 'This is how Photo Quest greets you.',
            textInputAction: TextInputAction.done,
            onSubmitted: _nameChanged ? onSaveName : null,
          ),
          if (_nameChanged) ...[
            const SizedBox(height: AppSpacing.md),
            MdPrimaryButton(
              label: 'Save name',
              loading: draft.saving,
              onPressed: onSaveName,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          MdAppCard(
            elevated: false,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.mail_outline_rounded),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Signed in as', style: AppTypography.caption),
                      Text(account.email, style: AppTypography.body),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          MdSecondaryButton(
            label: 'Log out',
            icon: Icons.logout_rounded,
            onPressed: loggingOut || deleting ? null : onLogOut,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your photos and memories stay on this phone when you log out.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.xl),
          TextButton(
            onPressed: loggingOut || deleting ? null : onDeleteAccount,
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              deleting ? 'Deleting your account…' : 'Delete my account',
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.account});

  final AccountData account;

  @override
  Widget build(BuildContext context) {
    final url = account.avatarUrl;
    final initial = account.greetingName.characters.first.toUpperCase();

    return CircleAvatar(
      radius: AccountTemplate._avatarRadius,
      backgroundColor: AppColors.softPeach,
      foregroundImage: url == null ? null : NetworkImage(url),
      child: Text(initial, style: AppTypography.display),
    );
  }
}
