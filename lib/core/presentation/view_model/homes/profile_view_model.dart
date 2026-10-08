import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/settings_repository_provider.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/people/enum/mood.dart';
import '../people/people_list_view_model.dart';

part 'profile_view_model.g.dart';

/// The device owner, shown as the profile on Home. Null until the app has
/// one. See CLAUDE.md §18 note, §54A.
@riverpod
Future<Person?> selfPerson(Ref ref) {
  return ref.watch(peopleRepositoryProvider).getSelfPerson();
}

/// How the device owner says they feel right now, kept on this device. See
/// CLAUDE.md §54A.
@riverpod
class MoodSetting extends _$MoodSetting {
  @override
  Future<Mood?> build() {
    return ref.watch(settingsRepositoryProvider).getMood();
  }

  /// Sets the mood, or clears it when [mood] is null.
  Future<void> choose(Mood? mood) async {
    state = AsyncData(mood);
    await ref.read(settingsRepositoryProvider).setMood(mood);
  }
}

/// The avatar the device owner picked from the bundled set, kept on this
/// device. Null until they pick one.
@riverpod
class AvatarSetting extends _$AvatarSetting {
  @override
  Future<String?> build() {
    return ref.watch(settingsRepositoryProvider).getAvatar();
  }

  Future<void> choose(String avatarId) async {
    state = AsyncData(avatarId);
    await ref.read(settingsRepositoryProvider).setAvatar(avatarId);
  }
}

/// Saving the profile: the device owner's name and avatar, together. See
/// CLAUDE.md §40, §54A.
@riverpod
class ProfileEditor extends _$ProfileEditor {
  @override
  FutureOr<void> build() {}

  /// Saves [name] (when it isn't blank) and [avatarId] (when one is picked).
  /// Returns whether everything was saved.
  Future<bool> save({required String name, required String? avatarId}) async {
    state = const AsyncLoading();
    try {
      if (name.trim().isNotEmpty) {
        await ref.read(peopleRepositoryProvider).saveSelfName(name);
        ref.invalidate(selfPersonProvider);
        ref.invalidate(peopleListProvider);
      }
      if (avatarId != null) {
        await ref.read(avatarSettingProvider.notifier).choose(avatarId);
      }
      state = const AsyncData(null);
      return true;
    } on Exception catch (error, stack) {
      state = AsyncError(error, stack);
      return false;
    }
  }
}
