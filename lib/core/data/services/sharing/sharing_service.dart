import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

/// Opens the platform share sheet for a finished photo strip. Only runs when
/// the person explicitly taps Share — nothing is uploaded by the app itself.
/// See CLAUDE.md §11, §56.
class SharingService {
  Future<void> sharePhoto(
    String path, {
    required String text,
    Rect? origin,
  }) async {
    await Share.shareXFiles(
      [XFile(path, mimeType: 'image/jpeg')],
      text: text,
      sharePositionOrigin: origin,
    );
  }
}
