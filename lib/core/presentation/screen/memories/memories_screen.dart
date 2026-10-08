import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../types/async_value_loading.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../widget/molecules/common/md_screen_loading.dart';
import '../../widget/organisms/common/md_app_scaffold.dart';
import '../../widget/organisms/memories/md_photo_viewer.dart';
import '../../widget/templates/memories/memories_template.dart';

/// The memory box. Design lives in [MemoriesTemplate].
class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = ref.watch(memoryBoxProvider);
    if (box.isFirstFetch) {
      return const MdAppScaffold(
        body: MdScreenLoading(message: 'Opening your memory box…'),
      );
    }

    return MemoriesTemplate(
      box: box,
      now: DateTime.now(),
      onFilterChanged: (filter) =>
          ref.read(memoryFilterSelectionProvider.notifier).select(filter),
      onRetry: () => ref.invalidate(memoryListProvider),
      onRefresh: () async {
        ref.invalidate(memoryListProvider);
        await ref.read(memoryListProvider.future);
      },
      onStartQuest: () => context.push(AppRoutes.quests),
      onOpenShared: () => context.push(AppRoutes.shared),
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
