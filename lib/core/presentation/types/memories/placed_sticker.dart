import '../../../domain/memories/enum/sticker_type.dart';

/// One sticker placed on the keepsake. Position and size are relative to
/// the keepsake, so the design renders identically at any size.
class PlacedSticker {
  const PlacedSticker({
    required this.id,
    required this.type,
    this.x = 0.5,
    this.y = 0.4,
    this.scale = 1,
    this.rotation = 0,
  });

  final String id;
  final StickerType type;

  final double x;
  final double y;

  final double scale;

  final double rotation;

  PlacedSticker copyWith({
    double? x,
    double? y,
    double? scale,
    double? rotation,
  }) {
    return PlacedSticker(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}
