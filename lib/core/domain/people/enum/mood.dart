/// How someone is feeling right now, shown as a small status on Home. Stored
/// on this device only. See CLAUDE.md §2.5, §54A.
enum Mood {
  happy('Happy'),
  inLove('In love'),
  excited('Excited'),
  calm('Calm'),
  tired('Tired'),
  sad('Sad');

  const Mood(this.label);

  final String label;

  /// The saved mood for [name], or null if none was ever chosen.
  static Mood? fromName(String? name) {
    for (final mood in values) {
      if (mood.name == name) return mood;
    }
    return null;
  }
}
