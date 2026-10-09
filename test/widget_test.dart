import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/app.dart';
import 'package:photoquest/core/data/database/app_database.dart';
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/data/repositories/auth_repository_provider.dart';

import 'support/fake_auth_repository.dart';

void main() {
  testWidgets('PhotoQuestApp boots to the Home route', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository(signedIn: true),
          ),
        ],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.pump();

    expect(find.text("Let's make a memory."), findsOneWidget);
  });
}
