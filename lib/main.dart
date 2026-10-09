import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/env/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  // Restores the saved session before the first frame, so a signed-in person
  // never sees the log in screen flash by. Only the public anon key is used.
  if (AppEnv.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      publishableKey: AppEnv.supabasePublishableKey,
    );
  }
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
