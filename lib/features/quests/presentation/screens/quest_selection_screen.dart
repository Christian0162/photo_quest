import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/empty_states/empty_state.dart';
import '../../../../core/widgets/loading/loading_indicator.dart';
import '../../domain/entities/quest.dart';
import '../view_models/quest_list_view_model.dart';
import '../widgets/quest_card.dart';

/// Inspirational Quest picker, grouped by category. See CLAUDE.md §33.
class QuestSelectionScreen extends ConsumerWidget {
  const QuestSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Quest')),
      body: quests.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: "Couldn't load Quests",
          message: 'Please try again in a moment.',
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_awesome_rounded,
              title: 'No Quests yet',
              message: 'Quests you create will show up here.',
            );
          }

          final grouped = <String, List<Quest>>{};
          for (final quest in list) {
            grouped.putIfAbsent(quest.category, () => []).add(quest);
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
                    childAspectRatio: 0.85,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    final quest = entry.value[index];
                    return QuestCard(
                      quest: quest,
                      onTap: () => context.push('/quests/${quest.id}'),
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
