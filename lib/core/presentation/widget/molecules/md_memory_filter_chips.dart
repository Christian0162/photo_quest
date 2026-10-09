import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/memories/enum/memory_filter.dart';
import '../../../utils/app_haptics.dart';

/// "This day · This month · All journey" — how to look through the memory
/// box, each with how many memories it holds. The chosen one fills coral;
/// selection is also announced and never relies on color alone.
class MdMemoryFilterChips extends StatelessWidget {
  const MdMemoryFilterChips({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final MemoryFilter selected;
  final Map<MemoryFilter, int> counts;
  final ValueChanged<MemoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final filter in MemoryFilter.values) ...[
            _Chip(
              label: filter.label,
              count: counts[filter] ?? 0,
              selected: filter == selected,
              onTap: () {
                if (filter == selected) return;
                AppHaptics.selection();
                onSelected(filter);
              },
            ),
            if (filter != MemoryFilter.values.last)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.short);

    return Semantics(
      button: true,
      selected: selected,
      label: count == 1 ? '$label, 1 memory' : '$label, $count memories',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.standard,
          height: AppTouch.minTarget - AppSpacing.xs,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.warmCoral : AppColors.paper,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: selected ? AppShadows.card : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Unselected chips carry a small dot, like the reference.
              AnimatedSize(
                duration: duration,
                curve: AppMotion.standard,
                child: selected
                    ? const SizedBox.shrink()
                    : Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        decoration: const BoxDecoration(
                          color: AppColors.warmCoral,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              Text(label, style: AppTypography.label),
              const SizedBox(width: AppSpacing.sm),
              AnimatedContainer(
                duration: duration,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.paper : AppColors.sunken,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text('$count', style: AppTypography.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
