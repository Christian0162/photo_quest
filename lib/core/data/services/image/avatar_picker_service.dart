import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// A picked avatar, already shrunk to a profile-sized picture.
class PickedAvatar {
  const PickedAvatar({required this.bytes, required this.extension});

  final Uint8List bytes;

  /// `jpg`, `png` or `webp` — the types the `avatars` bucket accepts.
  final String extension;
}

/// Lets the person choose a profile picture from their photo library. The
/// photobooth camera stays custom; this is only for picking an existing photo.
class AvatarPickerService {
  AvatarPickerService([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _maxSide = 512.0;

  /// `null` when the person backs out.
  Future<PickedAvatar?> pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: 85,
    );
    if (file == null) return null;
    final name = file.name.toLowerCase();
    final extension = name.endsWith('.png')
        ? 'png'
        : name.endsWith('.webp')
        ? 'webp'
        : 'jpg';
    return PickedAvatar(bytes: await file.readAsBytes(), extension: extension);
  }
}
