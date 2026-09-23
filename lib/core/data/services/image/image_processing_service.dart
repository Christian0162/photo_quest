import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

/// Owns local image manipulation: resizing, thumbnails, and photo-strip
/// composition. Runs off the UI thread via `compute`. See CLAUDE.md §7.
class ImageProcessingService {
  static const thumbnailWidth = 480;
  static const stripWidth = 800;

  Future<Uint8List> createThumbnail(Uint8List originalBytes) {
    return compute(_createThumbnail, originalBytes);
  }

  /// Lays [photos] out as a physical photobooth print with a "PHOTO QUEST"
  /// footer and [caption] (usually the date). See CLAUDE.md §36.
  Future<Uint8List> composePhotoStrip(
    List<Uint8List> photos, {
    required String caption,
  }) {
    return compute(_composePhotoStrip, (photos, caption));
  }

  /// Decodes [bytes], or null for a corrupted/unsupported image — some
  /// decoders throw on garbage instead of returning null. See CLAUDE.md §42.
  static img.Image? _tryDecode(Uint8List bytes) {
    try {
      return img.decodeImage(bytes);
    } catch (_) {
      return null;
    }
  }

  static Uint8List _createThumbnail(Uint8List bytes) {
    final decoded = _tryDecode(bytes);
    if (decoded == null) return bytes;
    final resized = img.copyResize(decoded, width: thumbnailWidth);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  static Uint8List _composePhotoStrip((List<Uint8List>, String) request) {
    final (photos, caption) = request;
    const margin = 40;
    const gap = 24;
    const footerHeight = 176;
    const photoWidth = stripWidth - margin * 2;

    final decoded = photos
        .map(_tryDecode)
        .whereType<img.Image>()
        .map((image) => img.copyResize(image, width: photoWidth))
        .toList();

    if (decoded.isEmpty) return Uint8List(0);

    final totalHeight =
        margin +
        decoded.fold<int>(0, (sum, image) => sum + image.height) +
        gap * (decoded.length - 1) +
        footerHeight;

    // AppColors.warmCream paper, AppColors.warmCharcoal ink.
    final strip = img.Image(width: stripWidth, height: totalHeight);
    img.fill(strip, color: img.ColorRgb8(255, 249, 243));
    final ink = img.ColorRgb8(37, 35, 35);

    var y = margin;
    for (final photo in decoded) {
      img.compositeImage(strip, photo, dstX: margin, dstY: y);
      y += photo.height + gap;
    }

    final footerTop = y - gap + margin;
    _drawCentered(strip, 'PHOTO QUEST', img.arial48, footerTop, ink);
    _drawCentered(strip, caption, img.arial24, footerTop + 64, ink);

    return Uint8List.fromList(img.encodeJpg(strip, quality: 90));
  }

  static void _drawCentered(
    img.Image image,
    String text,
    img.BitmapFont font,
    int y,
    img.Color color,
  ) {
    final width = text.codeUnits.fold<int>(
      0,
      (sum, c) => sum + (font.characters[c]?.xAdvance ?? 0),
    );
    img.drawString(
      image,
      text,
      font: font,
      x: ((image.width - width) / 2).round(),
      y: y,
      color: color,
    );
  }
}
