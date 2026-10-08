import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, visibleForTesting;
import 'package:image/image.dart' as img;

import '../../../../config/constant/app_image_sizes.dart';
import '../../../domain/camera/enum/camera_frame_format.dart';
import '../../../domain/memories/enum/photo_look.dart';
import '../../../utils/stage_timer.dart';
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
    this.timings = '',
  });

  final Uint8List gif;
  final Uint8List poster;
  final int width;
  final int height;

  /// Per-stage timings, for comparing speed. TIMING: remove with
  /// `StageTimer` once profiling is done.
  final String timings;
}

/// Owns local image manipulation: looks (filters), resizing, thumbnails,
/// GIFs and boomerangs, and photo-strip composition. Everything heavy runs
/// off the UI thread via `compute`. See CLAUDE.md §7, §46.
class ImageProcessingService {
  /// A small JPEG of [originalBytes]. With [mirror] the thumbnail is also
  /// flipped left-right (after shrinking, so it is cheap).
  Future<Uint8List> createThumbnail(
    Uint8List originalBytes, {
    bool mirror = false,
  }) {
    return compute(_createThumbnail, (originalBytes, mirror));
  }

  /// Applies [look] to a captured photo and returns a JPEG. Orientation is
  /// baked in so the result displays upright everywhere.
  Future<Uint8List> applyLook(Uint8List photoBytes, PhotoLook look) {
    if (look.isNatural) return Future.value(photoBytes);
    return compute(_applyLookJpg, (photoBytes, look.matrix));
  }

  /// A stop-motion GIF from a few photos taken a moment apart, one frame
  /// per photo. Null if none of the photos could be read. Set [mirror] when
  /// the photos came unflipped from a camera whose preview is mirrored.
  Future<AnimationResult?> createGif(
    List<Uint8List> photos, {
    required PhotoLook look,
    bool mirror = false,
    ProgressCallback? onProgress,
  }) {
    final matrix = look.matrix;
    return _runWithProgress(
      (report) => _createGif(photos, matrix, mirror, report),
      onProgress,
    );
  }

