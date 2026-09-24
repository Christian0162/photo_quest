import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../atoms/fade_slide_in.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/empty_state.dart';
import '../molecules/memory_filter_chips.dart';
import '../organisms/app_scaffold.dart';
import '../organisms/memory_feature_card.dart';
import '../organisms/memory_journal_card.dart';
import '../../../domain/memories/enum/memory_filter.dart';
import '../../types/memories/memory_summary.dart';
import '../../types/memories/memory_month.dart';
import '../../types/memories/memory_box.dart';
import '../molecules/journal_heading.dart';
import '../molecules/page_header.dart';

/// The private memory box, kept like a journal:
///
/// ```text
/// Memories
/// (This day 1) (This month 3) (All journey 24)
///
/// • October                                2026
///   [ featured: taped page, fanned prints ]
/// • Earlier in October
///   [ journal entry ]
///   [ journal entry ]
/// • September …
/// ```
///
/// Not a social feed — no likes, no comments. See CLAUDE.md §38, design
/// system §35.
class MemoriesTemplate extends StatelessWidget {
  const MemoriesTemplate({
    super.key,
    required this.box,
    required this.now,
    required this.onFilterChanged,
    required this.onRetry,
    required this.onStartQuest,
    required this.onOpenMemory,
    required this.onViewPhoto,
  });

  final AsyncValue<MemoryBox> box;

  /// Today, for "This day" and "2 weeks ago".
  final DateTime now;
  final ValueChanged<MemoryFilter> onFilterChanged;
  final VoidCallback onRetry;
  final VoidCallback onStartQuest;
  final ValueChanged<MemorySummary> onOpenMemory;

  /// Opens one of a memory's photos full screen, at [index].
  final void Function(MemorySummary summary, int index) onViewPhoto;

  @override
  Widget build(BuildContext context) {
    final data = box.value;

    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.gutter,
              AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: FadeSlideIn(
                child: PageHeader(
                  overline: 'YOUR MEMORY BOX',
                  title: 'Memories',
                  subtitle: 'Just for you and the people who were there.',
                ),
              ),
            ),
          ),
          if (data != null && !data.isEmpty)
            SliverToBoxAdapter(
              child: FadeSlideIn(
                order: 1,
                child: MemoryFilterChips(
                  selected: data.filter,
                  counts: data.counts,
                  onSelected: onFilterChanged,
                ),
              ),
            ),
          ...box.when(
            loading: () => [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                sliver: SliverList.separated(
                  itemCount: 2,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (_, _) =>
                      const SkeletonBox(height: 420, radius: AppRadius.xl),
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
            data: (box) => box.isEmpty
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
                : [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      sliver: SliverList.list(children: _entries(box)),
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

  /// Each month: its heading and featured memory, then "Earlier in …" and
  /// the rest. Keys include the filter, so switching filters eases the new
  /// set in rather than swapping it abruptly.
  List<Widget> _entries(MemoryBox box) {
    final entries = <Widget>[];
    var order = 2;
    void add(String id, Widget child, {double gap = AppSpacing.lg}) {
      entries.add(
        Padding(
          key: ValueKey('${box.filter.name}-$id'),
          padding: EdgeInsets.only(top: gap),
          child: FadeSlideIn(order: order++, child: child),
        ),
      );
    }

    if (box.months.isEmpty) {
      add('nothing', _NothingHere(filter: box.filter), gap: AppSpacing.xl);
    }

    for (final MemoryMonth(:month, :memories) in box.months) {
      final monthName = DateFormat.MMMM().format(month);
      final [featured, ...earlier] = memories;

      add(
        'month-$month',
        JournalHeading(title: monthName, trailing: '${month.year}'),
        gap: AppSpacing.xl,
      );
      add(
        featured.memory.id,
        MemoryFeatureCard(
          summary: featured,
          now: now,
          onOpen: () => onOpenMemory(featured),
          onViewPhoto: (index) => onViewPhoto(featured, index),
        ),
        gap: AppSpacing.md,
      );
      if (earlier.isEmpty) continue;

      add('earlier-$month', JournalHeading(title: 'Earlier in $monthName'));
      for (final summary in earlier) {
        add(
          summary.memory.id,
          MemoryJournalCard(
            summary: summary,
            onOpen: () => onOpenMemory(summary),
            onViewPhoto: (index) => onViewPhoto(summary, index),
          ),
          gap: AppSpacing.md,
        );
      }
    }

    return entries;
  }
}

/// When a filter has nothing in it — "This day" on a day with no history.
class _NothingHere extends StatelessWidget {
  const _NothingHere({required this.filter});

  final MemoryFilter filter;

  @override
  Widget build(BuildContext context) {
    final (title, message) = switch (filter) {
      MemoryFilter.thisDay => (
        'Nothing on this day yet',
        'Make today one you’ll look back on next year.',
      ),
      MemoryFilter.thisMonth => (
        'No memories this month yet',
        'There’s still time to make one.',
      ),
      MemoryFilter.allJourney => ('', ''),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.journal),
        const SizedBox(height: AppSpacing.xs),
        Text(message, style: AppTypography.bodyMuted),
      ],
    );
  }
}
