import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/auth_repository_provider.dart';
import '../../../domain/auth/entities/account_user.dart';
import '../../../domain/auth/enum/auth_status.dart';

part 'auth_session_view_model.g.dart';

/// Where the person is in the account journey. The Supabase session is
/// restored before the app starts, so the first value is already right — no
/// login screen flashes while a saved session is found. The router is the
/// only reader that decides screens from it.
@Riverpod(keepAlive: true)
class AuthSessionViewModel extends _$AuthSessionViewModel {
  @override
  AuthStatus build() {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.userChanges.listen(_onAccountChanged);
    ref.onDispose(subscription.cancel);

    final user = repository.currentUser;
    return user == null ? const AuthSignedOut() : AuthSignedIn(user);
  }

  void _onAccountChanged(AccountUser? user) {
    switch (state) {
      case AuthRecovering():
        // Verifying the reset code signs the person in; they still have to
        // choose a new password before they enter the app.
        return;
      case AuthAwaitingVerification() when user == null:
        return;
      default:
        state = user == null ? const AuthSignedOut() : AuthSignedIn(user);
    }
  }

  /// The code screen: a new account, or a log in with an unconfirmed email.
  void awaitVerification(String email) =>
      state = AuthAwaitingVerification(email);

  /// The reset screen: a reset code was just sent.
  void beginRecovery(String email) => state = AuthRecovering(email);

  /// The email is confirmed or the password was changed: into the app.
  void completeSignIn() {
    final user = ref.read(authRepositoryProvider).currentUser;
    state = user == null ? const AuthSignedOut() : AuthSignedIn(user);
  }

  /// Backs out of the code or reset screen.
  Future<void> cancelPending() async {
    final repository = ref.read(authRepositoryProvider);
    if (repository.currentUser != null) {
      try {
        await repository.signOut();
      } on Object {
        // Leave the flow regardless; the person is not in the app yet.
      }
    }
    state = const AuthSignedOut();
  }

  /// Signs out. Account-scoped view models watch this status, so they
  /// release their data on their own.
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthSignedOut();
  }
}
