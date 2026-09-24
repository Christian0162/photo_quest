import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../utils/app_haptics.dart';
import '../../view_model/memories/keepsake_view_model.dart';
import '../atoms/loading_indicator.dart';
import '../atoms/primary_button.dart';
import '../atoms/sticker_art.dart';
import '../molecules/empty_state.dart';
import '../organisms/app_scaffold.dart';
import '../organisms/keepsake_canvas.dart';
import '../organisms/keepsake_snapshot.dart';

/// Makes the printed keepsake yours: pick a layout (strip, grid, polaroid),
/// a paper, and add stickers you drag, pinch and turn. The print stays in
/// view the whole time; one tidy tray changes it. Not a photo editor — just
/// the fun of decorating a photobooth print. See CLAUDE.md §36, design
/// system §34, §44, §65.
class KeepsakeTemplate extends StatefulWidget {
  const KeepsakeTemplate({
    super.key,
    required this.design,
    required this.doneLabel,
    required this.onClose,
    required this.onRetry,
    required this.onDone,
    required this.onLayoutChanged,
    required this.onFrameChanged,
    required this.onAddSticker,
    required this.onSelectSticker,
    required this.onTransformSticker,
    required this.onRemoveSticker,
  });

  final AsyncValue<KeepsakeDesign> design;

  /// The primary action's words, e.g. "Save keepsake" or "Done".
  final String doneLabel;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  /// Receives a function that renders the keepsake to PNG bytes.
  final ValueChanged<Future<Uint8List?> Function()> onDone;
  final ValueChanged<KeepsakeLayout> onLayoutChanged;
  final ValueChanged<KeepsakeFrame> onFrameChanged;
  final ValueChanged<StickerType> onAddSticker;
  final ValueChanged<String?> onSelectSticker;
  final void Function(
    String id, {
    required double x,
    required double y,
    required double scale,
    required double rotation,
  })
  onTransformSticker;
  final ValueChanged<String> onRemoveSticker;

  @override
  State<KeepsakeTemplate> createState() => _KeepsakeTemplateState();
}

enum _Tray { layout, paper, stickers }

class _KeepsakeTemplateState extends State<KeepsakeTemplate> {
  final _snapshot = KeepsakeSnapshotController();
  var _tray = _Tray.layout;

  /// True while rendering, so selection outlines aren't printed.
  bool _capturing = false;

  Future<Uint8List?> _render() async {
    setState(() => _capturing = true);
    try {
      return await _snapshot.toPng();
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = widget.design.value;

    return AppScaffold(
      showAppBar: true,
      title: 'Make it yours',
      leading: IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.close_rounded),
        onPressed: widget.onClose,
      ),
      bottomAction: design == null
          ? null
          : PrimaryButton(
              label: widget.doneLabel,
              icon: Icons.check_rounded,
              loading: design.isSaving,
              onPressed: () => widget.onDone(_render),
            ),
      body: widget.design.when(
        loading: () =>
            const LoadingIndicator(message: 'Laying out your print…'),
        error: (error, stack) => EmptyState.error(
          title: "We couldn't open this keepsake",
          onRetry: widget.onRetry,
        ),
        data: (design) => Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: AppSpacing.sm,
                ),
                child: Center(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 16),
                      ],
                    ),
                    child: KeepsakeSnapshot(
                      controller: _snapshot,
                      child: KeepsakeCanvas(
                        design: design,
                        editable: !_capturing && !design.isSaving,
                        onSelectSticker: widget.onSelectSticker,
                        onTransformSticker: widget.onTransformSticker,
                        onRemoveSticker: widget.onRemoveSticker,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _TrayTabs(
              selected: _tray,
              onChanged: (tray) => setState(() => _tray = tray),
            ),
            SizedBox(
              height: 128,
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.short),
                child: KeyedSubtree(
                  key: ValueKey(_tray),
                  child: switch (_tray) {
                    _Tray.layout => _LayoutTray(
                      selected: design.layout,
                      onChanged: widget.onLayoutChanged,
                    ),
                    _Tray.paper => _PaperTray(
                      selected: design.frame,
                      onChanged: widget.onFrameChanged,
                    ),
                    _Tray.stickers => _StickerTray(
                      canAdd: design.canAddSticker,
                      onAdd: widget.onAddSticker,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Layout · Paper · Stickers.
class _TrayTabs extends StatelessWidget {
  const _TrayTabs({required this.selected, required this.onChanged});

  final _Tray selected;
  final ValueChanged<_Tray> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Row(
        children: [
          for (final (tray, label, icon) in const [
            (_Tray.layout, 'Layout', Icons.dashboard_customize_rounded),
            (_Tray.paper, 'Paper', Icons.palette_rounded),
            (_Tray.stickers, 'Stickers', Icons.emoji_emotions_rounded),
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
            if (tray != _Tray.stickers) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _LayoutTray extends StatelessWidget {
  const _LayoutTray({required this.selected, required this.onChanged});

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
              child: _OptionTile(
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

class _PaperTray extends StatelessWidget {
  const _PaperTray({required this.selected, required this.onChanged});

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
        final (paper, ink) = KeepsakeCanvas.colorsOf(frame);
        return SizedBox(
          width: 76,
          child: _OptionTile(
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

class _StickerTray extends StatelessWidget {
  const _StickerTray({required this.canAdd, required this.onAdd});

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
                    borderRadius: BorderRadius.circular(AppRadius.md),
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
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: StickerArt(type: type, size: 40),
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

/// A big, tappable choice. Selected = dark border, tint and a check — never
/// color alone. See design system §17, CLAUDE.md §65.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.short),
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.softPeach : AppColors.paper,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.line,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected) ...[
                    const Icon(Icons.check_rounded, size: AppIconSizes.sm),
                    const SizedBox(width: AppSpacing.xxs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
