import 'dart:convert';

import '../../../domain/memories/entities/photo.dart';
import '../../../domain/memories/enum/keepsake_frame.dart';
import '../../../domain/memories/enum/keepsake_layout.dart';
import '../../../domain/memories/enum/sticker_type.dart';
import 'placed_sticker.dart';

/// A keepsake being designed: the shots, and how they're printed.
class KeepsakeDesign {
  const KeepsakeDesign({
    required this.memoryId,
    required this.title,
    required this.capturedAt,
    required this.shots,
    this.layout = KeepsakeLayout.strip,
    this.frame = KeepsakeFrame.cream,
    this.stickers = const [],
    this.selectedStickerId,
    this.isSaving = false,
    this.isSaved = false,
  });

  /// Most stickers on one keepsake — keeps the print about the people.
  static const maxStickers = 12;

  final String memoryId;
  final String title;
  final DateTime capturedAt;

  /// Every shot, in order. The print shows their stills; a live print
  /// plays GIFs, boomerangs and 360° clips in place.
  final List<Photo> shots;
  final KeepsakeLayout layout;
  final KeepsakeFrame frame;
  final List<PlacedSticker> stickers;
  final String? selectedStickerId;
  final bool isSaving;

  /// Whether this design was saved with the memory. Prints kept before
  /// designs were saved only have their image, so they're shown as that
  /// image rather than redrawn from a default design.
  final bool isSaved;

  bool get canAddSticker => stickers.length < maxStickers;

  /// The design choices only — layout, paper, stickers — as saved JSON.
  String toJson() => jsonEncode({
    'layout': layout.name,
    'frame': frame.name,
    'stickers': [
      for (final s in stickers)
        {
          'type': s.type.name,
          'x': s.x,
          'y': s.y,
          'scale': s.scale,
          'rotation': s.rotation,
        },
    ],
  });

  /// This design with the choices from saved [json]. Anything unreadable
  /// (e.g. from a newer version) is skipped rather than failing.
  KeepsakeDesign withSaved(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      T? byName<T extends Enum>(List<T> values, Object? name) =>
          values.where((v) => v.name == name).firstOrNull;
      final saved = <PlacedSticker>[];
      for (final (i, raw) in (data['stickers'] as List? ?? []).indexed) {
        final type = byName(StickerType.values, raw['type']);
        if (type == null) continue;
        saved.add(
          PlacedSticker(
            id: 'saved-$i',
            type: type,
            x: (raw['x'] as num).toDouble(),
            y: (raw['y'] as num).toDouble(),
            scale: (raw['scale'] as num).toDouble(),
            rotation: (raw['rotation'] as num).toDouble(),
          ),
        );
      }
      return copyWith(
        layout: byName(KeepsakeLayout.values, data['layout']),
        frame: byName(KeepsakeFrame.values, data['frame']),
        stickers: saved,
        isSaved: true,
      );
    } catch (_) {
      return this;
    }
  }

  KeepsakeDesign copyWith({
    KeepsakeLayout? layout,
    KeepsakeFrame? frame,
    List<PlacedSticker>? stickers,
    String? selectedStickerId,
    bool clearSelection = false,
    bool? isSaving,
    bool? isSaved,
  }) {
    return KeepsakeDesign(
      memoryId: memoryId,
      title: title,
      capturedAt: capturedAt,
      shots: shots,
      layout: layout ?? this.layout,
      frame: frame ?? this.frame,
      stickers: stickers ?? this.stickers,
      selectedStickerId: clearSelection
          ? null
          : selectedStickerId ?? this.selectedStickerId,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
