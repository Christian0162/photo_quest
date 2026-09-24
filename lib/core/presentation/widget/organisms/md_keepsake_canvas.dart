import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/memories/enum/keepsake_frame.dart';
import '../../../domain/memories/enum/keepsake_layout.dart';
import '../../../utils/app_haptics.dart';
import '../../types/memories/keepsake_design.dart';
import '../../types/memories/placed_sticker.dart';
import '../atoms/md_local_photo.dart';
import '../atoms/md_sticker_art.dart';
import '../molecules/md_shot_media.dart';

/// The printed keepsake — strip, grid or polaroid — on its paper, with the
/// title handwritten and any stickers on top. Everything is proportional to
/// the canvas width, so the exact same design renders on screen and into
/// the saved image. When [editable], stickers can be tapped to select,
/// dragged, pinched and rotated. When [live], GIFs and boomerangs play in
/// their frames and 360° clips loop — the saved image always uses shots.
/// See CLAUDE.md §36, design system §34.
class MdKeepsakeCanvas extends StatelessWidget {
  const MdKeepsakeCanvas({
    super.key,
    required this.design,
    this.editable = false,
    this.live = false,
    this.onSelectSticker,
    this.onTransformSticker,
    this.onRemoveSticker,
  });

  final KeepsakeDesign design;
  final bool editable;
  final bool live;
  final ValueChanged<String?>? onSelectSticker;
  final void Function(
    String id, {
    required double x,
    required double y,
    required double scale,
    required double rotation,
  })?
  onTransformSticker;
  final ValueChanged<String>? onRemoveSticker;

  /// Paper and ink for each frame. Ink always reads at 4.5:1 on its paper.
  static (Color, Color) colorsOf(KeepsakeFrame frame) => switch (frame) {
    KeepsakeFrame.cream => (AppColors.printPaper, AppColors.inkBrown),
    KeepsakeFrame.film => (AppColors.warmCharcoal, AppColors.warmCream),
    KeepsakeFrame.coral => (AppColors.warmCoral, AppColors.warmCharcoal),
    KeepsakeFrame.sunny => (AppColors.filmYellow, AppColors.warmCharcoal),
    KeepsakeFrame.mint => (AppColors.softGreen, AppColors.warmCharcoal),
  };

  /// Width ÷ height of the keepsake for [design].
  static double aspectRatioOf(KeepsakeDesign design) {
    final m = _Metrics(design, 1);
    return 1 / m.height;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatioOf(design),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final m = _Metrics(design, width);
          final (paper, ink) = colorsOf(design.frame);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: editable ? () => onSelectSticker?.call(null) : null,
            child: Container(
              color: paper,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  for (final slot in m.slots)
                    Positioned.fromRect(
                      rect: slot.rect,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(width * 0.012),
                        child: _SlotMedia(shot: slot.shot, live: live),
                      ),
                    ),
                  Positioned(
                    left: m.padding,
                    right: m.padding,
                    top: m.footerTop,
                    height: m.footerHeight,
                    child: _Footer(
                      title: design.title,
                      date: design.capturedAt,
                      ink: ink,
                      width: width,
                    ),
                  ),
                  for (final sticker in design.stickers)
                    _PlacedStickerView(
                      key: ValueKey(sticker.id),
                      sticker: sticker,
                      canvas: Size(width, m.height),
                      baseSize: width * 0.2,
                      selected:
                          editable && sticker.id == design.selectedStickerId,
                      editable: editable,
                      onSelect: () => onSelectSticker?.call(sticker.id),
                      onTransform: onTransformSticker,
                      onRemove: () => onRemoveSticker?.call(sticker.id),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Where everything goes on a keepsake [width] wide.
class _Metrics {
  _Metrics(KeepsakeDesign design, double width) {
    padding = width * 0.06;
    final gap = width * 0.03;
    final inner = width - padding * 2;
    final List<Photo?> shots = design.shots.isEmpty
        ? const [null]
        : design.shots;
    var y = padding;

    switch (design.layout) {
      case KeepsakeLayout.strip:
        // Landscape frames, like a real booth strip.
        final h = inner * 3 / 4;
        for (final shot in shots.take(6)) {
          slots.add(_Slot(shot, Rect.fromLTWH(padding, y, inner, h)));
          y += h + gap;
        }
        y -= gap;
        footerHeight = width * 0.34;
      case KeepsakeLayout.grid:
        final cell = (inner - gap) / 2;
        for (var i = 0; i < shots.length; i += 2) {
          final isLastAlone = i == shots.length - 1;
          if (isLastAlone) {
            // An odd one out spans the row instead of leaving a hole.
            final h = shots.length == 1 ? inner : cell;
            slots.add(_Slot(shots[i], Rect.fromLTWH(padding, y, inner, h)));
            y += h + gap;
          } else {
            slots
              ..add(_Slot(shots[i], Rect.fromLTWH(padding, y, cell, cell)))
              ..add(
                _Slot(
                  shots[i + 1],
                  Rect.fromLTWH(padding + cell + gap, y, cell, cell),
                ),
              );
            y += cell + gap;
          }
        }
        y -= gap;
        footerHeight = width * 0.26;
      case KeepsakeLayout.polaroid:
        slots.add(_Slot(shots.first, Rect.fromLTWH(padding, y, inner, inner)));
        y += inner;
        footerHeight = width * 0.3;
    }
    footerTop = y;
    height = y + footerHeight;
  }

  late final double padding;
  late final double footerTop;
  late final double footerHeight;
  late final double height;
  final slots = <_Slot>[];
}

class _Slot {
  const _Slot(this.shot, this.rect);

  /// Null shows the photo placeholder.
  final Photo? shot;
  final Rect rect;
}

/// One photo on the print: its still, or — when [live] — the GIF,
/// boomerang or 360° clip playing in place.
class _SlotMedia extends StatelessWidget {
  const _SlotMedia({required this.shot, required this.live});

  final Photo? shot;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final shot = this.shot;
    if (shot == null) return const MdLocalPhoto(path: null);
    if (live && shot.kind != PhotoKind.photo) {
      return MdShotMedia(photo: shot);
    }
    return MdLocalPhoto(
      path: shot.stillPath,
      // Faces tend to sit above center.
      alignment: const Alignment(0, -0.25),
    );
  }
}

/// The handwritten title and a small date line, like writing on a print.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.title,
    required this.date,
    required this.ink,
    required this.width,
  });

  final String title;
  final DateTime date;
  final Color ink;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            style: AppTypography.script.copyWith(
              color: ink,
              fontSize: width * 0.09,
              height: 1.1,
            ),
          ),
        ),
        SizedBox(height: width * 0.015),
        Text(
          '${DateFormat.yMMMd().format(date).toUpperCase()}  ·  PHOTO QUEST',
          maxLines: 1,
          style: AppTypography.overline.copyWith(
            color: ink,
            fontSize: width * 0.032,
            letterSpacing: width * 0.004,
          ),
        ),
      ],
    );
  }
}

