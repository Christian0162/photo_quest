import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_primary_button.dart';
import '../common/md_app_card.dart';

/// A soft nudge to bring a friend in. On a memory it offers to let a friend
/// see it; on a quest it offers to do it together.
class MdInviteFriendCard extends StatelessWidget {
  const MdInviteFriendCard({
    super.key,
    required this.onInvite,
    this.title = 'Share this memory with a friend',
    this.message =
        'They get a code and can see this memory, only this one. Nothing '
        'else of yours.',
    this.buttonLabel = 'Invite a friend',
  });

  /// The memory version.
  const MdInviteFriendCard.memory({super.key, required this.onInvite})
    : title = 'Share this memory with a friend',
      message =
          'They get a code and can see this memory, only this one. Nothing '
          'else of yours.',
      buttonLabel = 'Invite a friend';

  /// The quest version.
  const MdInviteFriendCard.quest({super.key, required this.onInvite})
    : title = 'Do this together',
      message =
          'Invite a friend with a code. Once they join they see the '
          'memories you make and can add their own photos.',
      buttonLabel = 'Invite a friend';

  final VoidCallback onInvite;
  final String title;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      color: AppColors.softPeach,
      elevated: false,
      padding: const EdgeInsets.all(AppSpacing.ml),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_1_rounded),
              const SizedBox(width: AppSpacing.ms),
              Expanded(child: Text(title, style: AppTypography.heading3)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          MdSecondaryButton(
            label: buttonLabel,
            icon: Icons.person_add_alt_1_rounded,
            expand: false,
            onPressed: onInvite,
          ),
        ],
      ),
    );
  }
}
