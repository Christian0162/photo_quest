import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/memories/enum/photo_look.dart';
import '../../../utils/app_haptics.dart';

/// A small row of looks (filters) over the camera. Each swatch shows a warm
/// sample scene through that look, so the choice is visual, with its name
/// underneath. The chosen look gets a coral ring and a bold name — never
/// color alone. See CLAUDE.md §2.4, design system §44, §53.
class LookPicker extends StatelessWidget {
  const LookPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PhotoLook selected;
  final ValueChanged<PhotoLook> onChanged;

  static const _swatch = 44.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _swatch + AppSpacing.xl,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: PhotoLook.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.ms),
        itemBuilder: (context, index) {
          final look = PhotoLook.values[index];
          final isSelected = look == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            label: '${look.label} look',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                AppHaptics.selection();
                onChanged(look);
              },
              child: SizedBox(
                width: AppTouch.minTarget + AppSpacing.md,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.of(context, AppMotion.short),
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.warmCoral
                              : AppColors.onCameraMuted,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: ClipOval(
                        child: SizedBox.square(
                          dimension: _swatch - AppSpacing.sm,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(look.matrix),
                            child: const _SampleScene(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      look.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: isSelected
                            ? AppColors.onCamera
                            : AppColors.onCameraMuted,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A tiny sunset-and-skin-tone scene that shows how a look shifts warmth,
/// color and contrast.
class _SampleScene extends StatelessWidget {
  const _SampleScene();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lookSampleSky,
            AppColors.filmYellow,
            AppColors.warmCoral,
            AppColors.lookSampleShadow,
          ],
        ),
      ),
    );
  }
}
