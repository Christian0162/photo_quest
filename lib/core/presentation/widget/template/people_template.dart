import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/entities/person.dart';
import '../../types/display_labels.dart';
import '../atoms/person_avatar.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/app_card.dart';
import '../molecules/empty_state.dart';
import '../organisms/app_scaffold.dart';

/// The people (and pets) your quests and memories are about. Private to
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
    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text('People', style: AppTypography.display),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'The people (and pets) your memories are about.',
                          style: AppTypography.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add someone',
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    onPressed: onAddPerson,
                  ),
                ],
              ),
            ),
          ),
          ...people.when(
            loading: () => [
              _grid(
                itemCount: 6,
                builder: (_) => const SkeletonBox(height: 148),
              ),
            ],
            error: (error, stack) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState.error(
                  title: "We couldn't load your people",
                  onRetry: onRetry,
                ),
              ),
            ],
            data: (list) => list.isEmpty
                ? [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.people_alt_rounded,
                        title: 'Who do you make memories with?',
                        message:
                            'Add your partner, family, friends — or your '
                            'dog. You can invite them to quests.',
                        action: PrimaryButton(
                          label: 'Add someone',
                          icon: Icons.person_add_alt_1_rounded,
                          expand: false,
                          onPressed: onAddPerson,
                        ),
                      ),
                    ),
                  ]
                : [
                    _grid(
                      itemCount: list.length + 1,
                      builder: (index) => index == list.length
                          ? _AddPersonTile(onTap: onAddPerson)
                          : _PersonTile(person: list[index]),
                    ),
                  ],
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _grid({
    required int itemCount,
    required Widget Function(int index) builder,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 128,
          mainAxisSpacing: AppSpacing.ms,
          crossAxisSpacing: AppSpacing.ms,
          childAspectRatio: 0.78,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => builder(index),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final type = personTypeLabel(person.type);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      semanticLabel: '${person.name}, $type',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PersonAvatar(person: person, radius: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            person.name,
            style: AppTypography.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            type,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AddPersonTile extends StatelessWidget {
  const _AddPersonTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.sunken,
      elevated: false,
      semanticLabel: 'Add someone',
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.paper,
            child: Icon(Icons.add_rounded, size: AppIconSizes.xl),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add someone',
            style: AppTypography.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
