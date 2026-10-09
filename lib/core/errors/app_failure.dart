/// Base type for domain/data-layer failures. Presentation code maps these
/// to friendly copy instead of showing raw exceptions.
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

/// What went wrong with an account action, so view models can react (e.g.
/// send an unverified person to the code screen) without parsing messages.
enum AuthFailureKind {
  invalidCredentials,
  emailNotConfirmed,
  emailTaken,
  weakPassword,
  invalidCode,
  rateLimited,
  offline,
  notConfigured,
  unknown,
}

class AuthFailure extends AppFailure {
  const AuthFailure(this.kind, super.message);

  final AuthFailureKind kind;
}

/// What went wrong sharing or backing up a memory, so screens can react
/// (for instance "wait a bit" after too many wrong codes).
enum SharingFailureKind {
  offline,
  notFound,
  tooManyTries,
  tooManyInvites,
  questFull,
  storageFull,
  notConfigured,
  unknown,
}

class SharingFailure extends AppFailure {
  const SharingFailure(this.kind, super.message);

  const SharingFailure.unknown([
    super.message = "We couldn't do that just now. Please try again.",
  ]) : kind = SharingFailureKind.unknown;

  final SharingFailureKind kind;
}

class ProfileFailure extends AppFailure {
  const ProfileFailure([
    super.message = "We couldn't update your profile. Please try again.",
  ]);
}
