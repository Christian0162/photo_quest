/// Build-time configuration, passed with
/// `flutter run --dart-define-from-file=env.json` (see `env.example.json`).
///
/// Only values that are safe to ship inside an app belong here: the Supabase
/// project URL and its public publishable (legacy name: anon) key. The publishable key grants no
/// power on its own — Row Level Security decides what a signed-in person can
/// touch. A secret key (sb_secret_...) or the legacy service_role key must NEVER be added here.
abstract final class AppEnv {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