/// One sticker on the canvas. While editable: tap selects, one finger
/// drags, two fingers resize and rotate. The selected sticker gets an
/// outline and a remove button (48px target); screen readers get a
/// "Remove sticker" action.
class _PlacedStickerView extends StatefulWidget {
  const _PlacedStickerView({
    super.key,
    required this.sticker,
    required this.canvas,
    required this.baseSize,
    required this.selected,
    required this.editable,
    required this.onSelect,
    required this.onTransform,
    required this.onRemove,
  });

  final PlacedSticker sticker;
  final Size canvas;
  final double baseSize;
  final bool selected;
  final bool editable;
  final VoidCallback onSelect;
  final void Function(
    String id, {
    required double x,
    required double y,
    required double scale,
    required double rotation,
  })?
  onTransform;
  final VoidCallback onRemove;

  @override
  State<_PlacedStickerView> createState() => _PlacedStickerViewState();
}

class _PlacedStickerViewState extends State<_PlacedStickerView> {
  late double _startScale;
  late double _startRotation;

  @override
  Widget build(BuildContext context) {
    final s = widget.sticker;
    final size = widget.baseSize * s.scale;

    // A halo around the art: a comfortable touch area for small stickers,
    // with room for the remove button fully inside it.
    const halo = AppTouch.minTarget / 2;
    Widget art = MdStickerArt(type: s.type, size: size);
    if (widget.selected) {
      art = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.warmCoral, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: art,
        ),
      );
    }

    Widget child = Stack(
      children: [
        Padding(padding: const EdgeInsets.all(halo), child: art),
        if (widget.selected)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove sticker',
              onPressed: () {
                AppHaptics.remove();
                widget.onRemove();
              },
              icon: const Icon(Icons.close_rounded, size: AppIconSizes.sm),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.warmCharcoal,
                foregroundColor: AppColors.warmCream,
                fixedSize: const Size.square(AppTouch.minTarget),
                padding: const EdgeInsets.all(AppSpacing.ms),
              ),
            ),
          ),
      ],
    );
    child = Transform.rotate(angle: s.rotation, child: child);

    if (widget.editable) {
      child = Semantics(
        button: true,
        selected: widget.selected,
        label: '${s.type.label} sticker',
        onTapHint: 'select',
        customSemanticsActions: {
          const CustomSemanticsAction(label: 'Remove sticker'): widget.onRemove,
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            AppHaptics.selection();
            widget.onSelect();
          },
          onScaleStart: (_) {
            _startScale = s.scale;
            _startRotation = s.rotation;
            if (!widget.selected) widget.onSelect();
          },
          onScaleUpdate: (details) {
            final current = widget.sticker;
            widget.onTransform?.call(
              current.id,
              x: current.x + details.focalPointDelta.dx / widget.canvas.width,
              y: current.y + details.focalPointDelta.dy / widget.canvas.height,
              scale: _startScale * details.scale,
              rotation: _startRotation + details.rotation,
            );
          },
          child: child,
        ),
      );
    } else {
      child = ExcludeSemantics(child: child);
    }

    // Centered on (x, y). The touch area moves with the art because the
    // shift is applied outside the gesture detector.
    return Positioned(
      left: s.x * widget.canvas.width,
      top: s.y * widget.canvas.height,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: child,
      ),
    );
  }
}
