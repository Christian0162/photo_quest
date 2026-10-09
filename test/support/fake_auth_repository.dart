import 'dart:async';

import 'package:photoquest/core/data/repositories/auth_repository.dart';
import 'package:photoquest/core/data/repositories/profile_repository.dart';
import 'package:photoquest/core/domain/auth/entities/account_user.dart';
import 'package:photoquest/core/domain/auth/entities/user_profile.dart';
import 'package:photoquest/core/errors/app_failure.dart';

/// An in-memory stand-in for Supabase Auth. Mirrors the behaviors the app
/// reacts to: existing emails, unconfirmed emails, wrong passwords and
/// emailed codes (always [validCode]).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    bool signedIn = false,
    this.requiresConfirmation = true,
  }) {
    if (signedIn) {
      _passwords['me@example.com'] = 'secret123';
      _confirmed.add('me@example.com');
      _user = const AccountUser(id: 'me', email: 'me@example.com');
    }
  }

  static const validCode = '123456';

  final bool requiresConfirmation;

  final _passwords = <String, String>{};
  final _confirmed = <String>{};
  final _changes = StreamController<AccountUser?>.broadcast(sync: true);
  AccountUser? _user;

  final calls = <String>[];

  AuthFailure? failNext;

  AuthFailure? failUpdatePassword;

  void registerConfirmed(String email, String password) {
    _passwords[email] = password;
    _confirmed.add(email);
  }

  void registerUnconfirmed(String email, String password) {
    _passwords[email] = password;
  }

  String? passwordOf(String email) => _passwords[email];

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  void _signInAs(String email) {
    _user = AccountUser(id: 'id-$email', email: email);
    _changes.add(_user);
  }

  @override
  AccountUser? get currentUser => _user;

  @override
  Stream<AccountUser?> get userChanges => _changes.stream;

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) async {
    calls.add('signUp:$email');
    _maybeFail();
    if (_passwords.containsKey(email)) {
      throw const AuthFailure(
        AuthFailureKind.emailTaken,
        'An account with this email already exists. Try logging in instead.',
      );
    }
    _passwords[email] = password;
    if (!requiresConfirmation) {
      _confirmed.add(email);
      _signInAs(email);
      return SignUpOutcome.signedIn;
    }
    return SignUpOutcome.needsVerification;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    calls.add('signIn:$email');
    _maybeFail();
    if (_passwords[email] != password) {
      throw const AuthFailure(
        AuthFailureKind.invalidCredentials,
        "That email or password doesn't look right. Please try again.",
      );
    }
    if (!_confirmed.contains(email)) {
      throw const AuthFailure(
        AuthFailureKind.emailNotConfirmed,
        'Confirm your email first. We can send you a new code.',
      );
    }
    _signInAs(email);
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _user = null;
    _changes.add(null);
  }

  @override
  Future<void> resendSignupCode(String email) async {
    calls.add('resend:$email');
    _maybeFail();
  }

  @override
  Future<void> verifySignupCode({
    required String email,
    required String code,
  }) async {
    calls.add('verify:$email:$code');
    _maybeFail();
    if (code != validCode) {
      throw const AuthFailure(
        AuthFailureKind.invalidCode,
        "That code didn't work. Check it and try again, or ask for a new one.",
      );
    }
    _confirmed.add(email);
    _signInAs(email);
  }

  @override
  Future<void> sendPasswordResetCode(String email) async {
    calls.add('sendReset:$email');
    _maybeFail();
  }

  @override
  Future<void> verifyRecoveryCode({
    required String email,
    required String code,
  }) async {
    calls.add('verifyReset:$email:$code');
    _maybeFail();
    if (code != validCode) {
      throw const AuthFailure(
        AuthFailureKind.invalidCode,
        "That code didn't work. Check it and try again, or ask for a new one.",
      );
    }
    _confirmed.add(email);
    _signInAs(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    calls.add('updatePassword');
    _maybeFail();
    final failure = failUpdatePassword;
    if (failure != null) {
      failUpdatePassword = null;
      throw failure;
    }
    _passwords[_user!.email] = newPassword;
  }
}

/// A profile that lives in memory.
class FakeProfileRepository extends ProfileRepository {
  FakeProfileRepository({this.displayName}) : super(null);

  String? displayName;

  int deleteCalls = 0;

  AppFailure? deleteError;

  Future<void> Function()? onDeleted;

  @override
  Future<UserProfile> getMyProfile() async =>
      UserProfile(id: 'me', displayName: displayName);

  @override
  Future<void> updateDisplayName(String name) async {
    displayName = name.trim().isEmpty ? null : name.trim();
  }

  @override
  Future<void> deleteMyAccount() async {
    deleteCalls++;
    final error = deleteError;
    if (error != null) {
      deleteError = null;
      throw error;
    }
    await onDeleted?.call();
  }

  @override
  Future<String?> avatarUrl(String? path) async => null;
}
