import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/auth/entities/account_user.dart';
import '../../errors/app_failure.dart';

/// What signing up led to.
enum SignUpOutcome { needsVerification, signedIn }

/// Source of truth for who is signed in. Wraps Supabase Auth; passwords and
/// tokens stay inside it. Every method throws an [AuthFailure] with copy that
/// is safe to show. Abstract so view models can be tested without a network.
abstract class AuthRepository {
  AccountUser? get currentUser;

  Stream<AccountUser?> get userChanges;

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> resendSignupCode(String email);

  Future<void> verifySignupCode({required String email, required String code});

  Future<void> sendPasswordResetCode(String email);

  /// Signs the person in with the emailed recovery code so they may then
  /// call [updatePassword].
  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  });

  Future<void> updatePassword(String newPassword);
}

class SupabaseAuthRepository implements AuthRepository {
  /// [auth] is null when the build has no Supabase configuration; every
  /// action then fails with a friendly "not set up" message.
  SupabaseAuthRepository(this._auth);

  final GoTrueClient? _auth;

  GoTrueClient get _client {
    final client = _auth;
    if (client == null) {
      throw const AuthFailure(
        AuthFailureKind.notConfigured,
        "Accounts aren't set up in this build yet.",
      );
    }
    return client;
  }

  @override
  AccountUser? get currentUser => _toUser(_auth?.currentUser);

  @override
  Stream<AccountUser?> get userChanges {
    final auth = _auth;
    if (auth == null) return const Stream.empty();
    return auth.onAuthStateChange.map((state) => _toUser(state.session?.user));
  }

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _client.signUp(
      email: email.trim(),
      password: password,
    );
    // With confirmation on, Supabase answers an already-registered address
    // with a user that has no identities instead of an error.
    final identities = response.user?.identities;
    if (response.user != null && identities != null && identities.isEmpty) {
      throw const AuthFailure(
        AuthFailureKind.emailTaken,
        'An account with this email already exists. Try logging in instead.',
      );
    }
    return response.session == null
        ? SignUpOutcome.needsVerification
        : SignUpOutcome.signedIn;
  });

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(
        () =>
            _client.signInWithPassword(email: email.trim(), password: password),
      );

  @override
  Future<void> signOut() => _guard(() => _client.signOut());

  @override
  Future<void> resendSignupCode(String email) =>
      _guard(() => _client.resend(type: OtpType.signup, email: email.trim()));

  @override
  Future<void> verifySignupCode({
    required String email,
    required String code,
  }) => _guard(
    () => _client.verifyOTP(
      type: OtpType.signup,
      email: email.trim(),
      token: code.trim(),
    ),
  );

  @override
  Future<void> sendPasswordResetCode(String email) =>
      _guard(() => _client.resetPasswordForEmail(email.trim()));

  @override
  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  }) => _guard(
    () => _client.verifyOTP(
      type: OtpType.recovery,
      email: email.trim(),
      token: code.trim(),
    ),
  );

  @override
  Future<void> updatePassword(String newPassword) =>
      _guard(() => _client.updateUser(UserAttributes(password: newPassword)));

  AccountUser? _toUser(User? user) {
    if (user == null) return null;
    return AccountUser(id: user.id, email: user.email ?? '');
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw _failureFor(error);
    } on SocketException {
      throw _offline;
    } on TimeoutException {
      throw _offline;
    }
  }

  static const _offline = AuthFailure(
    AuthFailureKind.offline,
    "Can't reach Photo Quest right now. Check your connection and try again.",
  );

  static const _weakPassword = AuthFailure(
    AuthFailureKind.weakPassword,
    'Pick a stronger password: at least 8 characters with letters and '
    'numbers.',
  );

  static const _rateLimited = AuthFailure(
    AuthFailureKind.rateLimited,
    'Too many tries for now. Please wait a minute and try again.',
  );

  /// Maps Supabase error codes to warm, actionable copy. Unknown errors get a
  /// generic message; the raw code never reaches the screen.
  static AuthFailure _failureFor(AuthException error) {
    if (error is AuthRetryableFetchException) return _offline;
    if (error is AuthWeakPasswordException) return _weakPassword;
    switch (error.code) {
      case 'invalid_credentials':
        return const AuthFailure(
          AuthFailureKind.invalidCredentials,
          "That email or password doesn't look right. Please try again.",
        );
      case 'email_not_confirmed':
        return const AuthFailure(
          AuthFailureKind.emailNotConfirmed,
          'Confirm your email first. We can send you a new code.',
        );
      case 'user_already_exists':
      case 'email_exists':
        return const AuthFailure(
          AuthFailureKind.emailTaken,
          'An account with this email already exists. Try logging in instead.',
        );
      case 'weak_password':
        return _weakPassword;
      case 'same_password':
        return const AuthFailure(
          AuthFailureKind.weakPassword,
          'Choose a password you have not used before.',
        );
      case 'otp_expired':
        return const AuthFailure(
          AuthFailureKind.invalidCode,
          'That code has expired. Ask for a new one.',
        );
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return _rateLimited;
    }
    if (error.statusCode == '429') return _rateLimited;
    if (error.statusCode == '403' || error.statusCode == '422') {
      return const AuthFailure(
        AuthFailureKind.invalidCode,
        "That code didn't work. Check it and try again, or ask for a new one.",
      );
    }
    return const AuthFailure(
      AuthFailureKind.unknown,
      'Something went wrong. Please try again.',
    );
  }
}
