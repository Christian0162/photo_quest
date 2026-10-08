import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_model/homes/day_moments_view_model.dart';
import '../../widget/molecules/md_confirmation_dialog.dart';
import '../../widget/organisms/md_app_scaffold.dart';
import '../../widget/templates/moment_viewer_template.dart';

/// Opens one "Your Day" moment full screen. Closes by itself when the last
/// one is gone or has faded. See CLAUDE.md §54A.
class MomentViewerScreen extends ConsumerWidget {
  const MomentViewerScreen({super.key, required this.momentId});

  final String momentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(dayMomentListProvider).value;

    if (moments == null) {
      return const MdAppScaffold(body: SizedBox.shrink());
    }
    if (moments.isEmpty) {
      // Everything faded or was removed while this was open.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.pop();
      });
      return const MdAppScaffold(body: SizedBox.shrink());
    }

    final start = moments.indexWhere((m) => m.id == momentId);

    return MomentViewerTemplate(
      moments: moments,
      initialIndex: start < 0 ? 0 : start,
      now: DateTime.now(),
      onClose: () => context.pop(),
      onDelete: (moment) async {
        final remove = await showConfirmationDialog(
          context,
          title: 'Remove this moment?',
          message: "It will be gone from Your Day for good.",
          confirmLabel: 'Remove',
          cancelLabel: 'Keep it',
        );
        if (remove) {
          await ref.read(dayMomentListProvider.notifier).delete(moment.id);
        }
      },
    );
  }
}
