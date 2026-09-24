import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/presentation/widget/molecules/app_widget_preview.dart';
import 'package:photoquest/core/presentation/widget/organisms/keepsake_canvas.dart';
import 'package:photoquest/core/domain/memories/enum/keepsake_layout.dart';
import 'package:photoquest/core/domain/memories/enum/sticker_type.dart';
import 'package:photoquest/core/presentation/types/memories/placed_sticker.dart';
import 'package:photoquest/core/presentation/types/memories/keepsake_design.dart';

final _design = KeepsakeDesign(
  memoryId: 'm',
  title: 'Anniversary',
  capturedAt: DateTime(2026, 9, 17),
  shots: const [],
  layout: KeepsakeLayout.polaroid,
  stickers: const [
    PlacedSticker(id: 'heart', type: StickerType.heart, x: 0.5, y: 0.4),
  ],
);

void main() {
  testWidgets('a sticker is picked up and dragged where it is drawn', (
    tester,
  ) async {
    String? selected;
    final moves = <Offset>[];

    await tester.pumpWidget(
      AppWidgetPreview(
        child: Center(
          child: SizedBox(
            width: 300,
            child: KeepsakeCanvas(
              design: _design,
              editable: true,
              onSelectSticker: (id) => selected = id,
              onTransformSticker: (
                id, {
                required x,
                required y,
                required scale,
                required rotation,
              }) => moves.add(Offset(x, y)),
              onRemoveSticker: (_) {},
            ),
          ),
        ),
      ),
    );

    // Anywhere on the sticker as it appears on screen — fingers rarely
    // land on the exact middle.
    final heart = find.byIcon(Icons.favorite_rounded);
    final center = tester.getCenter(heart);
    final upperLeft = tester.getTopLeft(heart) + const Offset(4, 4);

    await tester.tapAt(upperLeft);
    expect(selected, 'heart');

    await tester.dragFrom(center, const Offset(40, 30));
    expect(moves, isNotEmpty);
    expect(moves.last.dx, greaterThan(0.5));
    expect(moves.last.dy, greaterThan(0.4));
  });

  testWidgets('the selected sticker can be removed', (tester) async {
    String? removed;
    await tester.pumpWidget(
      AppWidgetPreview(
        child: Center(
          child: SizedBox(
            width: 300,
            child: KeepsakeCanvas(
              design: _design.copyWith(selectedStickerId: 'heart'),
              editable: true,
              onSelectSticker: (_) {},
              onTransformSticker: (
                id, {
                required x,
                required y,
                required scale,
                required rotation,
              }) {},
              onRemoveSticker: (id) => removed = id,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Remove sticker'));
    expect(removed, 'heart');
  });
}
