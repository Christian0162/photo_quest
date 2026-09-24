import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../widget/organisms/photo_viewer.dart';
import '../../widget/template/memories_template.dart';

/// The memory box. Design lives in [MemoriesTemplate]. See CLAUDE.md §38.
class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MemoriesTemplate(
      box: ref.watch(memoryBoxProvider),
      now: DateTime.now(),
      onFilterChanged: (filter) =>
          ref.read(memoryFilterSelectionProvider.notifier).select(filter),
      onRetry: () => ref.invalidate(memoryListProvider),
      onStartQuest: () => context.push(AppRoutes.quests),
      onOpenMemory: (summary) => context.push(
        AppRoutes.memoryDetailPath(summary.memory.id),
        extra: summary.coverPhoto?.thumbnailPath,
      ),
      onViewPhoto: (summary, index) => showPhotoViewer(
        context,
        photos: summary.photos.isEmpty ? [?summary.coverPhoto] : summary.photos,
        initialIndex: index,
        title: summary.memory.title,
      ),
    );
  }
}
