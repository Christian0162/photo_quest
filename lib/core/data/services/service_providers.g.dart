// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(photoStorageService)
final photoStorageServiceProvider = PhotoStorageServiceProvider._();

final class PhotoStorageServiceProvider
    extends
        $FunctionalProvider<
          PhotoStorageService,
          PhotoStorageService,
          PhotoStorageService
        >
    with $Provider<PhotoStorageService> {
  PhotoStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoStorageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoStorageServiceHash();

  @$internal
  @override
  $ProviderElement<PhotoStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PhotoStorageService create(Ref ref) {
    return photoStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoStorageService>(value),
    );
  }
}

String _$photoStorageServiceHash() =>
    r'e248af2f4ab333030142a890e6025804dcc8d640';

@ProviderFor(imageProcessingService)
final imageProcessingServiceProvider = ImageProcessingServiceProvider._();

final class ImageProcessingServiceProvider
    extends
        $FunctionalProvider<
          ImageProcessingService,
          ImageProcessingService,
          ImageProcessingService
        >
    with $Provider<ImageProcessingService> {
  ImageProcessingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageProcessingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageProcessingServiceHash();

  @$internal
  @override
  $ProviderElement<ImageProcessingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImageProcessingService create(Ref ref) {
    return imageProcessingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageProcessingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageProcessingService>(value),
    );
  }
}

String _$imageProcessingServiceHash() =>
    r'70b24a2fc7a9a8ac60990befec4e62a717668ca4';

@ProviderFor(sharingService)
final sharingServiceProvider = SharingServiceProvider._();

final class SharingServiceProvider
    extends $FunctionalProvider<SharingService, SharingService, SharingService>
    with $Provider<SharingService> {
  SharingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharingServiceHash();

  @$internal
  @override
  $ProviderElement<SharingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharingService create(Ref ref) {
    return sharingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharingService>(value),
    );
  }
}

String _$sharingServiceHash() => r'831b46102403cf05c126d8d7b6e7401863c24c86';

@ProviderFor(cameraService)
final cameraServiceProvider = CameraServiceProvider._();

final class CameraServiceProvider
    extends $FunctionalProvider<CameraService, CameraService, CameraService>
    with $Provider<CameraService> {
  CameraServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraServiceHash();

  @$internal
  @override
  $ProviderElement<CameraService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CameraService create(Ref ref) {
    return cameraService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CameraService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CameraService>(value),
    );
  }
}

String _$cameraServiceHash() => r'7fd509e164c877fe32e6ae2bff1e9cfd15858a52';
