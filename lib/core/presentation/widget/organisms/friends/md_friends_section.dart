import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/friends/entities/friend.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_skeleton_box.dart';
import '../../molecules/common/md_app_card.dart';
import '../../molecules/common/md_section_header.dart';

/// Real people on Photo Quest, above the people and pets kept on this phone:
/// friends you can invite straight to a quest or memory, requests waiting for
/// your answer, and requests you're waiting on. Added with a friend code, and
/// only once they accept.
class MdFriendsSection extends StatelessWidget {
  const MdFriendsSection({
    super.key,
    required this.friends,
    required this.onAddFriend,
    required this.onRespond,
    required this.onRemove,
    required this.onRetry,
  });

  final AsyncValue<List<Friend>> friends;
  final VoidCallback onAddFriend;
  final void Function(Friend friend, {required bool accept}) onRespond;
  final ValueChanged<Friend> onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MdSectionHeader(
          title: 'Friends on Photo Quest',
          subtitle:
              'Real people you can invite straight to quests and '
              'memories.',
          trailing: TextButton.icon(
            onPressed: onAddFriend,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              size: AppIconSizes.md,
            ),
            label: const Text('Add a friend'),
          ),
        ),
        const SizedBox(height: AppSpacing.ms),
        friends.when(
          loading: () =>
              const MdSkeletonBox(height: 64, radius: AppRadius.base),
          error: (error, stack) => Row(
            children: [
              Expanded(
                child: Text(
                  "Can't reach your friends right now.",
                  style: AppTypography.bodyMuted,
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return Text(
                'No friends yet. Share your friend code, or enter theirs.',
                style: AppTypography.bodyMuted,
              );
            }
            return Column(
              children: [
                for (final friend in list) ...[
                  _FriendRow(
                    friend: friend,
                    onRespond: onRespond,
                    onRemove: onRemove,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({
    required this.friend,
    required this.onRespond,
    required this.onRemove,
  });

  final Friend friend;
  final void Function(Friend friend, {required bool accept}) onRespond;
  final ValueChanged<Friend> onRemove;

  @override
  Widget build(BuildContext context) {
    final url = friend.avatarUrl;
    final avatar = ExcludeSemantics(
      child: CircleAvatar(
        radius: AppIconSizes.lg,
        backgroundColor: AppColors.softPeach,
        foregroundImage: url == null ? null : NetworkImage(url),
        child: Text(
          friend.name.characters.first.toUpperCase(),
          style: AppTypography.label,
        ),
      ),
    );

    return switch (friend.status) {
      FriendStatus.requestedMe => MdAppCard(
        color: AppColors.softPeach,
        elevated: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                avatar,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '${friend.name} wants to connect',
                    style: AppTypography.heading3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                MdPrimaryButton(
                  label: 'Accept',
                  expand: false,
                  onPressed: () => onRespond(friend, accept: true),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: () => onRespond(friend, accept: false),
                  child: const Text('Not now'),
                ),
              ],
            ),
          ],
        ),
      ),
      FriendStatus.friend || FriendStatus.requestedByMe => MdAppCard(
        child: Row(
          children: [
            avatar,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.name, style: AppTypography.heading3),
                  Text(
                    friend.isFriend ? 'Friend' : 'Request sent',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: friend.isFriend
                  ? 'Remove ${friend.name} from your friends'
                  : 'Cancel the request to ${friend.name}',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => onRemove(friend),
            ),
          ],
        ),
      ),
    };
  }
}
