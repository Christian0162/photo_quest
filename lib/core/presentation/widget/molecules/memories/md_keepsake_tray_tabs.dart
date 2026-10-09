import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../utils/app_haptics.dart';

enum KeepsakeTray { layout, paper, stickers }

/// Layout · Paper · Stickers.
class MdKeepsakeTrayTabs extends StatelessWidget {
  const MdKeepsakeTrayTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final KeepsakeTray selected;
  final ValueChanged<KeepsakeTray> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Row(
        children: [
          for (final (tray, label, icon) in const [
            (KeepsakeTray.layout, 'Layout', Icons.dashboard_customize_rounded),
            (KeepsakeTray.paper, 'Paper', Icons.palette_rounded),
            (KeepsakeTray.stickers, 'Stickers', Icons.emoji_emotions_rounded),
          ]) ...[
            Expanded(
              child: ChoiceChip(
                avatar: Icon(icon, size: AppIconSizes.sm),
                label: SizedBox(
                  width: double.infinity,
                  child: Text(label, textAlign: TextAlign.center),
                ),
                showCheckmark: false,
                selected: tray == selected,
                onSelected: (_) {
                  AppHaptics.selection();
                  onChanged(tray);
                },
              ),
            ),
            if (tray != KeepsakeTray.stickers)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
