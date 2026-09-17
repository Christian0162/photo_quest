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

  Future<Uint8List> composePhotoStrip(List<Uint8List> photos) {
    return compute(_composePhotoStrip, photos);
  }

  static Uint8List _createThumbnail(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized = img.copyResize(decoded, width: thumbnailWidth);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  static Uint8List _composePhotoStrip(List<Uint8List> photos) {
    final decoded = photos
        .map(img.decodeImage)
        .whereType<img.Image>()
        .map((image) => img.copyResize(image, width: stripWidth))
        .toList();

    if (decoded.isEmpty) return Uint8List(0);

    const padding = 24;
    final totalHeight =
        decoded.fold<int>(0, (sum, image) => sum + image.height) +
        padding * (decoded.length + 1);

    final strip = img.Image(width: stripWidth, height: totalHeight);
    img.fill(strip, color: img.ColorRgb8(255, 249, 243)); // AppColors.warmCream

    var y = padding;
    for (final photo in decoded) {
      img.compositeImage(strip, photo, dstX: 0, dstY: y);
      y += photo.height + padding;
    }

    return Uint8List.fromList(img.encodeJpg(strip, quality: 90));
  }
}
