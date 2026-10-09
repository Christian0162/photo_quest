import '../memories/entities/photo.dart';

/// Short, playful pose prompts for "Need an idea?" in the photobooth — the
/// answer to "what do we do?". Curated content, no AI. Ideas that fit the
/// capture kind come first, then ideas for who's in the shot. See CLAUDE.md
/// §2.4, §34, design system §27.
abstract final class PoseIdeas {
  static const _solo = [
    'Look back over your shoulder and laugh',
    'Jump — mid-air counts!',
    'Frame your face with your hands',
    'Close your eyes and tilt toward the sky',
    'Strike your best superhero pose',
    'Hold up the thing that made today',
  ];

  static const _pair = [
    'Back to back, arms crossed',
    'Forehead to forehead',
    'One whispers a secret, one laughs',
    'Piggyback!',
    'Make one heart with both your hands',
    'Recreate your very first photo together',
    'Fake-surprised faces',
  ];

  static const _group = [
    'Everyone jump on "1"!',
    'Squeeze in, cheek to cheek',
    'Stack your hands in the middle',
    'Line up tallest to shortest',
    'Everyone point at one person',
    'Group hug from the side',
    'Funniest face wins',
  ];

  static const _gif = [
    'New pose on every flash!',
    'Get closer with each flash',
    'Go from serious to silly',
  ];

  static const _boomerang = [
    'Toss something up — leaves, confetti, a hat',
    'Clink your glasses',
    'High-five!',
    'Hair flip',
  ];

  static const _video = [
    'Stand still and smile while the camera circles you',
    'Hold hands and spin slowly',
    'Wave at the camera the whole way round',
  ];

  /// Ideas for a shot, most relevant first. [questType] is `solo`, `pair`
  /// or `group`; [kind] is a [PhotoKind].
  static List<String> forShot({
    required String questType,
    required String kind,
  }) {
    final forKind = switch (kind) {
      PhotoKind.gif => _gif,
      PhotoKind.boomerang => _boomerang,
      PhotoKind.video => _video,
      _ => const <String>[],
    };
    final forPeople = switch (questType) {
      'pair' => _pair,
      'group' => _group,
      _ => _solo,
    };
    return [...forKind, ...forPeople];
  }
}
