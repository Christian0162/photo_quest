import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/app_haptics.dart';
import '../../view_model/memories/keepsake_view_model.dart';
import '../../view_model/memories/memory_detail_view_model.dart';
import '../../widget/organisms/app_scaffold.dart';
import '../../widget/templates/keepsake_template.dart';

/// Decorate a Memory's printed keepsake. Wires [KeepsakeViewModel] into
/// [KeepsakeTemplate]; saving renders the print and goes back. See
/// CLAUDE.md §36.
class KeepsakeScreen extends ConsumerWidget {
  const KeepsakeScreen({super.key, required this.memoryId});

  final String memoryId;

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    Future<Uint8List?> Function() render,
  ) async {
    final png = await render();
    if (!context.mounted) return;
    if (png == null) {
      showAppMessage(context, "We couldn't save your keepsake. Try again.");
      return;
    }
    try {
      await ref.read(keepsakeViewModelProvider(memoryId).notifier).save(png);
      ref.invalidate(memoryDetailProvider(memoryId));
      AppHaptics.success();
      if (context.mounted) context.pop();
    } catch (_) {
      if (!context.mounted) return;
      showAppMessage(context, "We couldn't save your keepsake. Try again.");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = keepsakeViewModelProvider(memoryId);
    final viewModel = ref.read(provider.notifier);

    return KeepsakeTemplate(
      design: ref.watch(provider),
      doneLabel: 'Save keepsake',
      onClose: () => context.pop(),
      onRetry: () => ref.invalidate(provider),
      onDone: (render) => _save(context, ref, render),
      onLayoutChanged: viewModel.setLayout,
      onFrameChanged: viewModel.setFrame,
      onAddSticker: viewModel.addSticker,
      onSelectSticker: viewModel.selectSticker,
      onTransformSticker: viewModel.transformSticker,
      onRemoveSticker: viewModel.removeSticker,
    );
  }
}
