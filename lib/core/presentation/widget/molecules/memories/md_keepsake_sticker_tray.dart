import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/memories/enum/sticker_type.dart';
import '../../../../utils/app_haptics.dart';
import '../../atoms/memories/md_sticker_art.dart';

class MdKeepsakeStickerTray extends StatelessWidget {
  const MdKeepsakeStickerTray({
    super.key,
    required this.canAdd,
    required this.onAdd,
  });

  final bool canAdd;
  final ValueChanged<StickerType> onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.sm,
            AppSpacing.gutter,
            0,
          ),
          child: Text(
            canAdd
                ? 'Tap to add · drag to move · pinch to resize and turn'
                : "That's plenty of stickers! Remove one to add another.",
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.sm,
            ),
            itemCount: StickerType.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final type = StickerType.values[index];
              return Semantics(
                button: true,
                enabled: canAdd,
                label: 'Add ${type.label} sticker',
                excludeSemantics: true,
                child: Opacity(
                  opacity: canAdd ? 1 : 0.4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.base),
                    onTap: canAdd
                        ? () {
                            AppHaptics.selection();
                            onAdd(type);
                          }
                        : null,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: AppTouch.minTarget + AppSpacing.md,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.sunken,
                        borderRadius: BorderRadius.circular(AppRadius.base),
                      ),
                      alignment: Alignment.center,
                      child: MdStickerArt(type: type, size: 40),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
