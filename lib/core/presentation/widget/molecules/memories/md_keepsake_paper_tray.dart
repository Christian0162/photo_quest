import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/memories/enum/keepsake_frame.dart';
import '../../molecules/common/md_option_tile.dart';
import '../../organisms/memories/md_keepsake_canvas.dart';

class MdKeepsakePaperTray extends StatelessWidget {
  const MdKeepsakePaperTray({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final KeepsakeFrame selected;
  final ValueChanged<KeepsakeFrame> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppSpacing.gutter),
      itemCount: KeepsakeFrame.values.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (context, index) {
        final frame = KeepsakeFrame.values[index];
        final (paper, ink) = MdKeepsakeCanvas.colorsOf(frame);
        return SizedBox(
          width: 76,
          child: MdOptionTile(
            label: frame.label,
            selected: frame == selected,
            onTap: () => onChanged(frame),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: paper,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                'Aa',
                style: AppTypography.caption.copyWith(
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
