import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/loading/loading_indicator.dart';
import '../../../memories/presentation/view_models/memory_list_view_model.dart';
import '../../../memories/presentation/widgets/memory_card.dart';
import '../widgets/recent_memories_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoryListProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting, style: AppTypography.bodyMuted),
              const SizedBox(height: AppSpacing.xs),
              Text("Let's make a memory.", style: AppTypography.heading1),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Start a Quest',
                icon: Icons.auto_awesome_rounded,
                onPressed: () => context.push('/quests'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Recent Memories', style: AppTypography.heading3),
              const SizedBox(height: AppSpacing.sm),
              memories.when(
                data: (list) => RecentMemoriesSection(
                  memories: list.take(6).toList(),
                  builder: (memory) => SizedBox(
                    width: 160,
                    child: MemoryCard(
                      memory: memory,
                      coverPhoto: null,
                      onTap: () => context.push('/memory/${memory.id}'),
                    ),
                  ),
                ),
                loading: () =>
                    const SizedBox(height: 160, child: LoadingIndicator()),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
