import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:photoquest/config/constant/app_image_sizes.dart';
import 'package:photoquest/core/data/services/image/image_processing_service.dart';

void main() {
  Uint8List photo(int width, int height) => Uint8List.fromList(
    img.encodeJpg(img.Image(width: width, height: height)),
  );

  test('photo strip is a print: margins, stacked photos, footer', () async {
    final service = ImageProcessingService();

    final bytes = await service.composePhotoStrip([
      photo(360, 480),
      photo(360, 480),
    ], caption: 'SEP 17, 2026');
    final strip = img.decodeJpg(bytes)!;

    expect(strip.width, AppImageSizes.stripWidth);
    // Each 360x480 photo scales to 720x960 inside 40px side margins.
    const photos = 960 * 2 + 24;
    expect(strip.height, 40 + photos + 176);
  });

  test('a corrupted photo is skipped instead of failing the strip', () async {
    final bytes = await ImageProcessingService().composePhotoStrip([
      photo(360, 480),
      Uint8List.fromList([1, 2, 3]),
    ], caption: 'x');
    expect(img.decodeJpg(bytes)!.height, 40 + 960 + 176);
  });

  test('no decodable photos gives an empty strip', () async {
    final bytes = await ImageProcessingService().composePhotoStrip([
      Uint8List.fromList([1, 2, 3]),
    ], caption: 'x');
    expect(bytes, isEmpty);
  });
}
