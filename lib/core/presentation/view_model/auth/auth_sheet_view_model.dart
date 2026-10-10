import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the welcome screen's drawer is showing.
enum AuthSheetMode {
  /// Closed: "Create account" and "I already have an account".
  actions,

  /// Open on the create account form.
  register,

  /// Open on the log in form.
  login,
}

/// The welcome drawer is one place with two forms in it, so which one is
/// open is screen state, not a route. Dropped with the screen, so coming
/// back (after "use a different email", say) starts closed again.
final authSheetViewModelProvider =
    NotifierProvider.autoDispose<AuthSheetViewModel, AuthSheetMode>(
      AuthSheetViewModel.new,
    );

class AuthSheetViewModel extends Notifier<AuthSheetMode> {
  @override
  AuthSheetMode build() => AuthSheetMode.actions;

  void open(AuthSheetMode mode) => state = mode;

  void close() => state = AuthSheetMode.actions;

  /// The drawer was dragged open or shut. Opening by hand lands on create
  /// account, the primary way in.
  void setExpanded(bool expanded) {
    if (expanded == (state != AuthSheetMode.actions)) return;
    state = expanded ? AuthSheetMode.register : AuthSheetMode.actions;
  }
}
