import 'package:gal/gal.dart';

import '../../../errors/app_failure.dart';

/// Saves shots and keepsakes to the phone's own photo library — only when
/// the person taps Download. Nothing leaves the device. See CLAUDE.md §56.
class GalleryService {
  /// Saves the file at [path]: a photo, GIF or keepsake image, or a clip
  /// when [isVideo]. Throws a friendly [AppFailure] if it can't.
  Future<void> save(String path, {required bool isVideo}) async {
    try {
      if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
        throw const GalleryAccessFailure();
      }
      isVideo ? await Gal.putVideo(path) : await Gal.putImage(path);
    } on GalException catch (e) {
      throw e.type == GalExceptionType.accessDenied
          ? const GalleryAccessFailure()
          : const GallerySaveFailure();
    }
  }
}
