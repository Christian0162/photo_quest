import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_constants.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../types/display_labels.dart';
import '../atoms/fade_slide_in.dart';
import '../atoms/person_avatar.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../atoms/status_pill.dart';
import '../molecules/empty_state.dart';
import '../molecules/section_header.dart';
import '../organisms/app_scaffold.dart';
import '../organisms/quest_card.dart';
import '../organisms/quest_participants_section.dart';
import '../organisms/quest_shot_list.dart';
import '../../../domain/quests/enum/status_tone.dart';
import '../../types/quests/quest_detail.dart';
import '../../types/quests/quest_start_readiness.dart';
import '../../types/quests/quest_participant_with_person.dart';
import '../atoms/icon_fact.dart';

/// Introduces a Quest before capture: what we're doing, who's joining, which
/// photos we'll take — then one primary action to begin. See CLAUDE.md §59,
/// design system §16, §23.
class QuestIntroTemplate extends StatelessWidget {
  const QuestIntroTemplate({
    super.key,
    required this.detail,
    required this.participants,
    required this.readiness,
    required this.isStarting,
    required this.onRetry,
    required this.onStart,
    required this.onInvite,
    required this.onConfirmParticipant,
    required this.onRemoveParticipant,
  });

  final AsyncValue<QuestDetail> detail;
  final AsyncValue<List<QuestParticipantWithPerson>> participants;
  final QuestStartReadiness readiness;
  final bool isStarting;
  final VoidCallback onRetry;
  final VoidCallback onStart;
  final VoidCallback onInvite;
  final ValueChanged<QuestParticipantWithPerson> onConfirmParticipant;
  final ValueChanged<QuestParticipantWithPerson> onRemoveParticipant;

  @override
  Widget build(BuildContext context) {
    final data = detail.value;

    return AppScaffold(
      showAppBar: true,
      bottomAction: data == null
          ? null
          : _StartAction(
              hint: readiness.hint,
              everyoneIn: readiness.everyoneIn,
              canStart: readiness.canStart,
              starting: isStarting,
              onStart: onStart,
            ),
      body: detail.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            children: [
              SkeletonBox(height: 220, radius: AppRadius.photo),
              SizedBox(height: AppSpacing.lg),
              SkeletonBox(height: 32),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 64),
            ],
          ),
        ),
        error: (error, stack) => EmptyState.error(
          title: "We couldn't open this quest",
          message: 'It may no longer be available.',
          onRetry: onRetry,
        ),
        data: (data) {
          final quest = data.quest;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              AppSpacing.xl,
            ),
            children: FadeSlideIn.staggered([
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.photo),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: QuestHeroCover(quest: quest),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(quest.category.toUpperCase(), style: AppTypography.overline),
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                header: true,
                child: Text(quest.title, style: AppTypography.heading1),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  IconFact(
                    icon: questTypeIcon(quest.type),
                    label: questTypeLabel(quest.type),
                  ),
                  IconFact(
                    icon: Icons.photo_camera_outlined,
                    label: data.shots.length == 1
                        ? '1 photo'
                        : '${data.shots.length} photos',
                  ),
                ],
              ),
              if (quest.description != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(quest.description!, style: AppTypography.bodyLarge),
              ],
              if (data.creator != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    PersonAvatar(person: data.creator!, radius: 14),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      data.creator!.type == 'self'
                          ? 'Created by you'
                          : 'Created by ${data.creator!.name}',
                      style: AppTypography.bodyMuted,
                    ),
                  ],
                ),
              ],
              if (quest.type != 'solo') ...[
                const SizedBox(height: AppSpacing.xl),
                QuestParticipantsSection(
                  participants: participants,
                  limit:
                      quest.maxParticipants ??
                      AppConstants.defaultGroupQuestParticipantLimit,
                  onInvite: onInvite,
                  onConfirm: onConfirmParticipant,
                  onRemove: onRemoveParticipant,
                ),
              ],
              if (data.shots.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(
                  title: "What you'll capture",
                  subtitle: 'The photobooth walks you through each one.',
                ),
                const SizedBox(height: AppSpacing.ms),
                QuestShotList(shots: data.shots),
              ],
            ]),
          );
        },
      ),
    );
  }
}

/// The pinned "Let's start", with a line on what happens next.
class _StartAction extends StatelessWidget {
  const _StartAction({
    required this.hint,
    required this.everyoneIn,
    required this.canStart,
    required this.starting,
    required this.onStart,
  });

  final String? hint;
  final bool everyoneIn;
  final bool canStart;
  final bool starting;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.short),
          child: everyoneIn
              ? StatusPill(
                  key: const ValueKey('everyone-in'),
                  label: hint ?? "Everyone's in",
                  icon: Icons.celebration_rounded,
                  tone: StatusTone.positive,
                )
              : Text(
                  hint ??
                      "Next up: the photobooth. We'll ask to use your camera.",
                  key: ValueKey(hint),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMuted,
                ),
        ),
        const SizedBox(height: AppSpacing.ms),
        PrimaryButton(
          label: starting ? 'Getting ready…' : "Let's start",
          icon: Icons.photo_camera_rounded,
          loading: starting,
          onPressed: canStart ? onStart : null,
        ),
      ],
    );
  }
}
