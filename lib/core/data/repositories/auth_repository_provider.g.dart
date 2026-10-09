// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Supabase client, or null when this build has no project configured
/// (see `AppEnv`). Only the public anon key ever reaches it.

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// The Supabase client, or null when this build has no project configured
/// (see `AppEnv`). Only the public anon key ever reaches it.

final class SupabaseClientProvider
    extends
        $FunctionalProvider<SupabaseClient?, SupabaseClient?, SupabaseClient?>
    with $Provider<SupabaseClient?> {
  /// The Supabase client, or null when this build has no project configured
  /// (see `AppEnv`). Only the public anon key ever reaches it.
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient? create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient?>(value),
    );
  }
}

String _$supabaseClientHash() => r'd15e0f2e68b53516ee6722e3f2c35b770aee2303';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'b29cd0858b0157a3c6891e1f96816723a752bbd1';

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'ae38b14b12f65cba9317db127821ef29f957fd3f';

@ProviderFor(avatarPickerService)
final avatarPickerServiceProvider = AvatarPickerServiceProvider._();

final class AvatarPickerServiceProvider
    extends
        $FunctionalProvider<
          AvatarPickerService,
          AvatarPickerService,
          AvatarPickerService
        >
    with $Provider<AvatarPickerService> {
  AvatarPickerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarPickerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarPickerServiceHash();

  @$internal
  @override
  $ProviderElement<AvatarPickerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AvatarPickerService create(Ref ref) {
    return avatarPickerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvatarPickerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvatarPickerService>(value),
    );
  }
}

String _$avatarPickerServiceHash() =>
    r'3fdd155f5d72ea3de9e96f188adabed21523468c';
