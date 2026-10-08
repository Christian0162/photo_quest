import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

/// Opens the platform share sheet for a finished photo strip. Only runs when
/// the person explicitly taps Share — nothing is uploaded by the app itself.
class SharingService {
  Future<void> sharePhoto(String path, {required String text, Rect? origin}) =>
      shareFile(path, mimeType: 'image/jpeg', text: text, origin: origin);

  /// Shares a short piece of text, such as an invite code, with whichever app
  /// the person picks.
  Future<void> shareText(String text, {Rect? origin}) async {
    await Share.share(text, sharePositionOrigin: origin);
  }

  /// Shares any saved keepsake file — a photo strip, a GIF or boomerang,
  /// or a 360° clip.
  Future<void> shareFile(
    String path, {
    required String mimeType,
    required String text,
    Rect? origin,
  }) async {
    await Share.shareXFiles(
      [XFile(path, mimeType: mimeType)],
      text: text,
      sharePositionOrigin: origin,
    );
  }
}
