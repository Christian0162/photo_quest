import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../widget/atoms/primary_button.dart';
import '../../widget/atoms/person_avatar.dart';
import '../../widget/molecules/empty_state.dart';
import '../../widget/atoms/loading_indicator.dart';
import '../../widget/organisms/quest_participants_section.dart';
import '../../../data/repositories/memory_repository_provider.dart';
import '../../view_model/quests/quest_detail_view_model.dart';
import '../../view_model/quests/quest_participants_view_model.dart';

/// Introduces a Quest before capture begins: what it is, how many shots,
/// and the single primary action to begin. See CLAUDE.md §60, §65.
class QuestIntroScreen extends ConsumerStatefulWidget {
  const QuestIntroScreen({super.key, required this.questId});

  final String questId;

  @override
  ConsumerState<QuestIntroScreen> createState() => _QuestIntroScreenState();
}

class _QuestIntroScreenState extends ConsumerState<QuestIntroScreen> {
  bool _starting = false;

  Future<void> _startQuest() async {
    if (_starting) return;
    setState(() => _starting = true);

    try {
      final memoryRepo = ref.read(memoryRepositoryProvider);
      final sessionId = await memoryRepo.startQuestSession(widget.questId);
      final detail = await ref.read(questDetailProvider(widget.questId).future);
      final participants = await ref.read(
        questParticipantsViewModelProvider(widget.questId).future,
      );
      final confirmed = participants
          .where((p) => p.participant.status == 'accepted')
          .map((p) => p.person.id)
          .toList();
      await memoryRepo.createMemory(
        questSessionId: sessionId,
        title: detail.quest.title,
        capturedAt: DateTime.now(),
        personIds: confirmed,
      );

      if (!mounted) return;
      context.push('/capture/$sessionId');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(questDetailProvider(widget.questId));
    final participants = ref.watch(
      questParticipantsViewModelProvider(widget.questId),
    );

    return Scaffold(
      appBar: AppBar(),
      body: detail.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: "Couldn't load this Quest",
          message: 'Please go back and try again.',
        ),
        data: (data) {
          final pending =
              participants.value
                  ?.where((p) => p.participant.status == 'invited')
                  .isNotEmpty ??
              false;
          final canStart = data.quest.type == 'solo' || !pending;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.quest.title, style: AppTypography.heading1),
                if (data.quest.description != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(data.quest.description!, style: AppTypography.bodyMuted),
                ],
                if (data.creator != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      PersonAvatar(person: data.creator!, radius: 12),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Created by ${data.creator!.name}',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text('${data.shots.length} shots', style: AppTypography.body),
                const SizedBox(height: AppSpacing.lg),
                QuestParticipantsSection(quest: data.quest),
                const Spacer(),
                if (pending) ...[
                  Text(
                    'Everyone needs to confirm before you start.',
                    style: AppTypography.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                PrimaryButton(
                  label: _starting ? 'Starting…' : 'Start This Quest',
                  onPressed: (_starting || !canStart) ? null : _startQuest,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
