/// Base type for domain/data-layer failures. Presentation code maps these
/// to friendly copy instead of showing raw exceptions. See CLAUDE.md §41.
sealed class AppFailure {
  const AppFailure(this.message);

  final String message;
}

class StorageFailure extends AppFailure {
  const StorageFailure([
    super.message = "Something went wrong saving your files.",
  ]);
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure([
    super.message = "Something went wrong saving your data.",
  ]);
}

class CameraFailure extends AppFailure {
  const CameraFailure([super.message = "The camera couldn't be started."]);
}

class CameraPermissionFailure extends AppFailure {
  const CameraPermissionFailure([
    super.message =
        'Photo Quest needs your camera to capture this memory. You can turn '
        "camera access on in your phone's settings.",
  ]);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([
    super.message = "We couldn't find what you were looking for.",
  ]);
}

class GalleryAccessFailure extends AppFailure {
  const GalleryAccessFailure([
    super.message =
        "Photo Quest can't save to your photos yet. You can allow it in your "
        "phone's settings.",
  ]);
}

class GallerySaveFailure extends AppFailure {
  const GallerySaveFailure([
    super.message = "We couldn't save that to your photos. Please try again.",
  ]);
}
