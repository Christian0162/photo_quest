import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/app.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/data/repositories/auth_repository_provider.dart';
import 'package:photoquest/core/domain/auth/auth_validators.dart';
import 'package:photoquest/core/errors/app_failure.dart';
import 'package:photoquest/core/presentation/types/auth/auth_form_states.dart';
import 'package:photoquest/core/presentation/view_model/auth/auth_session_view_model.dart';
import 'package:photoquest/core/presentation/widget/atoms/common/md_photoquest_logo.dart';
import 'package:photoquest/core/presentation/widget/molecules/common/md_animated_photoquest_logo.dart';
import 'package:photoquest/core/presentation/view_model/auth/auth_sheet_view_model.dart';
import 'package:photoquest/core/presentation/widget/organisms/auth/md_login_form.dart';
import 'package:photoquest/core/presentation/widget/organisms/auth/md_register_form.dart';
import 'package:photoquest/core/presentation/widget/templates/auth/welcome_template.dart';
import 'package:photoquest/core/presentation/widget/templates/auth/verify_email_template.dart';

import '../support/fake_auth_repository.dart';

/// The logo and stickers never stop moving; reduced motion lets
/// `pumpAndSettle` finish.
void _reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

/// Boots the whole app against [auth], on a phone-sized screen.
Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  FakeAuthRepository auth, {
  FakeProfileRepository? profile,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _reduceMotion(tester);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      authRepositoryProvider.overrideWithValue(auth),
      if (profile != null) profileRepositoryProvider.overrideWithValue(profile),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const PhotoQuestApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder _field(String label) => find.widgetWithText(TextField, label);

Future<void> _type(WidgetTester tester, String label, String text) async {
  await tester.enterText(_field(label), text);
  await tester.pump();
}

Future<void> _tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// Settings is longer now, so scroll down to the account row before tapping.
Future<void> _openAccountFromSettings(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Your account'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.text('Your account'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Your account'));
  await tester.pumpAndSettle();
}

