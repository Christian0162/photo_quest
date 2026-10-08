import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database_providers.dart';
import 'day_moment_repository.dart';
import 'service_providers.dart';

part 'day_moment_repository_provider.g.dart';

@riverpod
DayMomentRepository dayMomentRepository(Ref ref) {
  return DayMomentRepository(
    ref.watch(dayMomentDaoProvider),
    ref.watch(photoStorageServiceProvider),
    ref.watch(imageProcessingServiceProvider),
  );
}
