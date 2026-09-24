import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database_providers.dart';
import 'settings_repository.dart';

part 'settings_repository_provider.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(settingsDaoProvider));
}
