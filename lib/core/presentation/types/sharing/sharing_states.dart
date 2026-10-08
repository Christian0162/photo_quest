import '../../../domain/friends/entities/friend.dart';
import '../../../domain/sharing/entities/shared_memory.dart';
import '../../../domain/sharing/invite_code.dart';

const _keep = Object();

enum SharePhase {
  /// Nothing started yet.
  idle,

  /// Saving the memory online, then making the code.
  saving,

  /// There is a code to hand to a friend.
  ready,
}

/// The "Invite a friend" sheet for one memory.
class ShareMemoryState {
  const ShareMemoryState({
    this.phase = SharePhase.idle,
    this.progress = 0,
    this.code,
    this.error,
    this.viewers = const [],
    this.isOnline = false,
    this.removing = false,
    this.friends = const [],
  });

  final SharePhase phase;

  /// 0 to 1 while [phase] is [SharePhase.saving].
  final double progress;
  final String? code;
  final String? error;

  /// Friends who can already see this memory, or are on this quest.
  final List<ShareViewer> viewers;

  /// Whether this memory already has an online copy.
  final bool isOnline;

  /// True while the online copy is being removed.
  final bool removing;

  /// Real friends (added in People) who can be invited straight from here.
  final List<Friend> friends;

  ShareMemoryState copyWith({
    SharePhase? phase,
    double? progress,
    Object? code = _keep,
    Object? error = _keep,
    List<ShareViewer>? viewers,
    bool? isOnline,
    bool? removing,
    List<Friend>? friends,
  }) => ShareMemoryState(
    phase: phase ?? this.phase,
    progress: progress ?? this.progress,
    code: identical(code, _keep) ? this.code : code as String?,
    error: identical(error, _keep) ? this.error : error as String?,
    viewers: viewers ?? this.viewers,
    isOnline: isOnline ?? this.isOnline,
    removing: removing ?? this.removing,
    friends: friends ?? this.friends,
  );
}

/// The "Got a code?" form.
class JoinFormState {
  const JoinFormState({
    this.code = '',
    this.showErrors = false,
    this.busy = false,
    this.error,
  });

  final String code;
  final bool showErrors;
  final bool busy;
  final String? error;

  String? get codeError => showErrors ? InviteCode.validate(code) : null;
  bool get isValid => InviteCode.validate(code) == null;

  JoinFormState copyWith({
    String? code,
    bool? showErrors,
    bool? busy,
    Object? error = _keep,
  }) => JoinFormState(
    code: code ?? this.code,
    showErrors: showErrors ?? this.showErrors,
    busy: busy ?? this.busy,
    error: identical(error, _keep) ? this.error : error as String?,
  );
}
