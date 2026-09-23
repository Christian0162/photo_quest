import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../widget/template/memories_template.dart';

/// The memory box. Design lives in [MemoriesTemplate]. See CLAUDE.md §38.
class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MemoriesTemplate(
      months: ref.watch(memoriesByMonthProvider),
      onRetry: () => ref.invalidate(memoryListProvider),
      onStartQuest: () => context.push(AppRoutes.quests),
      onOpenMemory: (summary) =>
          context.push(AppRoutes.memoryDetailPath(summary.memory.id)),
    );
  }
}
