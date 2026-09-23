import '../../../domain/memories/entities/memory.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_participant.dart';
import '../../../domain/quests/entities/quest_shot.dart';
import '../../view_model/memories/memory_detail_view_model.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../../view_model/quests/quest_detail_view_model.dart';
import '../../view_model/quests/quest_list_view_model.dart';
import '../../view_model/quests/quest_participants_view_model.dart';
import '../../view_model/quests/quests_needing_confirmation_view_model.dart';

/// One consistent, made-up cast and set of Quests/Memories shared by every
/// `*_template_preview.dart`, so previews tell the same story. Dates are
/// fixed so previews look the same on every run. Photo paths are left
/// empty on purpose — the previewer can't read device files, so photos
/// render as the warm placeholder.
abstract final class PreviewSamples {
  static final today = DateTime(2026, 9, 17);

  // People -------------------------------------------------------------

  static final me = _person('p-me', 'Christian', 'self');
  static final jamie = _person('p-jamie', 'Jamie', 'partner');
  static final mom = _person('p-mom', 'Mom', 'family');
  static final dad = _person('p-dad', 'Dad', 'family');
  static final maya = _person('p-maya', 'Maya', 'friend');
  static final buddy = _person('p-buddy', 'Buddy', 'pet');

  static final people = [me, jamie, mom, dad, maya, buddy];

  /// Everyone except the device owner — who can be invited to a Quest.
  static final invitable = [jamie, mom, dad, maya, buddy];

  // Quests -------------------------------------------------------------

  static final anniversary = Quest(
    id: 'q-anniversary',
    title: 'Our Anniversary',
    description:
        'Go back to where you had your first date and recreate the moment.',
    category: 'For Us',
    type: 'pair',
    createdAt: today,
    updatedAt: today,
  );

  static final dateNight = Quest(
    id: 'q-date-night',
    title: 'Date Night',
    description: 'Cook something new together — photos before, during, after.',
    category: 'For Us',
    type: 'pair',
    createdAt: today,
    updatedAt: today,
  );

  static final familySunday = Quest(
    id: 'q-family-sunday',
    creatorId: me.id,
    title: 'Sunday at Mom & Dad’s',
    description: 'Lunch, a walk, and one big family photo on the porch.',
    category: 'For Family',
    type: 'group',
    status: 'invited',
    createdAt: today,
    updatedAt: today,
  );

  static final bestFriends = Quest(
    id: 'q-best-friends',
    title: 'Best Friends',
    description: 'Find the spot you always hang out at and own it.',
    category: 'For Friends',
    type: 'group',
    createdAt: today,
    updatedAt: today,
  );

  static final justMe = Quest(
    id: 'q-just-me',
    title: 'Just Me',
    description: 'Take yourself somewhere you love and capture how you feel.',
    category: 'For Me',
    createdAt: today,
    updatedAt: today,
  );

  static final shots = [
    _shot(anniversary.id, 0, 'Stand where you first met and smile', 'group'),
    _shot(anniversary.id, 1, 'A close-up of your hands together', 'close_up'),
    _shot(anniversary.id, 2, 'Walk away, looking back', 'candid'),
    _shot(anniversary.id, 3, 'The widest shot of the place', 'wide'),
  ];

  static final questDetail = QuestDetail(quest: anniversary, shots: shots);

  static final groupQuestDetail = QuestDetail(
    quest: familySunday,
    shots: [
      _shot(familySunday.id, 0, 'Everyone squeeze onto the porch', 'group'),
      _shot(familySunday.id, 1, 'Mom and Dad, just the two of you', 'candid'),
    ],
    creator: me,
  );

  /// Mom's in, Dad hasn't confirmed yet.
  static final familyParticipants = [
    _participant(familySunday.id, mom, 'accepted'),
    _participant(familySunday.id, dad, 'invited'),
  ];

  static final questShelves = [
    QuestCategoryShelf(
      category: 'For Us',
      quests: [
        QuestListItem(quest: anniversary),
        QuestListItem(quest: dateNight),
      ],
    ),
    QuestCategoryShelf(
      category: 'For Family',
      quests: [
        QuestListItem(quest: familySunday, participants: [mom, dad]),
      ],
    ),
    QuestCategoryShelf(
      category: 'For Friends',
      quests: [QuestListItem(quest: bestFriends)],
    ),
    QuestCategoryShelf(
      category: 'For Me',
      quests: [QuestListItem(quest: justMe)],
    ),
  ];

  static final questsNeedingConfirmation = [
    QuestNeedingConfirmation(
      quest: familySunday,
      people: [mom, dad],
      pendingCount: 1,
    ),
  ];

  // Memories -----------------------------------------------------------

  static final memories = [
    _summary('m-anniversary', 'Our Anniversary', DateTime(2026, 9, 14), [
      me,
      jamie,
    ]),
    _summary('m-park', 'Buddy’s Park Day', DateTime(2026, 9, 3), [me, buddy]),
    _summary('m-lake', 'Lake Weekend', DateTime(2026, 8, 22), [me, maya]),
    _summary('m-christmas', 'Family Christmas', DateTime(2025, 12, 25), [
      me,
      mom,
      dad,
    ]),
  ];

  static final memoryMonths = [
    MemoryMonth(month: DateTime(2026, 9), memories: memories.sublist(0, 2)),
    MemoryMonth(month: DateTime(2026, 8), memories: [memories[2]]),
    MemoryMonth(month: DateTime(2025, 12), memories: [memories[3]]),
  ];

  static final memoryDetail = MemoryDetail(
    memory: Memory(
      id: 'm-anniversary',
      questSessionId: 's-anniversary',
      title: 'Our Anniversary',
      note: 'It rained the whole time — somehow the best one yet.',
      capturedAt: DateTime(2026, 9, 14),
      createdAt: today,
      updatedAt: today,
    ),
    photos: const [],
    people: [me, jamie],
    questId: anniversary.id,
    stripPath: null,
  );

  // Helpers ------------------------------------------------------------

  static Person _person(String id, String name, String type) => Person(
    id: id,
    name: name,
    type: type,
    createdAt: today,
    updatedAt: today,
  );

  static QuestShot _shot(
    String questId,
    int position,
    String instruction,
    String shotType,
  ) => QuestShot(
    id: '$questId-shot-$position',
    questId: questId,
    position: position,
    instruction: instruction,
    shotType: shotType,
  );

  static QuestParticipantWithPerson _participant(
    String questId,
    Person person,
    String status,
  ) => QuestParticipantWithPerson(
    participant: QuestParticipant(
      id: '$questId-${person.id}',
      questId: questId,
      personId: person.id,
      status: status,
      invitedAt: today,
      respondedAt: status == 'invited' ? null : today,
    ),
    person: person,
  );

  static MemorySummary _summary(
    String id,
    String title,
    DateTime capturedAt,
    List<Person> people,
  ) => MemorySummary(
    memory: Memory(
      id: id,
      questSessionId: 's-$id',
      title: title,
      capturedAt: capturedAt,
      createdAt: capturedAt,
      updatedAt: capturedAt,
    ),
    coverPhoto: null,
    people: people,
  );
}
