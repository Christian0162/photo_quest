// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A time-of-day greeting for the top of Home. See CLAUDE.md §31.

@ProviderFor(homeGreeting)
final homeGreetingProvider = HomeGreetingProvider._();

/// A time-of-day greeting for the top of Home. See CLAUDE.md §31.

final class HomeGreetingProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// A time-of-day greeting for the top of Home. See CLAUDE.md §31.
  HomeGreetingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeGreetingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeGreetingHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return homeGreeting(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$homeGreetingHash() => r'5bb780bf3ace503578e2c02ebd4b652c2d3ec095';
