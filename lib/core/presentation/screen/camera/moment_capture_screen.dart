import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_model/camera/moment_capture_view_model.dart';
import '../../widget/organisms/md_app_scaffold.dart';
import '../../widget/templates/moment_capture_template.dart';

/// The "Your Day" camera. Wires [MomentCapture] into
/// [MomentCaptureTemplate] and closes once the moment is added. See
/// CLAUDE.md §35.
class MomentCaptureScreen extends ConsumerWidget {
  const MomentCaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = momentCaptureProvider;

    ref.listen(provider, (previous, next) {
      if (next.value?.failed ?? false) {
        showAppMessage(
          context,
          next.value?.isReviewing ?? false
              ? "That didn't save. Please try again."
              : "That one didn't work. Let's try again.",
        );
      }
    });

    final viewModel = ref.read(provider.notifier);

    return MomentCaptureTemplate(
      capture: ref.watch(provider),
      onClose: () => context.pop(),
      onRetry: () => ref.invalidate(provider),
      onTakePhoto: viewModel.takePhoto,
      onSwitchCamera: viewModel.switchCamera,
      onRetake: viewModel.retake,
      onAdd: (caption) async {
        final saved = await viewModel.addToYourDay(caption);
        if (saved && context.mounted) context.pop();
      },
    );
  }
}
