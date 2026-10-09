import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart' show CameraLensDirection;
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:photoquest/core/data/services/camera/camera_frame.dart';
import 'package:photoquest/core/data/services/camera/camera_service.dart';
import 'package:photoquest/core/data/services/image/image_processing_service.dart';
import 'package:photoquest/core/data/services/storage/photo_storage_service.dart';
import 'package:photoquest/core/domain/camera/enum/camera_frame_format.dart';
import 'package:photoquest/core/domain/memories/enum/photo_look.dart';

void main() {
  Uint8List photo(int width, int height, {img.Color? color}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: color ?? img.ColorRgb8(200, 120, 60));
    return Uint8List.fromList(img.encodeJpg(image));
  }

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

  /// A BGRA frame whose every pixel is different, so rotation and mirroring
  /// mistakes show up.
  CameraFrame patternFrame(int width, int height, {required int rotation}) {
    final bytes = Uint8List(width * height * 4);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final i = (y * width + x) * 4;
        bytes[i] = y * 20; // blue
        bytes[i + 1] = x * 20; // green
        bytes[i + 2] = (x + y) * 10; // red
        bytes[i + 3] = 255;
      }
    }
    return CameraFrame(
      width: width,
      height: height,
      format: CameraFrameFormat.bgra8888,
      rotationDegrees: rotation,
      planes: [CameraFramePlane(bytes: bytes, bytesPerRow: width * 4)],
    );
  }

  CameraFrame greyFrame(int level) {
    final frame = bgraFrame(8, 6);
    final bytes = frame.planes.first.bytes;
    for (var i = 0; i < bytes.length; i += 4) {
      bytes[i] = bytes[i + 1] = bytes[i + 2] = level;
    }
    return frame;
  }

  img.Image reference(CameraFrame frame, {required bool mirror}) {
    final plane = frame.planes.first;
    final full = img.Image(width: frame.width, height: frame.height);
    for (var y = 0; y < frame.height; y++) {
      for (var x = 0; x < frame.width; x++) {
        final i = y * plane.bytesPerRow + x * 4;
        full.setPixelRgb(
          x,
          y,
          plane.bytes[i + 2],
          plane.bytes[i + 1],
          plane.bytes[i],
        );
      }
    }
    final upright = frame.rotationDegrees == 0
        ? full
        : img.copyRotate(full, angle: frame.rotationDegrees);
    return mirror ? img.flipHorizontal(upright) : upright;
  }

  Uint8List redBlue(int width, int height) {
    final image = img.Image(width: width, height: height);
    for (final p in image) {
      p.setRgb(p.x < width / 2 ? 220 : 20, 20, p.x < width / 2 ? 20 : 220);
    }
    return Uint8List.fromList(img.encodeJpg(image, quality: 100));
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

    test('frames are shrunk to the animation width', () async {
      final result = await ImageProcessingService().createGif([
        photo(1200, 800),
        photo(1200, 800),
      ], look: PhotoLook.natural);

      final gif = img.decodeGif(result!.gif)!;
      expect(gif.width, 480);
      expect(result.width, 480);
      expect(result.height, 320);
    });

    test('a front-camera GIF is flipped to match the preview', () async {
      final bytes = redBlue(40, 60);
      final service = ImageProcessingService();

      final plain = await service.createGif([bytes], look: PhotoLook.natural);
      final mirrored = await service.createGif(
        [bytes],
        look: PhotoLook.natural,
        mirror: true,
      );

      for (final (result, leftIsRed) in [(plain!, true), (mirrored!, false)]) {
        final poster = img.decodeJpg(result.poster)!;
        final gif = img.decodeGif(result.gif)!;
        for (final picture in [poster, gif]) {
          final left = picture.getPixel(picture.width ~/ 5, 30);
          expect(left.r > left.b, leftIsRed);
        }
      }
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

    test('the way back is the same pictures in reverse order', () async {
      final result = await ImageProcessingService().createBoomerang([
        greyFrame(40),
        greyFrame(100),
        greyFrame(160),
        greyFrame(220),
      ], look: PhotoLook.natural);

      final gif = img.decodeGif(result!.gif)!;
      final levels = [
        for (final frame in gif.frames) frame.getPixel(2, 2).r.toInt(),
      ];
      // Up 40 100 160 220, then back down 160 100 — and the loop restarts.
      const expected = [40, 100, 160, 220, 160, 100];
      expect(levels.length, expected.length);
      for (var i = 0; i < expected.length; i++) {
        expect(levels[i], closeTo(expected[i], 12), reason: 'frame $i');
      }
    });

    test('ping-pong order never repeats the end frames', () {
      expect(ImageProcessingService.pingPongOrder([1, 2, 3, 4, 5]), [
        1, 2, 3, 4, 5, 4, 3, 2, //
      ]);
      expect(ImageProcessingService.pingPongOrder([1, 2]), [1, 2]);
      expect(ImageProcessingService.pingPongOrder([1]), [1]);
    });

    test('frames are sampled straight down to the animation width', () async {
      final result = await ImageProcessingService().createBoomerang([
        for (var i = 0; i < 4; i++) bgraFrame(1280, 720),
      ], look: PhotoLook.natural);

      final gif = img.decodeGif(result!.gif)!;
      // 720×1280 upright, shrunk to 480 wide.
      expect((gif.width, gif.height), (480, 853));
      expect(gif.numFrames, 6);
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

    test('rotating and mirroring by lookup matches doing it the slow way', () {
      for (final rotation in [0, 90, 180, 270]) {
        for (final mirror in [false, true]) {
          final frame = patternFrame(7, 5, rotation: rotation);
          final fast = ImageProcessingService.frameToImage(
            frame,
            mirror: mirror,
          )!;
          final slow = reference(frame, mirror: mirror);
          expect(
            (fast.width, fast.height),
            (slow.width, slow.height),
            reason: 'size at $rotation°',
          );
          for (var y = 0; y < slow.height; y++) {
            for (var x = 0; x < slow.width; x++) {
              final a = fast.getPixel(x, y);
              final b = slow.getPixel(x, y);
              expect(
                [a.r, a.g, a.b],
                [b.r, b.g, b.b],
                reason: 'pixel $x,$y at $rotation° mirror=$mirror',
              );
            }
          }
        }
      }
    });

    test('a Y/U/V frame turns grey into grey, upright and shrunk', () {
      Uint8List plane(int size, int value) =>
          Uint8List(size)..fillRange(0, size, value);
      final frame = CameraFrame(
        width: 64,
        height: 48,
        format: CameraFrameFormat.yuv420,
        rotationDegrees: 90,
        planes: [
          CameraFramePlane(bytes: plane(64 * 48, 150), bytesPerRow: 64),
          CameraFramePlane(
            bytes: plane(32 * 24, 128),
            bytesPerRow: 32,
            bytesPerPixel: 1,
          ),
          CameraFramePlane(
            bytes: plane(32 * 24, 128),
            bytesPerRow: 32,
            bytesPerPixel: 1,
          ),
        ],
      );

      final image = ImageProcessingService.frameToImage(frame, maxWidth: 24)!;
      expect((image.width, image.height), (24, 32));
      final p = image.getPixel(10, 10);
      expect([p.r, p.g, p.b], [150, 150, 150]);
    });

    test('camera frames are turned upright and keep their color', () {
      final image = ImageProcessingService.frameToImage(bgraFrame(8, 6))!;
      // Sensor frames are landscape; a 90° turn makes them portrait.
      expect((image.width, image.height), (6, 8));
      final p = image.getPixel(2, 2);
      expect([p.r, p.g, p.b], [220, 120, 40]);
    });
  });

  group('front-camera orientation', () {
    test('only the Android front camera needs flipping', () {
      bool needs(CameraLensDirection lens, TargetPlatform platform) =>
          CameraService.needsMirror(lens: lens, platform: platform);

      expect(needs(CameraLensDirection.front, TargetPlatform.android), isTrue);
      expect(needs(CameraLensDirection.back, TargetPlatform.android), isFalse);
      expect(needs(CameraLensDirection.front, TargetPlatform.iOS), isFalse);
      expect(needs(CameraLensDirection.back, TargetPlatform.iOS), isFalse);
    });

    test('a thumbnail is flipped only when asked', () async {
      final bytes = redBlue(40, 40);
      final service = ImageProcessingService();

      final plain = img.decodeJpg(await service.createThumbnail(bytes))!;
      final flipped = img.decodeJpg(
        await service.createThumbnail(bytes, mirror: true),
      )!;
      expect(plain.getPixel(5, 20).r, greaterThan(plain.getPixel(5, 20).b));
      expect(flipped.getPixel(5, 20).b, greaterThan(flipped.getPixel(5, 20).r));
    });

    test('image size comes from the header', () {
      expect(ImageProcessingService.sizeOf(photo(30, 50)), (30, 50));
      expect(ImageProcessingService.sizeOf(Uint8List.fromList([1, 2, 3])), (
        0,
        0,
      ));
    });
  });

  group('moving a recorded clip', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('photoquest_move'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('renames when it can', () async {
      final source = File('${dir.path}/clip.mp4')..writeAsBytesSync([1, 2, 3]);
      final target = '${dir.path}/kept.mp4';

      await PhotoStorageService.moveFile(source, target);

      expect(File(target).readAsBytesSync(), [1, 2, 3]);
      expect(source.existsSync(), isFalse);
    });

    test('copies then deletes when renaming fails', () async {
      final source = File('${dir.path}/clip.mp4')..writeAsBytesSync([4, 5, 6]);
      final target = '${dir.path}/kept.mp4';

      await PhotoStorageService.moveFile(
        source,
        target,
        rename: (_, _) => throw const FileSystemException('cross-device'),
      );

      expect(File(target).readAsBytesSync(), [4, 5, 6]);
      expect(source.existsSync(), isFalse);
    });
  });
}
