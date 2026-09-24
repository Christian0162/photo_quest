import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, visibleForTesting;
import 'package:image/image.dart' as img;

import '../../../../config/constant/app_image_sizes.dart';
import '../../../domain/camera/enum/camera_frame_format.dart';
import '../../../domain/memories/enum/photo_look.dart';
import '../camera/camera_frame.dart';

/// Reports how far along a long job is, from 0 to 1.
typedef ProgressCallback = void Function(double progress);

/// A finished GIF or boomerang plus a still poster frame for cards, strips
/// and keepsakes.
class AnimationResult {
  const AnimationResult({
    required this.gif,
    required this.poster,
    required this.width,
    required this.height,
  });

  final Uint8List gif;
  final Uint8List poster;
  final int width;
  final int height;
}

/// Owns local image manipulation: looks (filters), resizing, thumbnails,
/// GIFs and boomerangs, and photo-strip composition. Everything heavy runs
/// off the UI thread via `compute`. See CLAUDE.md §7, §46.
class ImageProcessingService {
  Future<Uint8List> createThumbnail(Uint8List originalBytes) {
    return compute(_createThumbnail, originalBytes);
  }

  /// Applies [look] to a captured photo and returns a JPEG. Orientation is
  /// baked in so the result displays upright everywhere.
  Future<Uint8List> applyLook(Uint8List photoBytes, PhotoLook look) {
    if (look.isNatural) return Future.value(photoBytes);
    return compute(_applyLookJpg, (photoBytes, look.matrix));
  }

  /// A stop-motion GIF from a few photos taken a moment apart, one frame
  /// per photo. Null if none of the photos could be read.
  Future<AnimationResult?> createGif(
    List<Uint8List> photos, {
    required PhotoLook look,
    ProgressCallback? onProgress,
  }) {
    final matrix = look.matrix;
    return _runWithProgress(
      (report) => _createGif(photos, matrix, report),
      onProgress,
    );
  }

  /// A boomerang from a quick burst of camera [frames]: played forward,
  /// then backward, on loop. Null if no frame could be read.
  Future<AnimationResult?> createBoomerang(
    List<CameraFrame> frames, {
    required PhotoLook look,
    ProgressCallback? onProgress,
  }) {
    final matrix = look.matrix;
    return _runWithProgress(
      (report) => _createBoomerang(frames, matrix, report),
      onProgress,
    );
  }

  /// Runs [work] on a background isolate, forwarding its progress reports
  /// back to [onProgress] on this one.
  static Future<R> _runWithProgress<R>(
    R Function(ProgressCallback report) work,
    ProgressCallback? onProgress,
  ) async {
    final port = ReceivePort();
    port.listen((message) {
      if (message is double) onProgress?.call(message);
    });
    try {
      final result = await _runInIsolate(work, port.sendPort);
      // The isolate's last report can arrive after its result; finish at
      // 100% either way.
      onProgress?.call(1);
      return result;
    } finally {
      port.close();
    }
  }

  /// Starts [work] on a new isolate. Kept separate on purpose: a closure
  /// carries every variable its function's closures use, so building it
  /// here means only [work] and [progress] are sent — never the caller's
  /// progress listener, which holds app state that can't cross isolates.
  static Future<R> _runInIsolate<R>(
    R Function(ProgressCallback report) work,
    SendPort progress,
  ) {
    return Isolate.run(() => work(progress.send));
  }

