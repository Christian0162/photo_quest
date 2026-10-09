// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in person's account: email, display name and avatar. It watches
/// the auth status, so it empties itself the moment they log out.

@ProviderFor(AccountViewModel)
final accountViewModelProvider = AccountViewModelProvider._();

/// The signed-in person's account: email, display name and avatar. It watches
/// the auth status, so it empties itself the moment they log out.
final class AccountViewModelProvider
    extends $AsyncNotifierProvider<AccountViewModel, AccountData> {
  /// The signed-in person's account: email, display name and avatar. It watches
  /// the auth status, so it empties itself the moment they log out.
  AccountViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: neverRetry,
        name: r'accountViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountViewModelHash();

  @$internal
  @override
  AccountViewModel create() => AccountViewModel();
}

String _$accountViewModelHash() => r'b9ed9cce8ab86d3ebf5d22d430982f4be31eaa20';

/// The signed-in person's account: email, display name and avatar. It watches
/// the auth status, so it empties itself the moment they log out.

abstract class _$AccountViewModel extends $AsyncNotifier<AccountData> {
  FutureOr<AccountData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AccountData>, AccountData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AccountData>, AccountData>,
              AsyncValue<AccountData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The name field on the Account screen. Saving goes through
/// [AccountViewModel]; this only holds what is being typed.

@ProviderFor(AccountNameDraftViewModel)
final accountNameDraftViewModelProvider = AccountNameDraftViewModelProvider._();

/// The name field on the Account screen. Saving goes through
/// [AccountViewModel]; this only holds what is being typed.
final class AccountNameDraftViewModelProvider
    extends $NotifierProvider<AccountNameDraftViewModel, AccountNameDraft> {
  /// The name field on the Account screen. Saving goes through
  /// [AccountViewModel]; this only holds what is being typed.
  AccountNameDraftViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountNameDraftViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountNameDraftViewModelHash();

  @$internal
  @override
  AccountNameDraftViewModel create() => AccountNameDraftViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountNameDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountNameDraft>(value),
    );
  }
}

String _$accountNameDraftViewModelHash() =>
    r'7b9a88306ae513d0c102ca7f8bc60d7495084aae';

/// The name field on the Account screen. Saving goes through
/// [AccountViewModel]; this only holds what is being typed.

abstract class _$AccountNameDraftViewModel extends $Notifier<AccountNameDraft> {
  AccountNameDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AccountNameDraft, AccountNameDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountNameDraft, AccountNameDraft>,
              AccountNameDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
