import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

const _uuid = Uuid();

/// Inserts the starter set of Quest templates the first time the database
/// is created, so Quest Selection (CLAUDE.md §33) isn't empty on first
/// launch. Categories match the groupings from §33; titles/shots draw from
/// the examples in §19.
Future<void> seedDefaultQuests(AppDatabase db) async {
  final now = DateTime.now();

  for (final quest in _defaultQuests) {
    final questId = _uuid.v4();
    await db.questDao.insertQuest(
      QuestsCompanion.insert(
        id: questId,
        title: quest.title,
        category: quest.category,
        description: Value(quest.description),
        createdAt: now,
        updatedAt: now,
      ),
    );

    for (var i = 0; i < quest.shots.length; i++) {
      final shot = quest.shots[i];
      await db.questDao.insertShot(
        QuestShotsCompanion.insert(
          id: _uuid.v4(),
          questId: questId,
          position: i + 1,
          instruction: shot.instruction,
          shotType: shot.shotType,
          createdAt: now,
        ),
      );
    }
  }
}

class _SeedShot {
  const _SeedShot(this.instruction, this.shotType);

  final String instruction;
  final String shotType;
}

class _SeedQuest {
  const _SeedQuest({
    required this.title,
    required this.category,
    required this.description,
    required this.shots,
  });

  final String title;
  final String category;
  final String description;
  final List<_SeedShot> shots;
}

final _defaultQuests = <_SeedQuest>[
  _SeedQuest(
    title: 'Anniversary',
    category: 'For Us',
    description: 'Celebrate another year together.',
    shots: [
      _SeedShot('Stand close and smile like the day you met', 'group'),
      _SeedShot('Foreheads together, eyes closed', 'close_up'),
      _SeedShot('A candid laugh, mid-conversation', 'candid'),
      _SeedShot('Wide shot, wherever you are right now', 'wide'),
    ],
  ),
  _SeedQuest(
    title: 'Date Night',
    category: 'For Us',
    description: 'A little proof you still make time for each other.',
    shots: [
      _SeedShot('Cheers to tonight', 'group'),
      _SeedShot('Show off tonight\'s outfit', 'solo'),
      _SeedShot('Catch a candid mid-laugh', 'candid'),
      _SeedShot('Wide shot of where the night happened', 'wide'),
    ],
  ),
  _SeedQuest(
    title: 'Family Day',
    category: 'For Family',
    description: 'Everyone together, exactly as you are today.',
    shots: [
      _SeedShot('Everyone squeeze in for one big smile', 'group'),
      _SeedShot('The kids being themselves', 'candid'),
      _SeedShot('A close-up of someone you love', 'close_up'),
      _SeedShot('Wide shot of the whole crew', 'wide'),
    ],
  ),
  _SeedQuest(
    title: 'Holiday',
    category: 'For Family',
    description: 'This year\'s holiday, just as it happened.',
    shots: [
      _SeedShot('Everyone together by the decorations', 'group'),
      _SeedShot('Someone opening a gift, mid-reaction', 'candid'),
      _SeedShot(
        'A close-up of the details that made it feel like today',
        'close_up',
      ),
      _SeedShot('Wide shot of the whole room', 'wide'),
    ],
  ),
  _SeedQuest(
    title: 'Best Friends',
    category: 'For Friends',
    description: 'The people who feel like home.',
    shots: [
      _SeedShot('Everyone pile in together', 'group'),
      _SeedShot('Your best "we\'re ridiculous" face', 'candid'),
      _SeedShot('One friend, up close', 'close_up'),
      _SeedShot('Wide shot of wherever you ended up', 'wide'),
    ],
  ),
  _SeedQuest(
    title: 'Just Me',
    category: 'For Me',
    description: 'A moment for yourself, exactly as you are.',
    shots: [
      _SeedShot('However you\'re feeling right now', 'solo'),
      _SeedShot('A close-up, no pressure to pose', 'close_up'),
      _SeedShot('Something candid, caught off guard', 'candid'),
      _SeedShot('Wide shot of where you are today', 'wide'),
    ],
  ),
  _SeedQuest(
    title: 'Random Day',
    category: 'For Life',
    description: 'An ordinary day, worth remembering anyway.',
    shots: [
      _SeedShot('Whoever\'s around right now', 'group'),
      _SeedShot('Something candid from today', 'candid'),
      _SeedShot('A close-up of a small detail', 'close_up'),
      _SeedShot('Wide shot of today, as it looks right now', 'wide'),
    ],
  ),
];
