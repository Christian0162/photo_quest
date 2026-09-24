import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/entities/person.dart';
import '../../types/display_labels.dart';
import '../atoms/fade_slide_in.dart';
import '../atoms/person_avatar.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/app_card.dart';
import '../molecules/empty_state.dart';
import '../organisms/app_scaffold.dart';

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

  /// Group order on screen: closest first.
  static const _groupOrder = ['partner', 'family', 'friend', 'pet', 'other'];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
              child: FadeSlideIn(child: _Header(onAddPerson: onAddPerson)),
            ),
          ),
          ...people.when(
            loading: () => [
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                sliver: SliverToBoxAdapter(child: _LoadingPeople()),
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
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _PeopleGroups(
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

class _Header extends StatelessWidget {
  const _Header({required this.onAddPerson});

  final VoidCallback onAddPerson;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR CIRCLE', style: AppTypography.overline),
              const SizedBox(height: AppSpacing.sm),
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
        const SizedBox(width: AppSpacing.sm),
        DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppShadows.card,
          ),
          child: IconButton(
            tooltip: 'Add someone',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.warmCoral,
              foregroundColor: AppColors.onCoral,
              minimumSize: const Size.square(AppTouch.minTarget),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: onAddPerson,
          ),
        ),
      ],
    );
  }
}

/// "You" up top, then one group per relationship, then a way to add
/// someone. Built eagerly — a private circle is a handful of people — so
/// the stagger plays once instead of replaying on scroll.
class _PeopleGroups extends StatelessWidget {
  const _PeopleGroups({required this.people, required this.onAddPerson});

  final List<Person> people;
  final VoidCallback onAddPerson;

  /// Unknown types fall into "Everyone else", matching [personTypeLabel].
  static String _groupOf(Person person) =>
      PeopleTemplate._groupOrder.contains(person.type) ? person.type : 'other';

  @override
  Widget build(BuildContext context) {
    final self = people.where((p) => p.type == 'self').firstOrNull;
    final others = people.where((p) => p.type != 'self').toList();
    final groups = [
      for (final type in PeopleTemplate._groupOrder)
        (type, others.where((p) => _groupOf(p) == type).toList()),
    ].where((g) => g.$2.isNotEmpty);

    var order = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (self != null) ...[
          FadeSlideIn(
            key: ValueKey(self.id),
            order: order++,
            child: _SelfCard(person: self, circleSize: others.length),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        for (final (type, members) in groups) ...[
          FadeSlideIn(
            key: ValueKey('group-$type'),
            order: order++,
            child: _GroupHeader(type: type, count: members.length),
          ),
          const SizedBox(height: AppSpacing.ms),
          _TileGrid(
            children: [
              for (final person in members)
                FadeSlideIn(
                  key: ValueKey(person.id),
                  order: order++,
                  child: _PersonTile(person: person),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        FadeSlideIn(
          key: const ValueKey('add-person'),
          order: order,
          child: _AddPersonCard(onTap: onAddPerson),
        ),
      ],
    );
  }
}

/// The device owner, shown as the centre of the circle rather than one
/// more tile.
class _SelfCard extends StatelessWidget {
  const _SelfCard({required this.person, required this.circleSize});

  final Person person;
  final int circleSize;

  @override
  Widget build(BuildContext context) {
    final circle = switch (circleSize) {
      0 => 'Just you, for now',
      1 => '1 person in your circle',
      _ => '$circleSize people in your circle',
    };

    return AppCard(
      color: AppColors.softPeach,
      elevated: false,
      radius: AppRadius.xl,
      semanticLabel: '${person.name}, you. $circle',
      child: Row(
        children: [
          _RingedAvatar(person: person, radius: 30, ring: AppColors.paper),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: AppTypography.heading2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(circle, style: AppTypography.bodyMuted),
              ],
            ),
          ),
          const _Chip(label: "That's you", icon: Icons.favorite_rounded),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.type, required this.count});

  final String type;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Icon(
            personTypeIcon(type),
            size: AppIconSizes.md,
            color: AppColors.coralInk,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              personGroupLabel(type),
              style: AppTypography.heading3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('$count', style: AppTypography.caption),
        ],
      ),
    );
  }
}

/// Lays tiles out in even columns that fit the width (3 on most phones).
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});

  final List<Widget> children;

  static const _maxTileWidth = 128.0;
  static const _gap = AppSpacing.ms;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + _gap) / (_maxTileWidth + _gap))
            .ceil()
            .clamp(2, 6);
        final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final child in children)
              SizedBox(key: child.key, width: width, child: child),
          ],
        );
      },
    );
  }
}

/// A small photo-print: the face first, the name written underneath.
class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.ms,
      ),
      semanticLabel: '${person.name}, ${personTypeLabel(person.type)}',
      child: Column(
        children: [
          _RingedAvatar(person: person, radius: 32, ring: AppColors.sunken),
          const SizedBox(height: AppSpacing.sm),
          Text(
            person.name,
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

class _AddPersonCard extends StatelessWidget {
  const _AddPersonCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.sunken,
      elevated: false,
      radius: AppRadius.xl,
      semanticLabel: 'Add someone. Partner, family, friends or pets.',
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.paper,
            foregroundColor: AppColors.textPrimary,
            child: Icon(Icons.add_rounded),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add someone', style: AppTypography.heading3),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Partner, family, friends — or pets.',
                  style: AppTypography.bodyMuted,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

/// [PersonAvatar] inside a soft ring, like a photo in a round frame.
class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({
    required this.person,
    required this.radius,
    required this.ring,
  });

  final Person person;
  final double radius;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
      child: PersonAvatar(person: person, radius: radius),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.ms,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.sm, color: AppColors.coralInk),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

/// Placeholder shapes that match the loaded layout, so nothing jumps.
class _LoadingPeople extends StatelessWidget {
  const _LoadingPeople();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SkeletonBox(height: 96, radius: AppRadius.xl),
          const SizedBox(height: AppSpacing.xl),
          const SkeletonBox(width: 120, height: 20),
          const SizedBox(height: AppSpacing.ms),
          _TileGrid(
            children: [
              for (var i = 0; i < 6; i++) const SkeletonBox(height: 124),
            ],
          ),
        ],
      ),
    );
  }
}
