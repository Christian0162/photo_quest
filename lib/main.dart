import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  _registerFontLicenses();
  runApp(const ProviderScope(child: PhotoQuestApp()));
}

/// The bundled fonts are SIL OFL; their licenses must ship with the app and
/// appear on the licenses page (Settings → Open-source licenses).
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (family, asset) in [
      ('Outfit', 'assets/fonts/OFL-Outfit.txt'),
      ('Inter', 'assets/fonts/OFL-Inter.txt'),
      ('Caveat', 'assets/fonts/OFL-Caveat.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        family,
      ], await rootBundle.loadString(asset));
    }
  });
}
