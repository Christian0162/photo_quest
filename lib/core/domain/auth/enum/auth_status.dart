import '../entities/account_user.dart';

/// Where the person is in the account journey. The router reads this and
/// nothing else to decide which screen they belong on.
sealed class AuthStatus {
  const AuthStatus();
}

/// No account session. Shows the welcome / log in / create account screens.
class AuthSignedOut extends AuthStatus {
  const AuthSignedOut();
}

/// Registered (or tried to log in) but the email isn't confirmed yet.
class AuthAwaitingVerification extends AuthStatus {
  const AuthAwaitingVerification(this.email);

  final String email;
}

/// A reset code was sent; the person is choosing a new password.
class AuthRecovering extends AuthStatus {
  const AuthRecovering(this.email);

  final String email;
}

class AuthSignedIn extends AuthStatus {
  const AuthSignedIn(this.user);

  final AccountUser user;
}
