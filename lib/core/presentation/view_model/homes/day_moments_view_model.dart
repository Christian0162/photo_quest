import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/day_moment_repository_provider.dart';
import '../../../domain/moments/entities/day_moment.dart';

part 'day_moments_view_model.g.dart';

/// The "Your Day" moments still showing. Each one disappears 24 hours after
/// it was added, even while the app stays open. See CLAUDE.md §54A.
@riverpod
class DayMomentList extends _$DayMomentList {
  @override
  Future<List<DayMoment>> build() async {
    final moments = await ref
        .watch(dayMomentRepositoryProvider)
        .getActiveMoments();
    if (moments.isNotEmpty) {
      final now = DateTime.now();
      final soonest = moments
          .map((moment) => moment.remaining(now))
          .reduce((a, b) => a < b ? a : b);
      // Look again just after the first one runs out.
      final timer = Timer(soonest + const Duration(seconds: 1), () {
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);
    }
    return moments;
  }

  Future<void> delete(String id) async {
    await ref.read(dayMomentRepositoryProvider).deleteMoment(id);
    ref.invalidateSelf();
    await future;
  }
}
