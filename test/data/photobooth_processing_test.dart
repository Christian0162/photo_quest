import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:photoquest/core/data/services/camera/camera_frame.dart';
import 'package:photoquest/core/data/services/image/image_processing_service.dart';
import 'package:photoquest/core/domain/memories/entities/photo_look.dart';

void main() {
  Uint8List photo(int width, int height, {img.Color? color}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: color ?? img.ColorRgb8(200, 120, 60));
    return Uint8List.fromList(img.encodeJpg(image));
  }

  /// A tiny iOS-style BGRA frame, filled with one color.
  CameraFrame bgraFrame(int width, int height, {int rotation = 90}) {
    final bytes = Uint8List(width * height * 4);
    for (var i = 0; i < bytes.length; i += 4) {
      bytes[i] = 40; // blue
      bytes[i + 1] = 120; // green
      bytes[i + 2] = 220; // red
      bytes[i + 3] = 255;
    }
    return CameraFrame(
      width: width,
      height: height,
      format: CameraFrameFormat.bgra8888,
      rotationDegrees: rotation,
      planes: [CameraFramePlane(bytes: bytes, bytesPerRow: width * 4)],
    );
  }

  group('looks', () {
    test('Natural leaves pixels untouched', () {
      final image = img.Image(width: 1, height: 1)
        ..setPixelRgb(0, 0, 200, 120, 60);
      ImageProcessingService.applyColorMatrix(image, PhotoLook.natural.matrix);
      final p = image.getPixel(0, 0);
      expect([p.r, p.g, p.b], [200, 120, 60]);
    });

    test('Booth B&W turns color into shades of grey', () {
      final image = img.Image(width: 1, height: 1)
        ..setPixelRgb(0, 0, 200, 120, 60);
      ImageProcessingService.applyColorMatrix(image, PhotoLook.mono.matrix);
      final p = image.getPixel(0, 0);
      expect(p.r, p.g);
      expect(p.g, p.b);
    });

    test('Film warms the photo: more red than blue', () {
      final image = img.Image(width: 1, height: 1)
        ..setPixelRgb(0, 0, 128, 128, 128);
      ImageProcessingService.applyColorMatrix(image, PhotoLook.film.matrix);
      final p = image.getPixel(0, 0);
      expect(p.r, greaterThan(p.b));
    });

    test('values stay within 0–255', () {
      final image = img.Image(width: 1, height: 1)
        ..setPixelRgb(0, 0, 255, 255, 255);
      ImageProcessingService.applyColorMatrix(image, PhotoLook.golden.matrix);
      final p = image.getPixel(0, 0);
      for (final channel in [p.r, p.g, p.b]) {
        expect(channel, inInclusiveRange(0, 255));
      }
    });

    test('the saved photo gets the look the preview showed', () async {
      final service = ImageProcessingService();
      final bytes = await service.applyLook(
        photo(8, 8, color: img.ColorRgb8(200, 120, 60)),
        PhotoLook.mono,
      );
      final p = img.decodeJpg(bytes)!.getPixel(4, 4);
      // JPEG is lossy, so grey means "channels within a few steps".
      expect((p.r - p.b).abs(), lessThan(6));
    });
  });

  group('GIF', () {
    test('one frame per burst photo, with a still poster', () async {
      final result = await ImageProcessingService().createGif([
        photo(40, 60),
        photo(40, 60),
        photo(40, 60),
        photo(40, 60),
      ], look: PhotoLook.natural);

      final gif = img.decodeGif(result!.gif)!;
      expect(gif.numFrames, 4);
      expect(img.decodeJpg(result.poster), isNotNull);
    });

    test('unreadable photos give no GIF instead of a crash', () async {
      final result = await ImageProcessingService().createGif([
        Uint8List.fromList([1, 2, 3]),
      ], look: PhotoLook.natural);
      expect(result, isNull);
    });
  });

  group('boomerang', () {
    test('plays forward then back without repeating the ends', () async {
      final result = await ImageProcessingService().createBoomerang([
        for (var i = 0; i < 4; i++) bgraFrame(8, 6),
      ], look: PhotoLook.natural);

      // 0 1 2 3 2 1 — loops back to 0 seamlessly.
      expect(img.decodeGif(result!.gif)!.numFrames, 6);
    });

    test('reports progress all the way to done', () async {
      final progress = <double>[];
      await ImageProcessingService().createBoomerang(
        [for (var i = 0; i < 4; i++) bgraFrame(8, 6)],
        look: PhotoLook.natural,
        onProgress: progress.add,
      );
      // Reports arrive from another isolate; give the last one a moment.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(progress, isNotEmpty);
      expect(progress.last, 1);
      for (var i = 1; i < progress.length; i++) {
        expect(progress[i], greaterThanOrEqualTo(progress[i - 1]));
      }
    });

    test('works when the progress listener holds app state', () async {
      // In the app, the listener belongs to the booth's view model, which
      // can't be sent to another isolate. Only the work may cross over.
      final appState = ReceivePort();
      addTearDown(appState.close);
      final progress = <double>[];

      final result = await ImageProcessingService().createBoomerang(
        [for (var i = 0; i < 4; i++) bgraFrame(8, 6)],
        look: PhotoLook.natural,
        onProgress: (p) {
          appState.sendPort;
          progress.add(p);
        },
      );

      expect(result, isNotNull);
      expect(progress.last, 1);
    });

    test('camera frames are turned upright and keep their color', () {
      final image = ImageProcessingService.frameToImage(bgraFrame(8, 6))!;
      // Sensor frames are landscape; a 90° turn makes them portrait.
      expect((image.width, image.height), (6, 8));
      final p = image.getPixel(2, 2);
      expect([p.r, p.g, p.b], [220, 120, 40]);
    });
  });
}
