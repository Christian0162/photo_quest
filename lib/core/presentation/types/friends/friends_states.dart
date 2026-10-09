import '../../../domain/sharing/invite_code.dart';

const _keep = Object();

/// My friend code, to give to people who want to add me.
class FriendCodeState {
  const FriendCodeState({
    this.code,
    this.loading = true,
    this.resetting = false,
    this.error,
  });

  final String? code;
  final bool loading;
  final bool resetting;
  final String? error;

  FriendCodeState copyWith({
    Object? code = _keep,
    bool? loading,
    bool? resetting,
    Object? error = _keep,
  }) => FriendCodeState(
    code: identical(code, _keep) ? this.code : code as String?,
    loading: loading ?? this.loading,
    resetting: resetting ?? this.resetting,
    error: identical(error, _keep) ? this.error : error as String?,
  );
}

/// The "enter a friend's code" form.
class AddFriendState {
  const AddFriendState({
    this.code = '',
    this.showErrors = false,
    this.busy = false,
    this.error,
    this.notice,
  });

  final String code;
  final bool showErrors;
  final bool busy;
  final String? error;

  final String? notice;

  String? get codeError => showErrors ? InviteCode.validate(code) : null;
  bool get isValid => InviteCode.validate(code) == null;

  AddFriendState copyWith({
    String? code,
    bool? showErrors,
    bool? busy,
    Object? error = _keep,
    Object? notice = _keep,
  }) => AddFriendState(
    code: code ?? this.code,
    showErrors: showErrors ?? this.showErrors,
    busy: busy ?? this.busy,
    error: identical(error, _keep) ? this.error : error as String?,
    notice: identical(notice, _keep) ? this.notice : notice as String?,
  );
}
