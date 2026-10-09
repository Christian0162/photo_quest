import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueLoading on AsyncValue<Object?> {
  /// Still fetching with nothing to show yet. A re-fetch that already has data
  /// is not this, so the page stays up while it refreshes.
  bool get isFirstFetch => isLoading && !hasValue;
}
