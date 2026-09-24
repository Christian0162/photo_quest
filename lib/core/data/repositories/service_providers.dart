import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/camera/camera_service.dart';
import '../services/gallery/gallery_service.dart';
import '../services/image/image_processing_service.dart';
import '../services/sharing/sharing_service.dart';
import '../services/storage/photo_storage_service.dart';

part 'service_providers.g.dart';

@Riverpod(keepAlive: true)
PhotoStorageService photoStorageService(Ref ref) => PhotoStorageService();

@Riverpod(keepAlive: true)
ImageProcessingService imageProcessingService(Ref ref) =>
    ImageProcessingService();

@Riverpod(keepAlive: true)
GalleryService galleryService(Ref ref) => GalleryService();

@Riverpod(keepAlive: true)
SharingService sharingService(Ref ref) => SharingService();

@riverpod
CameraService cameraService(Ref ref) {
  final service = CameraService();
  ref.onDispose(service.dispose);
  return service;
}
