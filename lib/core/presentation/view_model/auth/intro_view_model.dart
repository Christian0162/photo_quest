import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/settings_repository_provider.dart';

/// Whether the intro pages were already seen on this device. Read once
/// before the first frame (see `main.dart`), so the router can decide
/// synchronously. Defaults to "seen" so nothing shows it unless the app
/// bootstrap says it is new.
final initialIntroSeenProvider = Provider<bool>((ref) => true);

/// The three get-started pages are shown once, to someone who is signed out
/// and new to the app. The router is the only reader that acts on this.
final introSeenProvider = NotifierProvider<IntroSeenViewModel, bool>(
  IntroSeenViewModel.new,
);

class IntroSeenViewModel extends Notifier<bool> {
  @override
  bool build() => ref.watch(initialIntroSeenProvider);

  /// Leaves the intro for good. The router follows the new state.
  Future<void> markSeen() async {
    state = true;
    try {
      await ref.read(settingsRepositoryProvider).setIntroSeen();
    } on Object {
      // Only costs the person seeing the pages once more next launch.
    }
  }
}
