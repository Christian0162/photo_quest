import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/camera/memory_reveal_view_model.dart';
import '../../view_model/memories/keepsake_view_model.dart';
import '../../widget/organisms/app_scaffold.dart';
import '../../widget/templates/memory_reveal_template.dart';
import '../../types/camera/memory_reveal_result.dart';

/// Memory reveal. Wires the reveal, the keepsake design and navigation into
/// [MemoryRevealTemplate]. See CLAUDE.md §36-37.
class MemoryRevealScreen extends ConsumerWidget {
  const MemoryRevealScreen({super.key, required this.sessionId});

  final String sessionId;

  /// Saves the print exactly as shown, then opens the memory. If the print
  /// can't be saved, the default strip made earlier is kept, so the memory
  /// is never lost.
  Future<void> _keep(
    BuildContext context,
    WidgetRef ref,
    MemoryRevealResult result,
    Future<Uint8List?> Function() render,
  ) async {
    final keepsake = keepsakeViewModelProvider(result.memoryId);
    if (ref.read(keepsake).hasValue) {
      final png = await render();
      try {
        if (png != null) await ref.read(keepsake.notifier).save(png);
      } catch (_) {
        if (context.mounted) {
          showAppMessage(
            context,
            "We couldn't save your decorations — your photo strip is safe.",
          );
        }
      }
    }
    if (context.mounted) {
      context.go(AppRoutes.memoryDetailPath(result.memoryId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reveal = ref.watch(memoryRevealProvider(sessionId));
    final memoryId = reveal.value?.memoryId;

    return MemoryRevealTemplate(
      reveal: reveal,
      // Watching keeps the design alive while the designer is open.
      keepsake: memoryId == null
          ? null
          : ref.watch(keepsakeViewModelProvider(memoryId)).value,
      onRetry: () => ref.invalidate(memoryRevealProvider(sessionId)),
      onKeep: (result, render) => _keep(context, ref, result, render),
      onDecorate: (result) =>
          context.push(AppRoutes.keepsakePath(result.memoryId)),
    );
  }
}