  /// A boomerang from a quick burst of camera [frames]: played forward,
  /// then backward, on loop. Null if no frame could be read.
  Future<AnimationResult?> createBoomerang(
    List<CameraFrame> frames, {
    required PhotoLook look,
    bool mirror = false,
    ProgressCallback? onProgress,
  }) {
    final matrix = look.matrix;
    return _runWithProgress(
      (report) => _createBoomerang(frames, matrix, mirror, report),
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

  /// Width and height of an encoded image, read from its header alone — no
  /// pixels are decoded. (0, 0) for an unreadable image.
  static (int, int) sizeOf(Uint8List bytes) {
    try {
      final info = img.findDecoderForData(bytes)?.startDecode(bytes);
      return (info?.width ?? 0, info?.height ?? 0);
    } catch (_) {
      return (0, 0);
    }
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

  static Uint8List _createThumbnail((Uint8List, bool) request) {
    final (bytes, mirror) = request;
    final decoded = _tryDecode(bytes);
    if (decoded == null) return bytes;
    final resized = img.copyResize(
      decoded,
      width: AppImageSizes.thumbnailWidth,
    );
    return Uint8List.fromList(
      img.encodeJpg(
        mirror ? img.flipHorizontal(resized) : resized,
        quality: AppImageSizes.thumbnailJpegQuality,
      ),
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

  /// Shrinks [image] to [width] if it is wider; otherwise returns it as is.
  static img.Image _fitWidth(img.Image image, int width) =>
      image.width > width ? img.copyResize(image, width: width) : image;

  static AnimationResult? _createGif(
    List<Uint8List> photos,
    List<double> matrix,
    bool mirror,
    ProgressCallback report,
  ) {
    final timer = StageTimer(); // TIMING
    // One frame at a time: decode, shrink, flip, colour, hand to the
    // encoder, let go. Nothing full-size is kept once its frame is added.
    final encoder = img.GifEncoder(samplingFactor: 20);
    Uint8List? poster;
    int? width;
    int? height;

    for (var i = 0; i < photos.length; i++) {
      final decoded = timer.time('decode', () => _tryDecode(photos[i]));
      if (decoded != null) {
        final img.Image small;
        if (poster == null) {
          // The first frame doubles as the poster, which is kept larger.
          var still = timer.time(
            'resize',
            () => _fitWidth(decoded, AppImageSizes.posterWidth),
          );
          if (mirror) still = timer.time('mirror', () => _flip(still));
          timer.time('look', () => applyColorMatrix(still, matrix));
          poster = timer.time('poster', () => _encodePoster(still));
          small = timer.time(
            'resize',
            () => _fitWidth(still, AppImageSizes.animationWidth),
          );
          width = small.width;
          height = small.height;
        } else {
          var frame = timer.time(
            'resize',
            () => _fitWidth(decoded, AppImageSizes.animationWidth),
          );
          if (mirror) frame = timer.time('mirror', () => _flip(frame));
          timer.time('look', () => applyColorMatrix(frame, matrix));
          small = frame;
        }
        // Half a second per pose — the rhythm of a classic GIF booth.
        timer.time('gif-encode', () => encoder.addFrame(small, duration: 50));
      }
      report(0.95 * (i + 1) / photos.length);
    }
    if (poster == null) return null;

    final gif = timer.time('gif-encode', () => encoder.finish()!);
    report(1);
    return AnimationResult(
      gif: gif,
      poster: poster,
      width: width!,
      height: height!,
      timings: timer.summary(), // TIMING
    );
  }

  static AnimationResult? _createBoomerang(
    List<CameraFrame> cameraFrames,
    List<double> matrix,
    bool mirror,
    ProgressCallback report,
  ) {
    final timer = StageTimer(); // TIMING
    // Each camera frame is sampled straight to its final size (rotation and
    // mirroring are just a different pixel lookup), so no full-size picture
    // is ever built — except the first, which is also the poster.
    final small = <img.Image>[];
    Uint8List? poster;
    for (var i = 0; i < cameraFrames.length; i++) {
      if (poster == null) {
        final still = timer.time(
          'convert+rotate+mirror',
          () => _frameToImage(
            cameraFrames[i],
            maxWidth: AppImageSizes.posterWidth,
            mirror: mirror,
          ),
        );
        if (still != null) {
          timer.time('look', () => applyColorMatrix(still, matrix));
          poster = timer.time('poster', () => _encodePoster(still));
          small.add(
            timer.time(
              'resize',
              () => _fitWidth(still, AppImageSizes.animationWidth),
            ),
          );
        }
      } else {
        final frame = timer.time(
          'convert+rotate+mirror',
          () => _frameToImage(
            cameraFrames[i],
            maxWidth: AppImageSizes.animationWidth,
            mirror: mirror,
          ),
        );
        if (frame != null) {
          timer.time('look', () => applyColorMatrix(frame, matrix));
          small.add(frame);
        }
      }
      report(0.5 * (i + 1) / cameraFrames.length);
    }
    if (small.isEmpty || poster == null) return null;

    final pingPong = pingPongOrder(small);
    final encoder = img.GifEncoder(samplingFactor: 20);
    for (var i = 0; i < pingPong.length; i++) {
      timer.time(
        'gif-encode',
        () => encoder.addFrame(pingPong[i], duration: 7),
      );
      report(0.5 + 0.5 * (i + 1) / (pingPong.length + 1));
    }
    final gif = timer.time('gif-encode', () => encoder.finish()!);
    report(1);
    return AnimationResult(
      gif: gif,
      poster: poster,
      width: small.first.width,
      height: small.first.height,
      timings: timer.summary(), // TIMING
    );
  }

  /// Forward, then back again without repeating the end frames, so the loop
  /// is seamless: 0 1 2 3 → 0 1 2 3 2 1. The same objects are reused, so the
  /// way back costs no extra resizing.
  @visibleForTesting
  static List<T> pingPongOrder<T>(List<T> frames) => [
    ...frames,
    if (frames.length > 2) ...frames.reversed.skip(1).take(frames.length - 2),
  ];

  static img.Image _flip(img.Image image) => img.flipHorizontal(image);

  static Uint8List _encodePoster(img.Image image) => Uint8List.fromList(
    img.encodeJpg(image, quality: AppImageSizes.printJpegQuality),
  );

  /// Converts a raw camera stream frame into an upright RGB image, at most
  /// [maxWidth] wide (nearest-pixel sampling), flipped left-right when
  /// [mirror] is set. Rotation and mirroring are done by choosing which
  /// sensor pixel each output pixel reads, so no big intermediate is built.
  @visibleForTesting
  static img.Image? frameToImage(
    CameraFrame frame, {
    int? maxWidth,
    bool mirror = false,
  }) => _frameToImage(frame, maxWidth: maxWidth, mirror: mirror);

  static img.Image? _frameToImage(
    CameraFrame frame, {
    int? maxWidth,
    bool mirror = false,
  }) {
    final turns = (frame.rotationDegrees ~/ 90) % 4;
    final sensorW = frame.width;
    final sensorH = frame.height;
    // Size after the rotation that makes the frame upright.
    final uprightW = turns.isOdd ? sensorH : sensorW;
    final uprightH = turns.isOdd ? sensorW : sensorH;
    final outW = maxWidth == null || maxWidth > uprightW ? uprightW : maxWidth;
    final outH = (uprightH * outW / uprightW).round().clamp(1, uprightH);

    // Which upright column / row each output column / row samples.
    final cols = List<int>.generate(outW, (x) {
      final ux = ((2 * x + 1) * uprightW) ~/ (2 * outW);
      return mirror ? uprightW - 1 - ux : ux;
    });
    final rows = List<int>.generate(
      outH,
      (y) => ((2 * y + 1) * uprightH) ~/ (2 * outH),
    );

    final image = img.Image(width: outW, height: outH);

    // Sensor pixel for an upright pixel (ux, uy), for a clockwise turn.
    int sx(int ux, int uy) => switch (turns) {
      0 => ux,
      1 => uy,
      2 => sensorW - 1 - ux,
      _ => sensorW - 1 - uy,
    };
    int sy(int ux, int uy) => switch (turns) {
      0 => uy,
      1 => sensorH - 1 - ux,
      2 => sensorH - 1 - uy,
      _ => ux,
    };

    switch (frame.format) {
      case CameraFrameFormat.yuv420:
        if (frame.planes.length < 3) return null;
        final yPlane = frame.planes[0];
        final uPlane = frame.planes[1];
        final vPlane = frame.planes[2];
        final uStride = uPlane.bytesPerPixel ?? 1;
        final vStride = vPlane.bytesPerPixel ?? 1;
        for (var y = 0; y < outH; y++) {
          final uy = rows[y];
          for (var x = 0; x < outW; x++) {
            final ux = cols[x];
            final px = sx(ux, uy);
            final py = sy(ux, uy);
            final luma = yPlane.bytes[py * yPlane.bytesPerRow + px];
            final u =
                uPlane.bytes[(py >> 1) * uPlane.bytesPerRow +
                    (px >> 1) * uStride] -
                128;
            final v =
                vPlane.bytes[(py >> 1) * vPlane.bytesPerRow +
                    (px >> 1) * vStride] -
                128;
            image.setPixelRgb(
              x,
              y,
              _clamp(luma + ((1436 * v) >> 10)),
              _clamp(luma - ((352 * u + 731 * v) >> 10)),
              _clamp(luma + ((1814 * u) >> 10)),
            );
          }
        }
      case CameraFrameFormat.bgra8888:
        final plane = frame.planes.first;
        for (var y = 0; y < outH; y++) {
          final uy = rows[y];
          for (var x = 0; x < outW; x++) {
            final ux = cols[x];
            final i = sy(ux, uy) * plane.bytesPerRow + sx(ux, uy) * 4;
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
    return image;
  }

  static int _clamp(int value) => value < 0 ? 0 : (value > 255 ? 255 : value);

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
