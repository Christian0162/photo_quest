import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/camera/memory_reveal_view_model.dart';
import '../../widget/template/memory_reveal_template.dart';

/// Memory reveal. Design lives in [MemoryRevealTemplate]. See CLAUDE.md §37.
class MemoryRevealScreen extends ConsumerWidget {
  const MemoryRevealScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MemoryRevealTemplate(
      reveal: ref.watch(memoryRevealProvider(sessionId)),
      onRetry: () => ref.invalidate(memoryRevealProvider(sessionId)),
      onKeep: (result) =>
          context.go(AppRoutes.memoryDetailPath(result.memoryId)),
    );
  }
}
