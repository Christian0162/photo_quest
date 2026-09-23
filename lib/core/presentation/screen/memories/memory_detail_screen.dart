import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/memories/memory_detail_view_model.dart';
import '../../widget/organisms/app_scaffold.dart';
import '../../widget/template/memory_detail_template.dart';

/// One Memory. Wires [MemoryDetailViewModel] and navigation into
/// [MemoryDetailTemplate]. See CLAUDE.md §39.
class MemoryDetailScreen extends ConsumerWidget {
  const MemoryDetailScreen({super.key, required this.memoryId});

  final String memoryId;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the actions notifier alive while the memory is open.
    ref.watch(memoryDetailViewModelProvider(memoryId));

    return MemoryDetailTemplate(
      detail: ref.watch(memoryDetailProvider(memoryId)),
      onRetry: () => ref.invalidate(memoryDetailProvider(memoryId)),
      onShare: (origin) => _share(context, ref, origin),
      onDoAgain: (questId) => context.push(AppRoutes.questDetailPath(questId)),
    );
  }
}
