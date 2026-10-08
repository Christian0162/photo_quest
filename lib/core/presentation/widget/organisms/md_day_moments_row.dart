import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/moments/entities/day_moment.dart';
import '../../../utils/app_haptics.dart';
import '../../types/moment_time_label.dart';
import '../atoms/md_local_photo.dart';
import '../atoms/md_skeleton_box.dart';

/// "Your Day": a shelf of small round moments that fade after 24 hours,
/// starting with a tile to add one. Private to this phone. See CLAUDE.md
/// §2.1, §54A.
class MdDayMomentsRow extends StatelessWidget {
  const MdDayMomentsRow({
    super.key,
    required this.moments,
    required this.now,
    required this.onAdd,
    required this.onOpen,
  });

  final AsyncValue<List<DayMoment>> moments;
  final DateTime now;
  final VoidCallback onAdd;
  final ValueChanged<DayMoment> onOpen;

  static const _bubble = 68.0;

  @override
  Widget build(BuildContext context) {
    final list = moments.value ?? const <DayMoment>[];

    // Sizes to its content (so large text never clips), and scrolls
    // sideways when the moments outgrow the screen.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AddTile(onTap: onAdd),
          if (moments.isLoading && !moments.hasValue)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.md),
              child: MdSkeletonBox(
                width: _bubble,
                height: _bubble,
                radius: _bubble / 2,
              ),
            ),
          for (final moment in list)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: _MomentBubble(
                moment: moment,
                label: moment.timeLeftLabel(now),
                onTap: () => onOpen(moment),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add to Your Day',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          AppHaptics.tap();
          onTap();
        },
        child: SizedBox(
          width: MdDayMomentsRow._bubble + AppSpacing.sm,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: MdDayMomentsRow._bubble,
                    height: MdDayMomentsRow._bubble,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sunken,
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      size: AppIconSizes.lg,
                    ),
                  ),
                  Positioned(
                    right: -AppSpacing.xxs,
                    bottom: -AppSpacing.xxs,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warmCoral,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: AppIconSizes.sm,
                        color: AppColors.onCoral,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text('Your Day', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _MomentBubble extends StatelessWidget {
  const _MomentBubble({
    required this.moment,
    required this.label,
    required this.onTap,
  });

  final DayMoment moment;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open moment, $label',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          AppHaptics.tap();
          onTap();
        },
        child: SizedBox(
          width: MdDayMomentsRow._bubble + AppSpacing.sm,
          child: Column(
            children: [
              Container(
                width: MdDayMomentsRow._bubble,
                height: MdDayMomentsRow._bubble,
                padding: const EdgeInsets.all(AppSpacing.xxs + 1),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warmCoral,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                  ),
                  child: ClipOval(
                    child: MdLocalPhoto(
                      path: moment.thumbnailPath,
                      decodeWidth: MdDayMomentsRow._bubble,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: AppTypography.caption, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
