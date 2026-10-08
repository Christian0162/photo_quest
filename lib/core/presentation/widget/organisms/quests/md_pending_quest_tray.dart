import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/quests/quest_needing_confirmation.dart';
import '../../atoms/common/md_pressable_scale.dart';
import '../../atoms/people/md_person_avatar.dart';
import '../../atoms/people/md_story_ring.dart';

/// Quests you made that are still waiting on people, laid out like a row of
/// stories: a turning ring round the first friend, a count badge, the quest
/// name underneath. An open loop you can close with one tap, so a group
/// quest doesn't quietly stall. See design system §13, §22, §60.
class MdPendingQuestTray extends StatelessWidget {
  const MdPendingQuestTray({
    super.key,
    required this.entries,
    required this.onOpen,
  });

  final List<QuestNeedingConfirmation> entries;
  final ValueChanged<QuestNeedingConfirmation> onOpen;

  static const _ringSize = 84.0;
  static const _tileWidth = 92.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _Tile(entry: entry, onTap: () => onOpen(entry));
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.entry, required this.onTap});

  final QuestNeedingConfirmation entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final waiting = entry.pendingCount == 1
        ? 'Waiting on 1 person'
        : 'Waiting on ${entry.pendingCount} people';
    final first = entry.people.isEmpty ? null : entry.people.first;
    final inner = MdStoryRing.innerSize(MdPendingQuestTray._ringSize);

    return Semantics(
      button: true,
      label: '${entry.quest.title}. $waiting',
      excludeSemantics: true,
      child: MdPressableScale(
        enabled: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: MdPendingQuestTray._tileWidth,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    MdStoryRing(
                      size: MdPendingQuestTray._ringSize,
                      child: first == null
                          ? ColoredBox(
                              color: AppColors.softPeach,
                              child: SizedBox.square(
                                dimension: inner,
                                child: const Icon(Icons.hourglass_top_rounded),
                              ),
                            )
                          : MdPersonAvatar(person: first, radius: inner / 2),
                    ),
                    Positioned(
                      right: -2,
                      bottom: 0,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.warmCoral,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 3,
                          ),
                        ),
                        child: Text(
                          '${entry.pendingCount}',
                          style: AppTypography.label.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  entry.quest.title,
                  style: AppTypography.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