void main() {
  group('AuthValidators', () {
    test('email', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('nope'), isNotNull);
      expect(AuthValidators.email('a@b'), isNotNull);
      expect(AuthValidators.email(' me@example.com '), isNull);
    });

    test('new password needs length, letters and numbers', () {
      expect(AuthValidators.newPassword(''), isNotNull);
      expect(AuthValidators.newPassword('short1'), isNotNull);
      expect(AuthValidators.newPassword('onlyletters'), isNotNull);
      expect(AuthValidators.newPassword('12345678'), isNotNull);
      expect(AuthValidators.newPassword('longenough1'), isNull);
    });

    test('confirmation must match', () {
      expect(AuthValidators.passwordMatch('abc12345', ''), isNotNull);
      expect(AuthValidators.passwordMatch('abc12345', 'abc12346'), isNotNull);
      expect(AuthValidators.passwordMatch('abc12345', 'abc12345'), isNull);
    });

    test('code is six digits', () {
      expect(AuthValidators.code(''), isNotNull);
      expect(AuthValidators.code('12345'), isNotNull);
      expect(AuthValidators.code('12a456'), isNotNull);
      expect(AuthValidators.code('123456'), isNull);
    });
  });

  group('routing follows the auth state', () {
    testWidgets('a saved session goes straight to the app, no login flash', (
      tester,
    ) async {
      await _pumpApp(tester, FakeAuthRepository(signedIn: true));

      expect(find.text("Let's make a memory."), findsOneWidget);
      expect(find.text('Create account'), findsNothing);
    });

    testWidgets('no session shows the welcome screen', (tester) async {
      await _pumpApp(tester, FakeAuthRepository());

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
      expect(find.text("Let's make a memory."), findsNothing);
    });

    testWidgets('logging out returns to the welcome screen', (tester) async {
      final container = await _pumpApp(
        tester,
        FakeAuthRepository(signedIn: true),
      );

      await container.read(authSessionViewModelProvider.notifier).signOut();
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);
    });
  });

  group('create account', () {
    testWidgets('validates before sending anything', (tester) async {
      final auth = FakeAuthRepository();
      await _pumpApp(tester, auth);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await _tapButton(tester, 'Create account');

      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Choose a password.'), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('mismatched passwords are caught inline', (tester) async {
      final auth = FakeAuthRepository();
      await _pumpApp(tester, auth);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'new@example.com');
      await _type(tester, 'Password', 'longenough1');
      await _type(tester, 'Confirm password', 'longenough2');
      await _tapButton(tester, 'Create account');

      expect(find.text("The passwords don't match yet."), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('register → confirm with the emailed code → in the app', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await _pumpApp(tester, auth);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'new@example.com');
      await _type(tester, 'Password', 'longenough1');
      await _type(tester, 'Confirm password', 'longenough1');
      await _tapButton(tester, 'Create account');

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining('new@example.com'), findsOneWidget);

      await _type(tester, 'Code', '000000');
      await _tapButton(tester, 'Confirm email');
      expect(find.textContaining("didn't work"), findsOneWidget);
      expect(find.text('Check your email'), findsOneWidget);

      await _type(tester, 'Code', FakeAuthRepository.validCode);
      await _tapButton(tester, 'Confirm email');

      expect(find.text("Let's make a memory."), findsOneWidget);
    });

    testWidgets('an email that already has an account says so', (tester) async {
      final auth = FakeAuthRepository()
        ..registerConfirmed('taken@example.com', 'whatever123');
      await _pumpApp(tester, auth);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'taken@example.com');
      await _type(tester, 'Password', 'longenough1');
      await _type(tester, 'Confirm password', 'longenough1');
      await _tapButton(tester, 'Create account');

      expect(
        find.text(
          'An account with this email already exists. Try logging in instead.',
        ),
        findsOneWidget,
      );
      expect(find.text('Check your email'), findsNothing);
    });

    testWidgets('"use a different email" leaves the code screen', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await _pumpApp(tester, auth);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'new@example.com');
      await _type(tester, 'Password', 'longenough1');
      await _type(tester, 'Confirm password', 'longenough1');
      await _tapButton(tester, 'Create account');

      await tester.tap(find.text('Use a different email'));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Check your email'), findsNothing);
    });
  });

  group('log in', () {
    testWidgets('a wrong password shows a friendly inline message', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..registerConfirmed('me@example.com', 'secret123');
      await _pumpApp(tester, auth);

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'me@example.com');
      await _type(tester, 'Password', 'wrongpass1');
      await _tapButton(tester, 'Log in');

      expect(
        find.text(
          "That email or password doesn't look right. Please try again.",
        ),
        findsOneWidget,
      );
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('the right password enters the app', (tester) async {
      final auth = FakeAuthRepository()
        ..registerConfirmed('me@example.com', 'secret123');
      await _pumpApp(tester, auth);

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'me@example.com');
      await _type(tester, 'Password', 'secret123');
      await _tapButton(tester, 'Log in');

      expect(find.text("Let's make a memory."), findsOneWidget);
    });

    testWidgets('an unconfirmed email is sent to the code screen', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..registerUnconfirmed('late@example.com', 'secret123');
      await _pumpApp(tester, auth);

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'late@example.com');
      await _type(tester, 'Password', 'secret123');
      await _tapButton(tester, 'Log in');

      expect(find.text('Check your email'), findsOneWidget);
      expect(auth.calls, contains('resend:late@example.com'));
    });

    testWidgets('the password can be shown and hidden', (tester) async {
      await _pumpApp(tester, FakeAuthRepository());

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();

      TextField password() => tester.widget<TextField>(_field('Password'));
      expect(password().obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(password().obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('a network failure is explained, not shown raw', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..registerConfirmed('me@example.com', 'secret123')
        ..failNext = const AuthFailure(
          AuthFailureKind.offline,
          "Can't reach Photo Quest right now. Check your connection and try "
          'again.',
        );
      await _pumpApp(tester, auth);

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'me@example.com');
      await _type(tester, 'Password', 'secret123');
      await _tapButton(tester, 'Log in');

      expect(find.textContaining("Can't reach Photo Quest"), findsOneWidget);

      // Trying again once the connection is back works.
      await _tapButton(tester, 'Log in');
      expect(find.text("Let's make a memory."), findsOneWidget);
    });
  });

  group('forgot password', () {
    testWidgets('request a code, choose a new password, land in the app', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..registerConfirmed('me@example.com', 'oldsecret1');
      await _pumpApp(tester, auth);

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Forgot your password?'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'me@example.com');
      await _tapButton(tester, 'Send me a code');

      expect(find.text('Choose a new password'), findsOneWidget);

      await _type(tester, 'Code', FakeAuthRepository.validCode);
      await _type(tester, 'New password', 'brandnew123');
      await _type(tester, 'Confirm new password', 'brandnew123');
      await _tapButton(tester, 'Save new password');

      expect(find.text("Let's make a memory."), findsOneWidget);
      expect(auth.passwordOf('me@example.com'), 'brandnew123');
    });

    testWidgets('a refused new password does not spend the code twice', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..registerConfirmed('me@example.com', 'oldsecret1')
        ..failUpdatePassword = const AuthFailure(
          AuthFailureKind.weakPassword,
          'Choose a password you have not used before.',
        );
      await _pumpApp(tester, auth);

      await tester.tap(find.text('I already have an account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Forgot your password?'));
      await tester.pumpAndSettle();
      await _type(tester, 'Email', 'me@example.com');
      await _tapButton(tester, 'Send me a code');

      await _type(tester, 'Code', FakeAuthRepository.validCode);
      await _type(tester, 'New password', 'brandnew123');
      await _type(tester, 'Confirm new password', 'brandnew123');
      await _tapButton(tester, 'Save new password');

      // Refused: still on the reset screen, with the reason.
      expect(find.text('Choose a new password'), findsOneWidget);
      expect(
        find.text('Choose a password you have not used before.'),
        findsOneWidget,
      );

      await _tapButton(tester, 'Save new password');

      expect(find.text("Let's make a memory."), findsOneWidget);
      expect(
        auth.calls.where((c) => c.startsWith('verifyReset')),
        hasLength(1),
      );
    });
  });

  group('account', () {
    testWidgets('shows the email and saves a new name', (tester) async {
      final profile = FakeProfileRepository();
      await _pumpApp(
        tester,
        FakeAuthRepository(signedIn: true),
        profile: profile,
      );

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await _openAccountFromSettings(tester);

      expect(find.text('me@example.com'), findsOneWidget);
      expect(find.text('Save name'), findsNothing);

      await _type(tester, 'Your name', 'Alex');
      expect(find.text('Save name'), findsOneWidget);
      await _tapButton(tester, 'Save name');

      expect(profile.displayName, 'Alex');
      expect(find.text('Save name'), findsNothing);
    });

    testWidgets('log out returns to the welcome screen', (tester) async {
      final auth = FakeAuthRepository(signedIn: true);
      await _pumpApp(tester, auth, profile: FakeProfileRepository());

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await _openAccountFromSettings(tester);
      await tester.ensureVisible(find.text('Log out'));
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      expect(auth.calls, contains('signOut'));
      expect(find.text('Create account'), findsOneWidget);
    });
  });

  group('delete account', () {
    Future<void> openAccount(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await _openAccountFromSettings(tester);
      await tester.ensureVisible(find.text('Delete my account'));
    }

    testWidgets('asks first, and "keep my account" changes nothing', (
      tester,
    ) async {
      final auth = FakeAuthRepository(signedIn: true);
      final profile = FakeProfileRepository();
      await _pumpApp(tester, auth, profile: profile);
      await openAccount(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Delete my account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete your account?'), findsOneWidget);
      expect(
        find.textContaining('Photos saved on this phone stay'),
        findsOneWidget,
      );

      await tester.tap(find.text('Keep my account'));
      await tester.pumpAndSettle();

      expect(profile.deleteCalls, 0);
      expect(find.text('Your account'), findsWidgets);
      expect(find.text('Create account'), findsNothing);
    });

    testWidgets('confirming deletes the account and returns to welcome', (
      tester,
    ) async {
      final auth = FakeAuthRepository(signedIn: true);
      final profile = FakeProfileRepository()..onDeleted = auth.signOut;
      await _pumpApp(tester, auth, profile: profile);
      await openAccount(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Delete my account'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Delete my account'),
      );
      await tester.pumpAndSettle();

      expect(profile.deleteCalls, 1);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text("Let's make a memory."), findsNothing);
    });

    testWidgets('a failure explains itself and the person stays signed in', (
      tester,
    ) async {
      final auth = FakeAuthRepository(signedIn: true);
      final profile = FakeProfileRepository()
        ..deleteError = const ProfileFailure(
          "We couldn't delete your account. Nothing was lost, so please try "
          'again.',
        );
      await _pumpApp(tester, auth, profile: profile);
      await openAccount(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Delete my account'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Delete my account'),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Nothing was lost'), findsOneWidget);
      expect(find.text('Your account'), findsWidgets);
      expect(find.text('Create account'), findsNothing);
      // The button is usable again for a retry.
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Delete my account'),
            )
            .onPressed,
        isNotNull,
      );
    });
  });

  group('layout', () {
    Widget host(Widget child) =>
        MaterialApp(theme: AppTheme.light, home: child);

    Future<void> pumpSized(
      WidgetTester tester,
      Size size,
      Widget child, {
      double keyboard = 0,
    }) async {
      _reduceMotion(tester);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(child));
      await tester.pumpAndSettle();
    }

    final templates = <String, Widget Function()>{
      'welcome': () => WelcomeTemplate(
        mode: AuthSheetMode.actions,
        formBuilder: (_, _) => const SizedBox.shrink(),
        onCreateAccount: () {},
        onLogIn: () {},
        onClose: () {},
        onExpandedChanged: (_) {},
      ),
      'login': () => WelcomeTemplate(
        mode: AuthSheetMode.login,
        formBuilder: (_, controller) => MdLoginForm(
          scrollController: controller,
          form: const LoginFormState(),
          onEmailChanged: (_) {},
          onPasswordChanged: (_) {},
          onToggleShowPassword: () {},
          onSubmit: () {},
          onForgotPassword: () {},
          onCreateAccount: () {},
        ),
        onCreateAccount: () {},
        onLogIn: () {},
        onClose: () {},
        onExpandedChanged: (_) {},
      ),
      'register with errors': () => WelcomeTemplate(
        mode: AuthSheetMode.register,
        formBuilder: (_, controller) => MdRegisterForm(
          scrollController: controller,
          form: const RegisterFormState(showErrors: true, error: 'Oops'),
          onEmailChanged: (_) {},
          onPasswordChanged: (_) {},
          onConfirmationChanged: (_) {},
          onToggleShowPassword: () {},
          onSubmit: () {},
          onLogIn: () {},
        ),
        onCreateAccount: () {},
        onLogIn: () {},
        onClose: () {},
        onExpandedChanged: (_) {},
      ),
      'verify': () => VerifyEmailTemplate(
        email: 'a-rather-long-address@example-domain.com',
        form: const VerifyFormState(notice: 'A new code is on its way.'),
        onCodeChanged: (_) {},
        onSubmit: () {},
        onResend: () {},
        onUseDifferentEmail: () {},
      ),
    };

    for (final entry in templates.entries) {
      for (final (name, size, keyboard) in const [
        ('small phone', Size(320, 568), 0.0),
        ('small phone with keyboard', Size(320, 568), 260.0),
        ('large phone', Size(430, 932), 0.0),
      ]) {
        testWidgets('${entry.key} fits a $name', (tester) async {
          await pumpSized(tester, size, entry.value(), keyboard: keyboard);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('text scales up without overflowing', (tester) async {
      _reduceMotion(tester);
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: templates['login']!(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('MdAnimatedPhotoQuestLogo', () {
    MdPhotoQuestLogo logo(WidgetTester tester) =>
        tester.widget<MdPhotoQuestLogo>(find.byType(MdPhotoQuestLogo));

    Widget app(Widget child, {bool disableAnimations = false}) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(body: Center(child: child)),
    );

    testWidgets('plays through its frames and settles at the resting logo', (
      tester,
    ) async {
      await tester.pumpWidget(app(const MdAnimatedPhotoQuestLogo()));

      await tester.pump(const Duration(milliseconds: 400));
      expect(logo(tester).open, greaterThan(0));
      expect(logo(tester).develop, lessThan(1));

      await tester.pump(const Duration(milliseconds: 1100));
      expect(logo(tester).open, 0);
      expect(logo(tester).develop, 1);
      expect(logo(tester).twinkle, closeTo(0, 0.001));
    });

    testWidgets('loops while playing and stops cleanly', (tester) async {
      await tester.pumpWidget(
        app(const MdAnimatedPhotoQuestLogo(playing: true, loop: true)),
      );
      // Several full cycles later it is still animating.
      await tester.pump(const Duration(milliseconds: 3000));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(
        app(const MdAnimatedPhotoQuestLogo(playing: false)),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(logo(tester).develop, 1);
    });

    testWidgets('reduced motion shows the still logo and never animates', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(const MdAnimatedPhotoQuestLogo(), disableAnimations: true),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.hasRunningAnimations, isFalse);
      expect(logo(tester).open, 0);
      expect(logo(tester).develop, 1);
    });

    testWidgets('is disposed without leaking a running ticker', (tester) async {
      await tester.pumpWidget(app(const MdAnimatedPhotoQuestLogo(loop: true)));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(app(const SizedBox()));

      expect(tester.takeException(), isNull);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('has a screen reader label', (tester) async {
      await tester.pumpWidget(app(const MdAnimatedPhotoQuestLogo()));
      expect(find.bySemanticsLabel('Photo Quest'), findsOneWidget);
    });
  });
}
