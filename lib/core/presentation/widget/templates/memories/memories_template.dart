import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../domain/memories/enum/memory_filter.dart';
import '../../../types/memories/memory_box.dart';
import '../../../types/memories/memory_month.dart';
import '../../../types/memories/memory_summary.dart';
import '../../atoms/common/md_fade_slide_in.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_skeleton_box.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../molecules/memories/md_journal_heading.dart';
import '../../molecules/memories/md_memory_filter_chips.dart';
import '../../molecules/common/md_page_header.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/memories/md_memory_feature_card.dart';
import '../../organisms/memories/md_memory_journal_card.dart';
import '../../molecules/memories/md_empty_memory_filter.dart';
import '../../molecules/sharing/md_shared_with_you_row.dart';

class MemoriesTemplate extends StatelessWidget {
  const MemoriesTemplate({
    super.key,
    required this.box,
    required this.now,
    required this.onFilterChanged,
    required this.onRetry,
    required this.onRefresh,
    required this.onStartQuest,
    required this.onOpenMemory,
    required this.onViewPhoto,
    required this.onOpenShared,
  });

  final AsyncValue<MemoryBox> box;

  final DateTime now;
  final ValueChanged<MemoryFilter> onFilterChanged;
  final VoidCallback onRetry;

  final Future<void> Function() onRefresh;
  final VoidCallback onStartQuest;
  final ValueChanged<MemorySummary> onOpenMemory;

  final void Function(MemorySummary summary, int index) onViewPhoto;

  final VoidCallback onOpenShared;

  @override
  Widget build(BuildContext context) {
    final data = box.value;

    return MdAppScaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.coralInk,
        child: CustomScrollView(
          // Always scrollable, so the pull works on a short or empty page.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.md,
                AppSpacing.gutter,
                AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: MdFadeSlideIn(
                  child: MdPageHeader(
                    overline: 'Your memory box',
                    title: 'Memories',
                    subtitle: 'Just for you and the people who were there.',
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: MdFadeSlideIn(
                  order: 1,
                  child: MdSharedWithYouRow(onTap: onOpenShared),
                ),
              ),
            ),
            if (data != null && !data.isEmpty)
              SliverToBoxAdapter(
                child: MdFadeSlideIn(
                  order: 1,
                  child: MdMemoryFilterChips(
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
                        const MdSkeletonBox(height: 420, radius: AppRadius.xl),
                  ),
                ),
              ],
              error: (error, stack) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: MdEmptyState.error(
                    title: "We couldn't open your memories",
                    onRetry: onRetry,
                  ),
                ),
              ],
              data: (box) => box.isEmpty
                  ? [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: MdEmptyState(
                          icon: Icons.photo_album_outlined,
                          title: 'Your memories will live here',
                          message: 'Ready to make the first one?',
                          action: MdPrimaryButton(
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
          child: MdFadeSlideIn(order: order++, child: child),
        ),
      );
    }

    if (box.months.isEmpty) {
      add(
        'nothing',
        MdEmptyMemoryFilter(filter: box.filter),
        gap: AppSpacing.xl,
      );
    }

    for (final MemoryMonth(:month, :memories) in box.months) {
      final monthName = DateFormat.MMMM().format(month);
      final [featured, ...earlier] = memories;

      add(
        'month-$month',
        MdJournalHeading(title: monthName, trailing: '${month.year}'),
        gap: AppSpacing.xl,
      );
      add(
        featured.memory.id,
        MdMemoryFeatureCard(
          summary: featured,
          now: now,
          onOpen: () => onOpenMemory(featured),
          onViewPhoto: (index) => onViewPhoto(featured, index),
        ),
        gap: AppSpacing.md,
      );
      if (earlier.isEmpty) continue;

      add('earlier-$month', MdJournalHeading(title: 'Earlier in $monthName'));
      for (final summary in earlier) {
        add(
          summary.memory.id,
          MdMemoryJournalCard(
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
