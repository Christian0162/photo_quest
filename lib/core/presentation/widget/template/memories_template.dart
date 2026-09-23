import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/empty_state.dart';
import '../molecules/section_header.dart';
import '../organisms/app_scaffold.dart';
import '../organisms/memory_card.dart';

/// The private memory box, grouped by year and month like a photo album.
/// Not a social feed — no likes, no counts. See CLAUDE.md §38, design
/// system §35.
class MemoriesTemplate extends StatelessWidget {
  const MemoriesTemplate({
    super.key,
    required this.months,
    required this.onRetry,
    required this.onStartQuest,
    required this.onOpenMemory,
  });

  static const _columns = 2;

  final AsyncValue<List<MemoryMonth>> months;
  final VoidCallback onRetry;
  final VoidCallback onStartQuest;
  final ValueChanged<MemorySummary> onOpenMemory;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth -
                  AppSpacing.gutter * 2 -
                  AppSpacing.ms * (_columns - 1)) /
              _columns;
          final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            mainAxisSpacing: AppSpacing.ms,
            crossAxisSpacing: AppSpacing.ms,
            mainAxisExtent: MemoryCard.heightFor(
              cardWidth,
              MediaQuery.textScalerOf(context),
            ),
          );

          return CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.md,
                  AppSpacing.gutter,
                  0,
                ),
                sliver: SliverToBoxAdapter(child: _Header()),
              ),
              ...months.when(
                loading: () => [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    sliver: SliverGrid.builder(
                      gridDelegate: gridDelegate,
                      itemCount: 4,
                      itemBuilder: (_, _) => const SkeletonBox(),
                    ),
                  ),
                ],
                error: (error, stack) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState.error(
                      title: "We couldn't open your memories",
                      onRetry: onRetry,
                    ),
                  ),
                ],
                data: (list) => list.isEmpty
                    ? [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(
                            icon: Icons.photo_album_outlined,
                            title: 'Your memories will live here',
                            message: 'Ready to make the first one?',
                            action: PrimaryButton(
                              label: 'Start a quest',
                              icon: Icons.auto_awesome_rounded,
                              expand: false,
                              onPressed: onStartQuest,
                            ),
                          ),
                        ),
                      ]
                    : _monthSlivers(list, gridDelegate),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          );
        },
      ),
    );
  }

  /// One header + grid per month; a year line appears when it changes.
  List<Widget> _monthSlivers(
    List<MemoryMonth> months,
    SliverGridDelegate gridDelegate,
  ) {
    final slivers = <Widget>[];
    int? year;
    for (final MemoryMonth(:month, :memories) in months) {
      if (month.year != year) {
        year = month.year;
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.xl,
              AppSpacing.gutter,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Semantics(
                header: true,
                child: Text('$year', style: AppTypography.heading1),
              ),
            ),
          ),
        );
      }
      slivers
        ..add(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.gutter,
              AppSpacing.ms,
            ),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: DateFormat.MMMM().format(month),
                trailing: Text(
                  memories.length == 1
                      ? '1 memory'
                      : '${memories.length} memories',
                  style: AppTypography.caption,
                ),
              ),
            ),
          ),
        )
        ..add(
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            sliver: SliverGrid.builder(
              gridDelegate: gridDelegate,
              itemCount: memories.length,
              itemBuilder: (context, index) => MemoryCard(
                summary: memories[index],
                onTap: () => onOpenMemory(memories[index]),
              ),
            ),
          ),
        );
    }
    return slivers;
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text('Memories', style: AppTypography.display),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Just for you and the people who were there.',
          style: AppTypography.bodyMuted,
        ),
      ],
    );
  }
}
