import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/quests/quest_list_view_model.dart';
import '../../widget/template/quest_selection_template.dart';

/// Choose a Quest. Design lives in [QuestSelectionTemplate].
/// See CLAUDE.md §33.
class QuestSelectionScreen extends ConsumerWidget {
  const QuestSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QuestSelectionTemplate(
      shelves: ref.watch(questShelvesProvider),
      onRetry: () => ref.invalidate(questListProvider),
      onCreateQuest: () => context.push(AppRoutes.createQuest),
      onOpenQuest: (quest) => context.push(AppRoutes.questDetailPath(quest.id)),
    );
  }
}
