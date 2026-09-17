import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../widget/molecules/empty_state.dart';
import '../../widget/atoms/loading_indicator.dart';
import '../../../domain/memories/entities/memory.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../widget/organisms/memory_card.dart';

/// The user's private memory collection, grouped by month. Not a social
/// feed. See CLAUDE.md §38.
class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Memories')),
      body: memories.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: "Couldn't load your memories",
          message: 'Please try again in a moment.',
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.photo_library_rounded,
              title: 'Your memories will live here',
              message: 'Ready to make the first one?',
            );
          }

          final grouped = <String, List<Memory>>{};
          for (final memory in list) {
            final key = DateFormat.yMMMM().format(memory.capturedAt);
            grouped.putIfAbsent(key, () => []).add(memory);
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final entry in grouped.entries) ...[
                Text(entry.key, style: AppTypography.heading3),
                const SizedBox(height: AppSpacing.sm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    final memory = entry.value[index];
                    return MemoryCard(
                      memory: memory,
                      coverPhoto: null,
                      onTap: () => context.push('/memory/${memory.id}'),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          );
        },
      ),
    );
  }
}