  /// Converts a rendered keepsake (PNG) to a shareable JPEG.
  Future<Uint8List> encodeKeepsake(Uint8List pngBytes) {
    return compute(_pngToJpg, pngBytes);
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
      final decoded = img.decodeImage(bytes);
      return decoded == null ? null : img.bakeOrientation(decoded);
    } catch (_) {
      return null;
    }
  }

  static Uint8List _createThumbnail(Uint8List bytes) {
    final decoded = _tryDecode(bytes);
    if (decoded == null) return bytes;
    final resized = img.copyResize(
      decoded,
      width: AppImageSizes.thumbnailWidth,
    );
    return Uint8List.fromList(
      img.encodeJpg(resized, quality: AppImageSizes.thumbnailJpegQuality),
    );
  }

  static Uint8List _applyLookJpg((Uint8List, List<double>) request) {
    final (bytes, matrix) = request;
    final decoded = _tryDecode(bytes);
    if (decoded == null) return bytes;
    applyColorMatrix(decoded, matrix);
    return Uint8List.fromList(
      img.encodeJpg(decoded, quality: AppImageSizes.originalJpegQuality),
    );
  }

  /// Applies a 4×5 RGBA color [matrix] (offsets in 0–255, the same format
  /// as Flutter's `ColorFilter.matrix`) to every pixel of [image], in place.
  @visibleForTesting
  static void applyColorMatrix(img.Image image, List<double> matrix) {
    if (_isIdentity(matrix)) return;
    final m = matrix;
    for (final p in image) {
      final r = p.r, g = p.g, b = p.b, a = p.a;
      p
        ..r = (m[0] * r + m[1] * g + m[2] * b + m[3] * a + m[4]).clamp(0, 255)
        ..g = (m[5] * r + m[6] * g + m[7] * b + m[8] * a + m[9]).clamp(0, 255)
        ..b = (m[10] * r + m[11] * g + m[12] * b + m[13] * a + m[14]).clamp(
          0,
          255,
        );
    }
  }

  static bool _isIdentity(List<double> m) {
    const identity = [
      1.0, 0.0, 0.0, 0.0, 0.0, //
      0.0, 1.0, 0.0, 0.0, 0.0, //
      0.0, 0.0, 1.0, 0.0, 0.0, //
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
    for (var i = 0; i < identity.length; i++) {
      if (m[i] != identity[i]) return false;
    }
    return true;
  }

  static AnimationResult? _createGif(
    List<Uint8List> photos,
    List<double> matrix,
    ProgressCallback report,
  ) {
    // Reading the photos is the first 30%, encoding the rest.
    final frames = <img.Image>[];
    for (var i = 0; i < photos.length; i++) {
      final frame = _tryDecode(photos[i]);
      if (frame != null) {
        applyColorMatrix(frame, matrix);
        frames.add(frame);
      }
      report(0.3 * (i + 1) / photos.length);
    }
    if (frames.isEmpty) return null;
    // Half a second per pose — the rhythm of a classic GIF booth.
    return _encodeAnimation(
      frames,
      frameCentis: 50,
      report: (p) => report(0.3 + 0.7 * p),
    );
  }

  static AnimationResult? _createBoomerang(
    List<CameraFrame> cameraFrames,
    List<double> matrix,
    ProgressCallback report,
  ) {
    // Turning raw frames into pictures is the first 40%, encoding the rest.
    final frames = <img.Image>[];
    for (var i = 0; i < cameraFrames.length; i++) {
      final frame = _frameToImage(cameraFrames[i]);
      if (frame != null) {
        applyColorMatrix(frame, matrix);
        frames.add(frame);
      }
      report(0.4 * (i + 1) / cameraFrames.length);
    }
    if (frames.isEmpty) return null;
    // Forward, then back again without repeating the end frames.
    final pingPong = [
      ...frames,
      if (frames.length > 2) ...frames.reversed.skip(1).take(frames.length - 2),
    ];
    return _encodeAnimation(
      pingPong,
      frameCentis: 7,
      report: (p) => report(0.4 + 0.6 * p),
    );
  }

  static AnimationResult _encodeAnimation(
    List<img.Image> frames, {
    required int frameCentis,
    required ProgressCallback report,
  }) {
    final poster = frames.first.width > AppImageSizes.posterWidth
        ? img.copyResize(frames.first, width: AppImageSizes.posterWidth)
        : frames.first;

    final encoder = img.GifEncoder(samplingFactor: 20);
    img.Image? first;
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final small = frame.width > AppImageSizes.animationWidth
          ? img.copyResize(frame, width: AppImageSizes.animationWidth)
          : frame;
      first ??= small;
      encoder.addFrame(small, duration: frameCentis);
      report((i + 1) / (frames.length + 1));
    }

    final gif = encoder.finish()!;
    report(1);
    return AnimationResult(
      gif: gif,
      poster: Uint8List.fromList(
        img.encodeJpg(poster, quality: AppImageSizes.printJpegQuality),
      ),
      width: first!.width,
      height: first.height,
    );
  }

  /// Converts a raw camera stream frame into an upright RGB image.
  @visibleForTesting
  static img.Image? frameToImage(CameraFrame frame) => _frameToImage(frame);

  static img.Image? _frameToImage(CameraFrame frame) {
    final image = img.Image(width: frame.width, height: frame.height);
    switch (frame.format) {
      case CameraFrameFormat.yuv420:
        if (frame.planes.length < 3) return null;
        final yPlane = frame.planes[0];
        final uPlane = frame.planes[1];
        final vPlane = frame.planes[2];
        final uvPixelStride = uPlane.bytesPerPixel ?? 1;
        for (var y = 0; y < frame.height; y++) {
          for (var x = 0; x < frame.width; x++) {
            final yValue = yPlane.bytes[y * yPlane.bytesPerRow + x];
            final uvIndex =
                (y >> 1) * uPlane.bytesPerRow + (x >> 1) * uvPixelStride;
            final u = uPlane.bytes[uvIndex] - 128;
            final v = vPlane.bytes[uvIndex] - 128;
            image.setPixelRgb(
              x,
              y,
              (yValue + 1.402 * v).clamp(0, 255).round(),
              (yValue - 0.344136 * u - 0.714136 * v).clamp(0, 255).round(),
              (yValue + 1.772 * u).clamp(0, 255).round(),
            );
          }
        }
      case CameraFrameFormat.bgra8888:
        final plane = frame.planes.first;
        for (var y = 0; y < frame.height; y++) {
          for (var x = 0; x < frame.width; x++) {
            final i = y * plane.bytesPerRow + x * 4;
            image.setPixelRgb(
              x,
              y,
              plane.bytes[i + 2],
              plane.bytes[i + 1],
              plane.bytes[i],
            );
          }
        }
    }
    return frame.rotationDegrees % 360 == 0
        ? image
        : img.copyRotate(image, angle: frame.rotationDegrees);
  }

  static Uint8List _pngToJpg(Uint8List pngBytes) {
    final decoded = img.decodePng(pngBytes);
    if (decoded == null) return pngBytes;
    return Uint8List.fromList(
      img.encodeJpg(decoded, quality: AppImageSizes.originalJpegQuality),
    );
  }

  static Uint8List _composePhotoStrip((List<Uint8List>, String) request) {
    final (photos, caption) = request;
    const margin = AppImageSizes.stripMargin;
    const gap = AppImageSizes.stripGap;
    const footerHeight = AppImageSizes.stripFooterHeight;
    const stripWidth = AppImageSizes.stripWidth;
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

    return Uint8List.fromList(
      img.encodeJpg(strip, quality: AppImageSizes.printJpegQuality),
    );
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
