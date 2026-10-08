import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/friends/entities/friend.dart';
import '../../../../domain/sharing/entities/shared_memory.dart';
import '../../../types/sharing/sharing_states.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/auth/md_auth_message.dart';
import '../../molecules/sharing/md_invite_code_card.dart';

/// The words on the invite sheet, so one sheet serves a memory and a quest.
class InviteSheetCopy {
  const InviteSheetCopy({
    required this.title,
    required this.explanation,
    required this.createLabel,
    required this.savingLabel,
    required this.peopleTitle,
    required this.removeTooltip,
    this.friendsTitle = 'Your friends',
  });

  final String title;
  final String explanation;
  final String createLabel;
  final String savingLabel;
  final String peopleTitle;

  /// Over the friends who can be invited straight away.
  final String friendsTitle;

  /// "Stop sharing with Bo".
  final String Function(String name) removeTooltip;

  static InviteSheetCopy memory = InviteSheetCopy(
    title: 'Invite a friend',
    explanation:
        'A friend with your code can see this memory and its photos. Only '
        'this one: the rest of your memories stay private.',
    createLabel: 'Create an invite code',
    savingLabel: 'Saving this memory online…',
    peopleTitle: 'Who can see this',
    removeTooltip: (name) => 'Stop sharing with $name',
  );

  static InviteSheetCopy quest = InviteSheetCopy(
    title: 'Do this quest together',
    explanation:
        'A friend with your code can join this quest. Once they accept they '
        'see the memories you make from it and can add their own photos. '
        'Nothing else of yours.',
    createLabel: 'Create an invite code',
    savingLabel: 'Getting your quest ready…',
    peopleTitle: "Who's taking part",
    removeTooltip: (name) => 'Remove $name from this quest',
  );
}

/// Inviting a friend, in three moments: explain, get ready and make the code
/// (with honest progress when photos go up first), and hand over the code.
/// Below it, the friends already in, each removable.
class MdInviteFriendSheet extends StatelessWidget {
  const MdInviteFriendSheet({
    super.key,
    required this.copy,
    required this.state,
    required this.onCreate,
    required this.onCopy,
    required this.onSend,
    required this.onRemoveViewer,
    this.onInviteFriend,
    this.onRemoveOnlineCopy,
  });

  final InviteSheetCopy copy;
  final ShareMemoryState state;
  final VoidCallback onCreate;
  final VoidCallback onCopy;
  final VoidCallback onSend;
  final ValueChanged<ShareViewer> onRemoveViewer;

  /// Invites a real friend straight away, with no code. When null, friends
  /// aren't offered.
  final ValueChanged<Friend>? onInviteFriend;

  /// When set, offers to take the memory's online copy away.
  final VoidCallback? onRemoveOnlineCopy;

  @override
  Widget build(BuildContext context) {
    final code = state.code;
    // Friends not already in.
    final inviteable = onInviteFriend == null
        ? const <Friend>[]
        : [
            for (final friend in state.friends)
              if (!state.viewers.any((v) => v.id == friend.id)) friend,
          ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.sm,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(copy.title, style: AppTypography.heading1),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(copy.explanation, style: AppTypography.bodyMuted),
            const SizedBox(height: AppSpacing.lg),
            if (state.error != null) ...[
              MdAuthMessage.error(state.error!),
              const SizedBox(height: AppSpacing.md),
            ],
            if (inviteable.isNotEmpty) ...[
              Text(copy.friendsTitle, style: AppTypography.heading3),
              const SizedBox(height: AppSpacing.xs),
              for (final friend in inviteable)
                _FriendInviteRow(
                  friend: friend,
                  onInvite: () => onInviteFriend!(friend),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Or share a code with someone else',
                style: AppTypography.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            switch (state.phase) {
              SharePhase.idle => MdPrimaryButton(
                label: copy.createLabel,
                icon: Icons.person_add_alt_1_rounded,
                onPressed: onCreate,
              ),
              SharePhase.saving => _Saving(
                label: copy.savingLabel,
                progress: state.progress,
              ),
              SharePhase.ready when code != null => MdInviteCodeCard(
                code: code,
                onCopy: onCopy,
                onSend: onSend,
              ),
              SharePhase.ready => const SizedBox.shrink(),
            },
            if (state.viewers.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(copy.peopleTitle, style: AppTypography.heading3),
              const SizedBox(height: AppSpacing.xs),
              for (final viewer in state.viewers)
                _PersonRow(
                  viewer: viewer,
                  removeTooltip: copy.removeTooltip(viewer.name),
                  onRemove: () => onRemoveViewer(viewer),
                ),
            ],
            if (onRemoveOnlineCopy != null && state.isOnline) ...[
              const SizedBox(height: AppSpacing.xl),
              TextButton.icon(
                onPressed: state.removing ? null : onRemoveOnlineCopy,
                icon: const Icon(Icons.cloud_off_outlined),
                label: Text(
                  state.removing
                      ? 'Removing the online copy…'
                      : 'Remove the online copy',
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FriendInviteRow extends StatelessWidget {
  const _FriendInviteRow({required this.friend, required this.onInvite});

  final Friend friend;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final url = friend.avatarUrl;
    return Row(
      children: [
        ExcludeSemantics(
          child: CircleAvatar(
            radius: AppIconSizes.md,
            backgroundColor: AppColors.softPeach,
            foregroundImage: url == null ? null : NetworkImage(url),
            child: Text(
              friend.name.characters.first.toUpperCase(),
              style: AppTypography.label,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.ms),
        Expanded(child: Text(friend.name, style: AppTypography.body)),
        Semantics(
          button: true,
          label: 'Invite ${friend.name}',
          excludeSemantics: true,
          child: OutlinedButton(
            onPressed: onInvite,
            child: const Text('Invite'),
          ),
        ),
      ],
    );
  }
}

class _Saving extends StatelessWidget {
  const _Saving({required this.label, required this.progress});

  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Semantics(
      liveRegion: true,
      label: '$label $percent percent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress == 0 ? null : progress,
              minHeight: AppSpacing.sm,
              color: AppColors.warmCoral,
              backgroundColor: AppColors.sunken,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted,
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.viewer,
    required this.removeTooltip,
    required this.onRemove,
  });

  final ShareViewer viewer;
  final String removeTooltip;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final url = viewer.avatarUrl;
    final status = viewer.status;

    return Row(
      children: [
        ExcludeSemantics(
          child: CircleAvatar(
            radius: AppIconSizes.md,
            backgroundColor: AppColors.softPeach,
            foregroundImage: url == null ? null : NetworkImage(url),
            child: Text(
              viewer.name.characters.first.toUpperCase(),
              style: AppTypography.label,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.ms),
        Expanded(child: Text(viewer.name, style: AppTypography.body)),
        if (status != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Text(status, style: AppTypography.caption),
          ),
        IconButton(
          tooltip: removeTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
