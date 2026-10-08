// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the person is in the account journey. The Supabase session is
/// restored before the app starts, so the first value is already right — no
/// login screen flashes while a saved session is found. The router is the
/// only reader that decides screens from it.

@ProviderFor(AuthSessionViewModel)
final authSessionViewModelProvider = AuthSessionViewModelProvider._();

/// Where the person is in the account journey. The Supabase session is
/// restored before the app starts, so the first value is already right — no
/// login screen flashes while a saved session is found. The router is the
/// only reader that decides screens from it.
final class AuthSessionViewModelProvider
    extends $NotifierProvider<AuthSessionViewModel, AuthStatus> {
  /// Where the person is in the account journey. The Supabase session is
  /// restored before the app starts, so the first value is already right — no
  /// login screen flashes while a saved session is found. The router is the
  /// only reader that decides screens from it.
  AuthSessionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionViewModelHash();

  @$internal
  @override
  AuthSessionViewModel create() => AuthSessionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStatus>(value),
    );
  }
}

String _$authSessionViewModelHash() =>
    r'596433102b381d7c072228d9f4083c0ea2a61312';

/// Where the person is in the account journey. The Supabase session is
/// restored before the app starts, so the first value is already right — no
/// login screen flashes while a saved session is found. The router is the
/// only reader that decides screens from it.

abstract class _$AuthSessionViewModel extends $Notifier<AuthStatus> {
  AuthStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthStatus, AuthStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthStatus, AuthStatus>,
              AuthStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
