import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Lets the person pick several photos from their library, for adding to a
/// shared memory. The photobooth camera stays custom; this is only for photos
/// that already exist.
class PhotoPickerService {
  PhotoPickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// How many photos can be added in one go.
  static const maxPhotos = 10;

  static const _maxSide = 2048.0;

  /// The picked photos' bytes; empty when the person backs out.
  Future<List<Uint8List>> pickPhotos() async {
    final files = await _picker.pickMultiImage(
      limit: maxPhotos,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: 90,
    );
    return [for (final file in files) await file.readAsBytes()];
  }
}
