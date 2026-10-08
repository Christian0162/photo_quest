import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../domain/friends/entities/friend.dart';
import '../../../../domain/people/entities/person.dart';
import '../../atoms/common/md_fade_slide_in.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_round_icon_button.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../molecules/common/md_page_header.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/friends/md_friends_section.dart';
import '../../organisms/people/md_people_groups.dart';
import '../../molecules/people/md_people_skeleton.dart';

/// The people (and pets) your quests and memories are about, grouped the
/// way life groups them — your person, family, friends, pets. Above them,
/// real friends on Photo Quest, added with a friend code and only once they
/// accept. Private: not a social directory. See CLAUDE.md §40, design system
/// §20.
class PeopleTemplate extends StatelessWidget {
  const PeopleTemplate({
    super.key,
    required this.people,
    required this.onRetry,
    required this.onRefresh,
    required this.onAddPerson,
    required this.friends,
    required this.onAddFriend,
    required this.onRespondToFriend,
    required this.onRemoveFriend,
    required this.onRetryFriends,
  });

  final AsyncValue<List<Person>> people;
  final VoidCallback onRetry;

  /// Pull down to fetch people and friends again.
  final Future<void> Function() onRefresh;
  final VoidCallback onAddPerson;

  /// Real people on Photo Quest, shown above the local people.
  final AsyncValue<List<Friend>> friends;
  final VoidCallback onAddFriend;
  final void Function(Friend friend, {required bool accept}) onRespondToFriend;
  final ValueChanged<Friend> onRemoveFriend;
  final VoidCallback onRetryFriends;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.coralInk,
        child: CustomScrollView(
          // Always scrollable, so the pull works on a short or empty page.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.md,
                AppSpacing.gutter,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: MdFadeSlideIn(
                  child: MdPageHeader(
                    overline: 'Your circle',
                    title: 'People',
                    subtitle: 'The people (and pets) your memories are about.',
                    trailing: MdRoundIconButton(
                      icon: Icons.person_add_alt_1_rounded,
                      tooltip: 'Add someone',
                      backgroundColor: AppColors.warmCoral,
                      foregroundColor: AppColors.onCoral,
                      onPressed: onAddPerson,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.xl,
              ),
              sliver: SliverToBoxAdapter(
                child: MdFadeSlideIn(
                  order: 1,
                  child: MdFriendsSection(
                    friends: friends,
                    onAddFriend: onAddFriend,
                    onRespond: onRespondToFriend,
                    onRemove: onRemoveFriend,
                    onRetry: onRetryFriends,
                  ),
                ),
              ),
            ),
            ...people.when(
              loading: () => [
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                  sliver: SliverToBoxAdapter(child: MdPeopleSkeleton()),
                ),
              ],
              error: (error, stack) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: MdEmptyState.error(
                    title: "We couldn't load your people",
                    onRetry: onRetry,
                  ),
                ),
              ],
              data: (list) => list.isEmpty
                  ? [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: MdEmptyState(
                          icon: Icons.people_alt_rounded,
                          title: 'Who do you make memories with?',
                          message:
                              'Add your partner, family, friends — or your '
                              'dog. You can invite them to quests.',
                          action: MdPrimaryButton(
                            label: 'Add someone',
                            icon: Icons.person_add_alt_1_rounded,
                            expand: false,
                            onPressed: onAddPerson,
                          ),
                        ),
                      ),
                    ]
                  : [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutter,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: MdPeopleGroups(
                            people: list,
                            onAddPerson: onAddPerson,
                          ),
                        ),
                      ),
                    ],
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.tabScrollEnd),
            ),
          ],
        ),
      ),
    );
  }
}
