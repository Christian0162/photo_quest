// TEMPORARY PROFILING: remove this file, and every `StageTimer` / `timings`
// use marked "TIMING", once the GIF, boomerang and 360° speed is confirmed.

/// Adds up how long named stages of a pipeline take, so before/after runs
/// can be compared. Plain data, so it works inside a background isolate.
class StageTimer {
  final _totals = <String, int>{};
  final _total = Stopwatch()..start();

  T time<T>(String stage, T Function() work) {
    final watch = Stopwatch()..start();
    try {
      return work();
    } finally {
      add(stage, watch.elapsed);
    }
  }

  void add(String stage, Duration elapsed) {
    _totals[stage] = (_totals[stage] ?? 0) + elapsed.inMilliseconds;
  }

  String summary() {
    final parts = [for (final e in _totals.entries) '${e.key}=${e.value}ms'];
    return '${parts.join(' ')} total=${_total.elapsedMilliseconds}ms';
  }
}
