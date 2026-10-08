// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device owner, shown as the profile on Home. Null until the app has
/// one. See CLAUDE.md §18 note, §54A.

@ProviderFor(selfPerson)
final selfPersonProvider = SelfPersonProvider._();

/// The device owner, shown as the profile on Home. Null until the app has
/// one. See CLAUDE.md §18 note, §54A.

final class SelfPersonProvider
    extends $FunctionalProvider<AsyncValue<Person?>, Person?, FutureOr<Person?>>
    with $FutureModifier<Person?>, $FutureProvider<Person?> {
  /// The device owner, shown as the profile on Home. Null until the app has
  /// one. See CLAUDE.md §18 note, §54A.
  SelfPersonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selfPersonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selfPersonHash();

  @$internal
  @override
  $FutureProviderElement<Person?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Person?> create(Ref ref) {
    return selfPerson(ref);
  }
}

String _$selfPersonHash() => r'2f2fd6b90b91f5b3fa5be65adfe6f5dd20b7fc2e';

/// How the device owner says they feel right now, kept on this device. See
/// CLAUDE.md §54A.

@ProviderFor(MoodSetting)
final moodSettingProvider = MoodSettingProvider._();

/// How the device owner says they feel right now, kept on this device. See
/// CLAUDE.md §54A.
final class MoodSettingProvider
    extends $AsyncNotifierProvider<MoodSetting, Mood?> {
  /// How the device owner says they feel right now, kept on this device. See
  /// CLAUDE.md §54A.
  MoodSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moodSettingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moodSettingHash();

  @$internal
  @override
  MoodSetting create() => MoodSetting();
}

String _$moodSettingHash() => r'88422f64aa6f62b5eb734c05719cc9b6d30921fa';

/// How the device owner says they feel right now, kept on this device. See
/// CLAUDE.md §54A.

abstract class _$MoodSetting extends $AsyncNotifier<Mood?> {
  FutureOr<Mood?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Mood?>, Mood?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Mood?>, Mood?>,
              AsyncValue<Mood?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The avatar the device owner picked from the bundled set, kept on this
/// device. Null until they pick one.

@ProviderFor(AvatarSetting)
final avatarSettingProvider = AvatarSettingProvider._();

/// The avatar the device owner picked from the bundled set, kept on this
/// device. Null until they pick one.
final class AvatarSettingProvider
    extends $AsyncNotifierProvider<AvatarSetting, String?> {
  /// The avatar the device owner picked from the bundled set, kept on this
  /// device. Null until they pick one.
  AvatarSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarSettingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarSettingHash();

  @$internal
  @override
  AvatarSetting create() => AvatarSetting();
}

String _$avatarSettingHash() => r'2b03031f220b055f4ef75a23f2a504a1a22027fd';

/// The avatar the device owner picked from the bundled set, kept on this
/// device. Null until they pick one.

abstract class _$AvatarSetting extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Saving the profile: the device owner's name and avatar, together. See
/// CLAUDE.md §40, §54A.

@ProviderFor(ProfileEditor)
final profileEditorProvider = ProfileEditorProvider._();

/// Saving the profile: the device owner's name and avatar, together. See
/// CLAUDE.md §40, §54A.
final class ProfileEditorProvider
    extends $AsyncNotifierProvider<ProfileEditor, void> {
  /// Saving the profile: the device owner's name and avatar, together. See
  /// CLAUDE.md §40, §54A.
  ProfileEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileEditorHash();

  @$internal
  @override
  ProfileEditor create() => ProfileEditor();
}

String _$profileEditorHash() => r'61c6fcc021d4410be11c7ba1ead2b0687ce98fd2';

/// Saving the profile: the device owner's name and avatar, together. See
/// CLAUDE.md §40, §54A.

abstract class _$ProfileEditor extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
