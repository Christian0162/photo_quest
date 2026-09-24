import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../errors/app_failure.dart';
import '../../view_model/memories/keepsake_view_model.dart';
import '../../view_model/memories/memory_detail_view_model.dart';
import '../../widget/organisms/app_scaffold.dart';
import '../../widget/organisms/photo_viewer.dart';
import '../../widget/templates/memory_detail_template.dart';

/// One Memory. Wires [MemoryDetailViewModel] and navigation into
/// [MemoryDetailTemplate]. See CLAUDE.md §39.
class MemoryDetailScreen extends ConsumerWidget {
  const MemoryDetailScreen({super.key, required this.memoryId, this.coverPath});

  final String memoryId;

  /// The cover already on screen when this memory was tapped.
  final String? coverPath;

  Future<void> _share(BuildContext context, WidgetRef ref, Rect? origin) async {
    try {
      await ref
          .read(memoryDetailViewModelProvider(memoryId).notifier)
          .shareStrip(origin: origin);
    } catch (_) {
      if (!context.mounted) return;
      showAppMessage(context, "We couldn't open sharing just now.");
    }
  }

  Future<void> _shareShot(
    BuildContext context,
    WidgetRef ref,
    Photo photo,
    Rect? origin,
  ) async {
    try {
      await ref
          .read(memoryDetailViewModelProvider(memoryId).notifier)
          .shareShot(photo, origin: origin);
    } catch (_) {
      if (!context.mounted) return;
      showAppMessage(context, "We couldn't open sharing just now.");
    }
  }

  /// Runs a download and says how it went, in friendly words.
  Future<void> _download(
    BuildContext context,
    Future<void> Function() save,
    String done,
  ) async {
    try {
      await save();
      if (context.mounted) showAppMessage(context, done);
    } on AppFailure catch (failure) {
      if (context.mounted) showAppMessage(context, failure.message);
    } catch (_) {
      if (context.mounted) {
        showAppMessage(context, const GallerySaveFailure().message);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the actions notifier alive while the memory is open.
    ref.watch(memoryDetailViewModelProvider(memoryId));

    return MemoryDetailTemplate(
      memoryId: memoryId,
      detail: ref.watch(memoryDetailProvider(memoryId)),
      coverPath: coverPath,
      onOpenPhoto: (detail, index) => showPhotoViewer(
        context,
        photos: detail.photos,
        initialIndex: index,
        title: detail.memory.title,
        onShare: (photo, origin) => _shareShot(context, ref, photo, origin),
        onDownload: (photo) => _download(
          context,
          () => ref
              .read(memoryDetailViewModelProvider(memoryId).notifier)
              .downloadShot(photo),
          'Saved to your photos.',
        ),
      ),
      onRetry: () => ref.invalidate(memoryDetailProvider(memoryId)),
      onShare: (origin) => _share(context, ref, origin),
      onDoAgain: (questId) => context.push(AppRoutes.questDetailPath(questId)),
      onDecorate: () => context.push(AppRoutes.keepsakePath(memoryId)),
      onDownloadStrip: () => _download(
        context,
        ref
            .read(memoryDetailViewModelProvider(memoryId).notifier)
            .downloadStrip,
        'Your photo strip is in your photos.',
      ),
      keepsake: ref.watch(keepsakeViewModelProvider(memoryId)).value,
    );
  }
}
