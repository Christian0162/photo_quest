import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../domain/people/entities/person.dart';
import '../../atoms/common/md_fade_slide_in.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_round_icon_button.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../molecules/common/md_page_header.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/people/md_people_groups.dart';
import '../../molecules/people/md_people_skeleton.dart';

/// The people (and pets) your quests and memories are about, grouped the
/// way life groups them — your person, family, friends, pets. Private to
/// this device — not a social directory. See CLAUDE.md §40, design system
/// §20.
class PeopleTemplate extends StatelessWidget {
  const PeopleTemplate({
    super.key,
    required this.people,
    required this.onRetry,
    required this.onAddPerson,
  });

  final AsyncValue<List<Person>> people;
  final VoidCallback onRetry;
  final VoidCallback onAddPerson;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      body: CustomScrollView(
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
                  overline: 'YOUR CIRCLE',
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
    );
  }
}
