import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../domain/memories/enum/keepsake_layout.dart';
import '../../molecules/common/md_option_tile.dart';

class MdKeepsakeLayoutTray extends StatelessWidget {
  const MdKeepsakeLayoutTray({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final KeepsakeLayout selected;
  final ValueChanged<KeepsakeLayout> onChanged;

  static IconData _icon(KeepsakeLayout layout) => switch (layout) {
    KeepsakeLayout.strip => Icons.view_agenda_rounded,
    KeepsakeLayout.grid => Icons.grid_view_rounded,
    KeepsakeLayout.polaroid => Icons.crop_portrait_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      child: Row(
        children: [
          for (final layout in KeepsakeLayout.values) ...[
            Expanded(
              child: MdOptionTile(
                label: layout.label,
                selected: layout == selected,
                onTap: () => onChanged(layout),
                child: Icon(_icon(layout), size: AppIconSizes.lg),
              ),
            ),
            if (layout != KeepsakeLayout.values.last)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
