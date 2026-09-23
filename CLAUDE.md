# Photo Quest — Master Engineering & Product Skill

## 1. Project Identity

You are working on **Photo Quest**, a mobile application built with Flutter.

Photo Quest is a **social real-life quest and photobooth app**. It is not a
photo-editing app, a generic camera app, a public social-media feed, or a
digital scrapbook.

The core idea:

> **Do something together. Take the picture. Keep the memory.**

The product revolves around one loop:

```text
QUEST → PEOPLE → REAL-LIFE ACTIVITY → PHOTOBOOTH → MEMORY
```

A **Quest** guides one or more people through a real-life activity and a
sequence of photographs:

* different poses
* different angles
* different perspectives
* candid moments
* close-up shots
* wide shots
* group shots
* playful prompts
* relationship/family/friend/pet/solo moments

A quest is **not complete** just because someone taps "Completed." Its
required photobooth photo(s) must actually be captured — the photo is the
evidence the quest happened in real life.

The resulting photographs become a **Memory**.

The long-term purpose is to let people repeat the same Quest over time and
see how life — and their relationships — change.

Example:

```text
US — 2026
    ↓
US — 2027
    ↓
US — 2028
    ↓
US — 2029
```

The product should make people feel:

> "Let's do this together."

not:

> "Let's browse an app."

and:

> "Let's make a memory."

not:

> "Let's take another photo."

---

# 2. Product Principles

Always preserve these principles when implementing features.

## 2.1 Real Life First

Photo Quest should push people out into the real world, not keep them
scrolling inside the app.

The important action is people doing something together. The app's job is
to prompt that activity, then capture proof of it — not to be the activity
itself.

## 2.2 Quests Create Memories

The photograph is the artifact. The memory is the product. The camera is
the experience. The Quest is the structure that gets people there together.

Think:

```text
Quest
  ↓
Participants (People)
  ↓
Photo Session
  ↓
Photos
  ↓
Memory
  ↓
Timeline
  ↓
Growth Over Time
```

## 2.3 Every Quest Requires a Photobooth Result

```text
Quest Created
    ↓
Participants Invited
    ↓
Quest Accepted
    ↓
Quest Started
    ↓
Photobooth Instructions
    ↓
Required Photo(s) Captured
    ↓
Photo Confirmed
    ↓
Quest Completed
    ↓
Memory Created
```

Do not let a quest be marked complete by a button press alone — completion
is gated on its required shots actually being captured (§11, §21, §60).

## 2.4 Photobooth Experience

The camera experience should feel like a modern physical photobooth.

Important characteristics:

* large camera preview
* a visual example of what to do (pose/positioning/expression), never a
  photography tutorial
* countdown
* visual instructions
* progress indicators
* shutter feedback
* flash effect
* playful transitions
* minimal UI during capture
* clear next-shot guidance
* satisfying completion state

Avoid making the camera screen look like a generic phone camera.

## 2.5 Emotional Product

The app should feel:

* warm
* personal
* playful
* nostalgic
* intimate
* memorable
* simple
* premium
* social, but never performative

Avoid:

* enterprise UI
* dashboard-heavy layouts
* excessive data
* technical terminology
* overly complex settings
* generic SaaS styling
* likes, followers, engagement scores, trending feeds, popularity mechanics

Photo Quest's social model is: **invite → participate → complete together →
create memory.** It is not a public feed.

---

# 3. Technology Stack

## Core

Use:

* Flutter
* Dart

Target:

* Android
* iOS

The project should remain cross-platform.

Flutter provides a reactive UI framework and allows shared application code
across platforms while integrating with native platform capabilities.

---

# 4. Core Libraries

Use the following libraries unless there is a strong technical reason to
change them.

## Camera

Use:

```yaml
camera:
```

Purpose:

* camera preview
* photo capture
* camera switching
* flash/torch
* camera lifecycle
* image streaming if required later

The official Flutter `camera` plugin currently supports Android, iOS and
web, including preview, image/video capture and image streaming.

Do NOT use `image_picker` as the primary camera implementation.

Photo Quest requires a custom photobooth camera experience.

---

# 5. Local Database

Use:

```yaml
drift:
drift_flutter:
```

SQLite is the underlying database.

Drift should provide the application's type-safe database layer.

Do not store actual photo binary data inside SQLite.

Use SQLite for:

* metadata
* relationships
* quests
* quest participants / invitations
* sessions
* memories
* people
* photo records
* settings
* timestamps
* ordering

Architecture:

```text
SQLite / Drift
    │
    ├── Memory metadata
    ├── Photo metadata
    ├── Quest metadata
    ├── Quest participants / invitations
    ├── People
    └── Relationships

Filesystem
    │
    ├── Original photos
    ├── Thumbnails
    └── Generated photo strips
```

Core rule:

> **Photos are files. Memories are data.**

---

# 6. File Storage

Use:

```yaml
path_provider:
```

for application directories.

The package provides platform-specific application storage directories
such as application documents/support and cache directories.

Recommended structure:

```text
app_documents/
    photos/
        originals/
        thumbnails/
        strips/
```

Never hardcode platform-specific storage paths.

Create a dedicated storage service.

Example responsibility:

```text
PhotoStorageService

saveOriginal()
saveThumbnail()
savePhotoStrip()
deletePhoto()
deleteMemoryFiles()
getPhotoPath()
```

The service owns filesystem behavior.

Repositories should not directly manipulate filesystem paths.

---

# 7. Image Processing

Use:

```yaml
image:
```

for local image manipulation.

Use it for:

* resizing
* compression
* cropping
* rotation
* thumbnails
* photo-strip composition
* image format conversion

The Dart `image` library supports reading, manipulating and writing common
image formats including JPEG, PNG, WebP and others.

Do not perform expensive image processing directly inside UI widgets.

Use a service or isolate/background execution when appropriate.

---

# 8. State Management

Use:

```yaml
flutter_riverpod:
riverpod_annotation:
riverpod_generator:
```

Riverpod is responsible for application state and dependency injection.

Use providers for:

* repositories
* services
* ViewModels
* screen state
* asynchronous state
* current user / profile
* selected people / quest participants
* active Quest
* invitations
* camera session state
* memory state

Riverpod providers encapsulate state/dependencies and are designed to be
composable and testable.

---

# 9. State Management Rules

Prefer:

```text
Notifier
AsyncNotifier
Provider
FutureProvider
StreamProvider
```

depending on the problem.

Do not create global mutable singletons.

Do not use static mutable variables as application state.

Do not place business logic inside widgets.

Do not use `StateProvider` for complex state.

Use `Notifier`/`AsyncNotifier` when state has meaningful behavior or
business logic. Riverpod's documentation specifically recommends more
structured notifiers for more complex state.

---

# 10. Navigation

Use:

```yaml
go_router:
```

Flutter's architecture recommendations currently recommend `go_router` for
most Flutter applications.

Navigation should be centralized.

Example:

```text
/
├── home
├── quests
├── quests/create
├── quests/:questId
├── quests/:questId/invitations
├── capture/:sessionId
├── memory/:memoryId
├── memories
├── people
└── settings
```

Do not scatter navigation logic throughout the application. Do not
introduce route changes without a product reason.

Widgets should only perform simple navigation actions.

---

# 11. Utility Libraries

Use:

```yaml
uuid:
intl:
path_provider:
share_plus:
```

Purpose:

### uuid

Generate stable IDs (users, quests, participants, photos, memories).

### intl

Dates, timestamps and formatting.

### path_provider

Filesystem directories.

### share_plus

Allow users to share finished photo strips/memories.

Only add another package when its value is clear. Avoid dependency bloat.

---

# 12. Development Dependencies

Use:

```yaml
flutter_lints:
build_runner:
drift_dev:
riverpod_generator:
custom_lint:
riverpod_lint:
```

where appropriate for the selected Riverpod/Drift setup.

Use code generation where it meaningfully reduces repetitive code. Do not
introduce code generation everywhere simply because it exists.

---

# 13. Architecture

Use a **layered architecture with domain-grouped subfolders**.

Flutter's current architecture guidance recommends separation of UI and
data responsibilities, repositories as sources of truth, ViewModels for UI
logic, dependency injection, unidirectional data flow, immutable state, and
testing architectural components separately.

Photo Quest should use:

```text
Presentation
      ↓
Domain
      ↓
Data
```

The domain layer should remain lightweight. Do not create unnecessary
abstractions.

---

# 14. Architecture Flow

The preferred flow is:

```text
USER
 ↓
VIEW
 ↓
VIEW MODEL / NOTIFIER
 ↓
USE CASE
 ↓
REPOSITORY
 ↓
DATA SOURCE / SERVICE
 ↓
SQLite / Filesystem / Native Plugin
```

Data returns upward:

```text
SQLite / Filesystem
 ↓
Data Source
 ↓
Repository
 ↓
Domain Model
 ↓
ViewModel
 ↓
UI State
 ↓
VIEW
```

This is a unidirectional data flow.

---

# 15. Layer Responsibilities

## Presentation

Responsible for:

* widgets
* screens
* UI state
* user interaction
* animations
* responsive layout
* navigation
* formatting data for display

Should NOT directly access:

* SQLite
* Drift DAOs
* filesystem
* camera plugin
* raw database queries

---

## Domain

Responsible for:

* business rules
* entities
* use cases
* important workflows
* validation

Examples:

```text
CreateMemory
CompleteQuest
StartQuestSession
CaptureQuestShot
InviteParticipant
RespondToInvitation
DeleteMemory
RepeatQuest
GeneratePhotoStrip
```

Do not create a use case for trivial one-line operations unless it
improves clarity.

---

## Data

Responsible for:

* repositories
* database
* Drift tables/DAOs
* file storage
* camera service
* image processing
* platform services

The data layer should hide implementation details from the presentation
layer.

---

# 16. Repository Rule

Repositories are the source of truth for application data.

Example:

```text
MemoryRepository
    getMemories()
    getMemory()
    createMemory()
    deleteMemory()

QuestRepository
    getQuests()
    getQuest()
    createQuest()
    getParticipants()
    inviteParticipant()
    respondToInvitation()
    removeParticipant()
```

The ViewModel should depend on:

```text
QuestRepository
```

not:

```text
QuestDao
```

and never:

```text
DriftDatabase
```

Flutter's architecture guidance recommends repository abstractions because
they isolate data access from the rest of the application and make
implementations replaceable/testable.

---

# 17. Services

Services represent external/platform mechanisms.

Examples:

```text
CameraService
PhotoStorageService
ImageProcessingService
PhotoStripService
FileService
```

Services should not contain UI logic.

Example:

```text
CameraService
    initialize()
    switchCamera()
    capturePhoto()
    dispose()
```

The camera service knows how to operate the camera. It does not know what
a Memory is.

---

# 18. Database Design

Initial entities:

```text
people
quests
quest_participants
quest_shots
quest_sessions
memories
photos
memory_people
```

Relationship:

```text
QUEST
  │
  ├── QUEST_PARTICIPANTS ── PERSON
  │
  └── QUEST_SHOTS
          │
          ↓
    QUEST_SESSION
          │
          ↓
       MEMORY
          │
          └── PHOTOS
```

People:

```text
PERSON
  │
  ├── QUEST_PARTICIPANTS
  │        │
  │        ↓
  │      QUEST
  │
  └── MEMORY_PEOPLE
          │
          ↓
       MEMORY
```

This allows one quest to have multiple participants, and one memory to
contain multiple people.

> **Local-first note (§56A):** V1 has no backend/auth. `people` doubles as
> the local, on-device stand-in for both "a person tagged in a memory" and
> "a participant on a quest" — one `person.type == 'self'` row represents
> the device owner. There is no separate network `User`/`Invitation` model
> yet; `quest_participants.status` carries the invited → accepted/declined
> lifecycle locally. See §54A before adding real accounts or network
> invitations.

---

# 19. Initial Tables

## people

```text
id
name
type
avatar_path
created_at
updated_at
```

Possible `type`:

```text
self
partner
family
friend
pet
other
```

`type == 'self'` is the device owner and the implicit creator of quests
they start.

---

## quests

```text
id
creator_id       -- people.id; null for built-in quest templates
title
description
category
type             -- solo, pair, group
status           -- draft, published, invited, active, completed
max_participants -- nullable; a configured default applies when null (§15A)
cover_image_path
created_at
updated_at
```

Examples:

```text
Our First Date
Best Friends
Family Day
My Pet
Just Me
Birthday
Christmas
Random Day
```

Do not confuse `quests.status` (the quest template/instance lifecycle)
with `quest_participants.status` (one participant's membership state).
Keep them separate columns on separate tables (§16A).

---

## quest_participants

```text
id
quest_id
person_id
status        -- invited, accepted, declined, removed, completed
invited_at
responded_at
```

One quest has many participants; this is the join between `quests` and
`people` that also carries invitation/membership state.

---

## quest_shots

```text
id
quest_id
position
instruction
shot_type
example_image_path  -- visual example of the pose/framing (§10A)
required             -- whether this shot gates quest completion
created_at
```

Example:

```text
1
1
1
"Stand together and smile"
"group"
```

---

## quest_sessions

```text
id
quest_id
started_at
completed_at
status
```

Possible status:

```text
in_progress
completed
cancelled
```

---

## memories

```text
id
quest_session_id
title
note
captured_at
cover_photo_id
created_at
updated_at
```

---

## photos

```text
id
memory_id
shot_id
original_path
thumbnail_path
position
captured_at
width
height
```

---

## memory_people

```text
memory_id
person_id
```

Use a composite primary key where appropriate.

---

# 15A. Group Quest Participant Limit

The initial target for a group quest is **4–5 participants**. This limit
must live as a single configured constant (e.g. an `AppConstants` value
used by validation and by the participant-picker UI), never hardcoded
independently in multiple screens or repositories.

---

# 16A. Quest Status vs. Participant Status

```text
quest.status        draft → published → invited → active → completed
participant.status  invited → accepted | declined → (removed | completed)
```

A quest can be `active` while individual participants are still
`invited`. Do not merge these two state machines into one column.

---

# 20. Important Domain Distinction

Do not confuse:

```text
Person
Quest
Quest Participant
Quest Session
Memory
Photo
```

They represent different things.

### Person

Someone (or a pet) known to the app on this device — including the device
owner (`type == 'self'`). The local stand-in for a social "user" until a
real account system exists (§54A).

### Quest

A reusable template/instruction set, with an owner/creator and a
participation model (solo/pair/group).

```text
"Couple Anniversary"
```

### Quest Participant

One Person's membership and invitation status on one Quest.

### Quest Session

One attempt at that Quest.

```text
September 17, 2026 session
```

### Memory

The completed memory created by the session.

```text
Christian + Partner
September 17, 2026
```

### Photo

An individual image belonging to the Memory.

---

# 21. Repeat Quest

One of the most important product mechanics is repeating a Quest.

Example:

```text
2026
Couple Quest
4 photos

        ↓

2027
Same Couple Quest
4 photos

        ↓

2028
Same Couple Quest
4 photos
```

Never overwrite the previous session. Each repeat creates a new:

```text
QuestSession
Memory
Photos
```

Participants may be re-confirmed or changed per repeat, but the original
Quest template remains reusable.

---

# 22. Project Structure

Use this structure:

```text
lib/
│
├── main.dart
├── app.dart
│
├── config/
│   ├── constant/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_constants.dart
│   │   └── app_theme.dart
│   └── routes/
│       ├── app_router.dart
│       └── app_shell.dart
│
├── core/
│   ├── errors/
│   ├── extensions/
│   ├── utils/
│   └── presentation/
│       ├── enum/
│       ├── types/
│       ├── screen/
│       │   ├── home/
│       │   ├── quests/
│       │   ├── camera/
│       │   ├── memories/
│       │   ├── people/
│       │   └── settings/
│       ├── view_model/
│       │   ├── quests/
│       │   ├── camera/
│       │   ├── memories/
│       │   └── people/
│       └── widget/
│           ├── atoms/
│           ├── molecules/
│           ├── organisms/
│           └── template/
│
├── domain/
│   ├── quests/
│   │   └── entities/
│   ├── memories/
│   │   └── entities/
│   └── people/
│       └── entities/
│
└── data/
    ├── database/
    │   ├── app_database.dart
    │   ├── tables/
    │   ├── daos/
    │   └── seed/
    ├── services/
    │   ├── camera/
    │   ├── storage/
    │   ├── image/
    │   └── sharing/
    └── repositories/
```

`app.dart` holds the root `MaterialApp.router` widget; `main.dart` only
bootstraps it.

`core/presentation/screen/` and `core/presentation/view_model/` are
grouped by domain area (`quests`, `camera`, `memories`, `people`, `home`,
`settings`) so related screens and their ViewModels stay easy to find.
`core/presentation/widget/` follows atomic design (`atoms` → `molecules` →
`organisms` → `template`) instead of being duplicated per domain area,
since most UI components are shared or composed from small pieces.

`domain/` holds entities (and use cases, when needed — see §53) grouped
by domain area, not by technical layer.

`data/repositories/` is flat: one repository per aggregate
(`quest_repository.dart`, `memory_repository.dart`,
`people_repository.dart`), each with its Riverpod provider file alongside
it. Quest participant/invitation operations live on `QuestRepository`
rather than a separate repository, since they are part of the Quest
aggregate (§16).

---

# 23. Presentation Structure

Within `core/presentation/`, keep the same shape as the top-level
`screen/` and `view_model/` folders: one subfolder per domain area
(`home`, `quests`, `camera`, `memories`, `people`, `settings`). A screen
and its ViewModel live in the matching subfolder under `screen/` and
`view_model/` respectively — e.g. `screen/memories/memory_detail_screen.dart`
pairs with `view_model/memories/memory_detail_view_model.dart`.

Shared UI components go in `widget/`, classified by atomic-design tier:

```text
widget/
│
├── atoms/       # PrimaryButton, LoadingIndicator, PersonAvatar
├── molecules/   # AppCard, EmptyState, AppWidgetPreview
├── organisms/   # AppScaffold, QuestCard, MemoryCard, RecentMemoriesSection, ParticipantList
└── template/    # one *_template.dart per screen + its *_template_preview.dart,
                 # preview_samples.dart
```

Every screen is split in three:

```text
Screen     (screen/)            ConsumerWidget: watches ViewModels, wires
                                callbacks, navigation, dialogs, sheets,
                                snackbars. No layout, no business logic.
ViewModel  (view_model/)        state, validation, derived data, actions.
Template   (widget/template/)   the full page design. Plain data + callbacks
                                in; never touches `ref`, the router, or
                                repositories/services.
```

Templates build on the shared, reusable `AppScaffold`
(`widget/organisms/app_scaffold.dart`) — app bar, safe area, pinned bottom
action, back-button interception — and use `showAppMessage` for snackbars.
Do not assemble a raw `Scaffold` in a screen or template.

Previews live next to their template as `<name>_template_preview.dart` in
`widget/template/`. They render the template directly (no providers, no
database) with the shared sample cast in `preview_samples.dart`, so update
that one file when example data needs to change.

Only create a domain-area subfolder under `screen/` or `view_model/` when
a screen actually exists for it. Only create a new atomic tier folder
entry when a component actually belongs there — do not force something
into `organisms/` just to have an entry in every tier.

Only create folders that are actually needed. Do not create empty
architectural layers simply to satisfy a template.

---

# 24. Naming

Use Flutter/Dart naming conventions.

Files:

```text
snake_case.dart
```

Classes:

```text
PascalCase
```

Variables:

```text
camelCase
```

Examples:

```text
memory_detail_screen.dart
memory_detail_view_model.dart
memory_repository.dart
photo_storage_service.dart
quest_participant.dart
```

Avoid vague names:

```text
helper.dart
manager.dart
stuff.dart
common.dart
utils2.dart
```

Prefer specific names.

---

# 25. UI Architecture

A screen should generally look like:

```text
Screen
  ↓
ViewModel
  ↓
Widgets
```

Example:

```text
MemoryDetailScreen
MemoryDetailViewModel
MemoryPhotoGrid
MemoryHeader
MemoryPeople
MemoryTimeline
```

The screen coordinates composition. Individual widgets should remain
focused.

---

# 26. Widget Rules

Create a widget when:

* it has a clear responsibility
* it is reused
* it improves readability
* it contains meaningful UI behavior

Do not extract every three lines into a widget. Do not create generic
components before there is a real need.

Prefer:

```text
MemoryCard
```

over:

```text
UniversalRoundedContainerWithOptionalIconAndSpacing
```

---

# 27. Design System

The app should use a centralized design system.

Never scatter arbitrary values throughout the application.

Use:

```text
AppColors
AppTypography
AppSpacing
AppRadius
AppShadows
```

Example:

```text
AppSpacing.xs
AppSpacing.sm
AppSpacing.md
AppSpacing.lg
AppSpacing.xl
```

and:

```text
AppRadius.sm
AppRadius.md
AppRadius.lg
AppRadius.xl
```

---

# 28. Color System

Primary visual direction:

**Warm photobooth + nostalgic film + modern mobile UI**

Base palette:

```text
Warm Coral       #FF6B5F
Warm Cream       #FFF9F3
Soft Peach       #FFD9C7
Film Yellow      #FFD166
Warm Charcoal    #252323
Soft Green       #A8C7A1
```

Use:

```text
Warm Cream
```

as the primary light background.

Use:

```text
Warm Charcoal
```

for primary text.

Use:

```text
Warm Coral
```

for primary actions and important accents.

Use:

```text
Film Yellow
```

sparingly for playful highlights.

Use:

```text
Soft Peach
```

for supporting surfaces.

Do not use every color on every screen. The palette should feel
intentional.

---

# 29. Typography

Preferred direction:

```text
Headings:
Outfit

Body:
Inter
```

Alternative:

```text
Plus Jakarta Sans
```

Typography should feel:

* friendly
* modern
* warm
* readable

Avoid overly corporate typography.

---

# 30. UI Style

Use:

* rounded cards
* generous spacing
* large photography
* subtle shadows
* soft surfaces
* large touch targets
* clear hierarchy
* minimal text
* strong imagery
* playful micro-interactions

Avoid:

* excessive borders
* dense tables
* tiny buttons
* excessive gradients
* excessive glassmorphism
* dashboard aesthetics
* unnecessary icons
* likes/followers/engagement-score UI

---

# 31. Home Screen

The home screen should focus on things the user can do **today**, not
become a dashboard full of statistics.

Suggested hierarchy:

```text
Greeting

Today's Quest
┌─────────────────────────┐
│ Take a photo with       │
│ someone you love        │
│                         │
│ [Example image]         │
│                         │
│ Start Quest             │
└─────────────────────────┘

Invitations
"You've been invited..."

Your Quests

Recent Memories

Create Quest
```

Primary CTA:

```text
Let's Make a Memory
```

or:

```text
Start a Quest
```

Do not make Home feel like a database dashboard.

---

# 32. Core Navigation

Recommended navigation:

```text
Home
Quests
Create
Memories
Profile
```

The primary Quest/create action should be visually prominent, e.g.:

```text
Home      Memories     [ + ]     People
```

Do not overload the navigation bar.

---

# 33. Quest Selection & Creation

Quest selection should feel inspirational, not like a dense list.

Example:

```text
Choose a Quest

For Us
[ Anniversary ]
[ Date Night ]

For Family
[ Family Day ]
[ Holiday ]

For Friends
[ Best Friends ]

For Me
[ Just Me ]

For Life
[ Random Day ]
```

Large visual cards are preferred over dense lists.

Quest creation flow:

```text
Create Quest
    ↓
Quest title
    ↓
Description
    ↓
Choose quest type (solo/pair/group)
    ↓
Choose participants
    ↓
Configure photobooth shots
    ↓
Review
    ↓
Create Quest
```

Every quest should answer, in its description:

1. What are we doing?
2. Who is this for?
3. What should we do in real life?
4. What photo needs to be captured?

Descriptions should be short, friendly, and actionable.

---

# 34. Camera / Photobooth Screen

This is one of the most important screens.

Prioritize, in order: participants, example shot, instruction, camera
preview, countdown, capture, review, retake/keep, progress.

Structure:

```text
┌──────────────────────────────┐
│ Shot 2 of 4                  │
│                              │
│ "Get closer together"        │
│                              │
│      [Example Photo]         │
│                              │
│         CAMERA VIEW          │
│                              │
│             3                │
│                              │
│             ●                │
└──────────────────────────────┘
```

During countdown, minimize visual distractions.

---

# 35. Capture Experience

Capture flow:

```text
Instruction
 ↓
Example
 ↓
Ready
 ↓
Countdown
 ↓
Shutter
 ↓
Photo captured
 ↓
Preview feedback
 ↓
Retake / Keep
 ↓
Next instruction
```

The user should always know:

* what to do
* which shot they're on
* what happens next

Avoid unnecessary confirmation dialogs between shots.

---

# 36. Photo Strip

The generated photo strip should feel like a physical photobooth print.

Example:

```text
┌────────────────────┐
│                    │
│      PHOTO 1       │
│                    │
├────────────────────┤
│      PHOTO 2       │
│                    │
├────────────────────┤
│      PHOTO 3       │
│                    │
├────────────────────┤
│      PHOTO 4       │
│                    │
│                    │
│     PHOTO QUEST    │
│     Sept 17 2026   │
└────────────────────┘
```

The strip should be generated as an actual image file.

---

# 37. Quest Completion & Memory Reveal

A quest must not be manually completed without its required photo(s).

For a single required shot:

```text
Capture photo
    ↓
Review photo
    ↓
Keep / Retake
    ↓
Photo accepted
    ↓
Quest completed
```

For multiple required shots:

```text
Shot 1 → complete
Shot 2 → complete
Shot 3 → complete
        ↓
All required shots complete
        ↓
Quest complete
```

Do not immediately throw the user into a database list after completion.
Create a satisfying reveal:

```text
Quest Complete ✨

You made a memory.

[ Photo Strip ]

September 17, 2026

[ Keep This Memory ]
```

---

# 38. Memories Screen

The Memories screen is not a social feed. It is the user's private
memory collection, shared only with the people who were actually there.

Possible layout:

```text
Memories

2026

[ large memory ]
[ large memory ]

September
[ memory ] [ memory ]

August
[ memory ]
```

Prioritize: photography, dates, participants, Quest identity.

Avoid: likes, followers, comments, public engagement metrics.

---

# 39. Memory Detail

Memory detail should contain:

```text
Quest title
Date
Participants
Quest
Photos
Note
Photo strip
Repeat Quest
```

Important CTAs:

```text
Do This Again
Share
View Participants
```

"Do This Again" connects the current memory to future memories (§21).

---

# 40. People & Participants

People are private, on-device entities used to organize memories and
participate in quests.

Examples:

```text
Me
Partner
Mom
Dad
Friends
Buddy
```

A Person can appear in multiple memories and be a participant on multiple
quests. Quest participants have explicit membership state (§16A,
`quest_participants.status`): `invited`, `accepted`, `declined`,
`removed`, `completed`.

Do not create social-network behavior (public profiles, followers,
discovery feeds). Invitation is always explicit and scoped to one quest.

---

# 41. Group Quests

Group quests are one quest shared by multiple participants — not several
separate quests.

```text
Family Christmas Quest

Participants

👤 Christian
👤 Mom
👤 Dad
👤 Sister
👤 Brother

5 / 5 participants
```

The participant limit (initial target 4–5, §15A) must come from a single
configured constant, never hardcoded per-screen.

---

# 42. Error Handling

Never expose raw exceptions to users.

Bad:

```text
SqliteException: UNIQUE constraint failed
```

Good:

```text
Something went wrong while saving your memory.
Please try again.
```

Log technical details for developers. Show friendly messages to users.

Always account for:

* camera permission denied
* camera unavailable
* photo capture failure
* user leaves during quest
* participant declines invitation
* participant removed
* incomplete required shots
* storage failure
* corrupted image
* quest no longer available
* duplicate invitation
* offline state

Never silently fail.

---

# 43. Loading States

Avoid unnecessary full-screen spinners.

Prefer: skeletons, progressive loading, subtle placeholders, image
placeholders, localized loading indicators.

For the camera:

```text
Initializing camera...
```

should only appear when genuinely necessary.

---

# 44. Empty States

Empty states should encourage the user.

Bad:

```text
No data found.
```

Good:

```text
Your memories will live here.

Ready to make the first one?

[ Start a Quest ]
```

---

# 45. Animations

Animations should communicate transition, progress, feedback, or
emotional reward. Avoid animation for decoration alone.

Use animations especially for:

```text
Quest start
Countdown
Capture
Photo preview
Quest completion
Memory reveal
Timeline transitions
```

Animations should be short and responsive. Never make users wait for
decorative animations.

---

# 46. Performance

Photo processing can be expensive. Rules:

* never decode huge images unnecessarily
* create thumbnails
* avoid rebuilding entire screens unnecessarily
* dispose camera controllers correctly
* dispose animation controllers
* process images outside the UI thread when appropriate
* paginate large memory/quest collections
* avoid loading every original photo at once

---

# 47. Camera Lifecycle

Camera resources must be managed carefully.

Handle: initialization, permission denial, app lifecycle,
background/foreground transitions, camera switching, disposal, errors.

Never assume the camera remains available forever.

---

# 48. Database Rules

All database access must go through:

```text
DAO
 ↓
Repository
```

Do not write SQL queries inside: Screen, ViewModel, Widget, UseCase.

Database schema belongs inside `data/database/`.

---

# 49. Migration Rules

Database changes must use migrations. Never casually delete/recreate
production tables.

Whenever schema changes:

```text
version N
    ↓
migration
    ↓
version N+1
```

Test migrations.

---

# 50. Dependency Injection

Use Riverpod providers to construct:

```text
Database
Repositories
Services
UseCases
ViewModels
```

Example conceptual dependency graph:

```text
PhotoStorageService
        ↓
PhotoRepository
        ↓
MemoryRepository
        ↓
MemoryViewModel
        ↓
MemoryScreen
```

Do not manually instantiate repositories inside screens.

---

# 51. Testing

Write tests for important logic.

### Unit tests

* Quest completion (gated on required shots)
* Invitation/participant status transitions
* Memory creation
* Repeat Quest
* repository logic
* photo ordering
* photo-strip generation
* validation

### Widget tests

* Home
* Quest selection / creation
* Memory detail
* Participant picker / invitations list
* empty states
* error states

### Integration tests

Later:

* full Quest flow, including participants
* camera flow where practical
* saving a memory
* reopening a saved memory

Flutter recommends testing services, repositories and ViewModels
separately, along with widget tests for views and important
routing/dependency-injection behavior.

---

# 52. Git Rules

Use meaningful commits.

Examples:

```text
feat: add quest selection flow
feat: implement photobooth countdown
feat: add memory persistence
feat: add quest participants and invitation status
fix: handle camera lifecycle
fix: prevent duplicate memory photos
refactor: extract photo storage service
test: add memory repository tests
```

Do not create commits like: `update`, `changes`, `fix`, `stuff`, `final`,
`final2`.

---

# 53. Code Quality

Before considering a feature complete:

```text
flutter analyze
flutter test
```

must pass. Use `dart format`.

Do not leave: dead code, unused imports, temporary debugging prints,
commented-out abandoned implementations, duplicate business logic, TODOs
without reason.

---

# 54. Architecture Decision Rule

Do not over-engineer.

Before creating:

```text
abstract class X
XImpl
XFactory
XManager
XCoordinator
XBuilder
```

ask whether the abstraction solves a real problem.

Prefer simple architecture that can evolve. Flutter's own guidance
explicitly treats the domain/use-case layer as conditional: introduce it
when client-side business logic becomes sufficiently complex, rather than
adding it mechanically to every app.

For Photo Quest, use domain objects/use cases where they clarify the
Quest → Participants → Session → Memory workflow.

---

# 54A. Do Not Build Yet (Real Backend / Social Infrastructure)

Photo Quest's product vision is social and eventually needs real
authentication and cross-device invitations (§54B). Unless specifically
requested, do NOT prematurely implement:

* Firebase / Supabase / any remote backend
* real network authentication (passwords, OAuth, sessions, tokens)
* cloud synchronization
* push notifications
* public profiles, followers, likes, comments
* public discovery / recommendation feeds
* AI photo generation
* AI face recognition
* payments / subscriptions / ads

V1 ships **local-first**: one `people` row with `type == 'self'` stands
in for "the current user," and quest participants/invitations are modeled
and stored locally on-device (§18 note, §16A). This lets the full quest →
participants → photobooth → memory data model and UI be built now, ready
to swap onto a real backend later without reshaping the domain layer.

---

# 54B. Future Architecture

The architecture should make real accounts and cloud synchronization
possible later without a rewrite.

Future:

```text
                Repository
                    │
           ┌────────┴────────┐
           │                 │
       Local DB          Remote API
           │                 │
        SQLite           Cloud DB
```

But V1 should only implement:

```text
Repository
    ↓
SQLite
```

When a real backend is introduced, `people` (self) becomes the local
cache of an authenticated `User`, and `quest_participants.status`
transitions start being driven by real invitations instead of local-only
state changes. Do not build synchronization before the product needs it.

---

# 55. Local-First Principle

Photo Quest should work without a network account in V1.

The user should be able to:

```text
Open app
 ↓
Create Quest
 ↓
Add participants (local People)
 ↓
Take photos
 ↓
Create Memory
 ↓
Close app
 ↓
Open app later
 ↓
Memory still exists
```

No internet should be required for the core experience.

---

# 56. Security / Privacy

Photos and quest/participant data are personal.

Treat all memories and quests as private by default. Quest participation
requires an explicit invite/accept step, even locally.

Do not upload photos anywhere unless explicitly required by a future
feature. Do not add analytics that collect photo contents. Do not expose
filesystem paths in the UI. Do not expose one person's private
information to another without cause.

---

# 57. UI Copywriting

Use warm, human language.

Prefer:

```text
Let's make a memory.
```

over:

```text
Create Session
```

Prefer:

```text
Do this again
```

over:

```text
Repeat Quest
```

Prefer:

```text
You made a memory.
```

over:

```text
Session completed successfully.
```

Prefer:

```text
Invite someone to join
```

over:

```text
Add participant
```

Technical terminology belongs in code, not user-facing UI.

---

# 58. Product Vocabulary

Always use these meanings:

```text
Person
= someone (or a pet) known to the app on this device, including the
  device owner

Quest
= reusable guided real-life activity + photobooth experience, with an
  owner and a participation model (solo/pair/group)

Quest Participant
= one Person's membership/invitation status on one Quest

Shot
= one instruction/photo within a Quest

Quest Session
= one execution of a Quest

Photo
= one captured image

Memory
= completed collection of photos representing a moment, tied to the
  people who were there
```

Do not randomly rename these concepts. Do not conflate `quest.status`
with `quest_participants.status` (§16A).

---

# 59. Core Product Flow

The primary V1 flow is:

```text
Home
    ↓
Today's Quest / Create Quest
    ↓
Choose Participants
    ↓
Choose/Confirm Quest
    ↓
Quest Introduction (participants, example, instructions)
    ↓
Photobooth
    ↓
Shot 1 → Shot 2 → Shot 3 → Shot 4
    ↓
Photo Strip
    ↓
Memory Reveal
    ↓
Save Memory
    ↓
Memory Detail
    ↓
Memories
```

Secondary flow:

```text
Memory Detail
    ↓
Do This Again
    ↓
New Quest Session (participants re-confirmed)
    ↓
New Memory
```

Invitation flow (local-only in V1, §54A):

```text
Creator
   ↓
Creates Quest
   ↓
Selects People
   ↓
quest_participants rows created (status: invited)
   ↓
Accept / Decline (locally simulated until real accounts exist)
   ↓
Accepted participants join the Quest Session
```

---

# 60. Coding Philosophy

When implementing anything:

1. Understand the existing architecture.
2. Reuse existing abstractions.
3. Do not duplicate functionality.
4. Keep widgets focused.
5. Keep business logic out of widgets.
6. Keep database logic inside data layer.
7. Keep filesystem logic inside services.
8. Keep state inside Riverpod.
9. Prefer immutable state.
10. Write testable code.
11. Keep dependencies flowing in one direction.
12. Avoid unnecessary abstractions.
13. Preserve the existing design system.
14. Keep the product emotionally simple.
15. Never sacrifice UX for architectural purity.

---

# 61. Dependency Direction

The intended dependency direction is:

```text
Presentation
    ↓
Domain
    ↓
Data
```

Data must never depend on Presentation. Domain must never depend on
Flutter UI.

Avoid:

```text
Repository → Widget
Repository → BuildContext
Repository → Screen
```

Prefer:

```text
Screen
 ↓
ViewModel
 ↓
UseCase
 ↓
Repository
 ↓
Service / DAO
```

---

# 62. When Claude Is Asked to Implement a Feature

Before writing code:

1. Identify the feature.
2. Identify affected layers.
3. Inspect the existing project structure.
4. Reuse existing components.
5. Determine whether a new abstraction is actually needed.
6. Identify database changes, if any (and whether they need a migration).
7. Identify state changes.
8. Identify UI changes.
9. Check the request against §54A ("Do Not Build Yet") — flag real
   backend/auth/social-infrastructure asks before silently implementing
   them, and default to the local-only model instead.
10. Implement the smallest clean solution.
11. Run formatting.
12. Run analysis.
13. Run relevant tests.
14. Report what changed.

Do not rewrite unrelated files. Do not refactor unrelated architecture
during feature work.

---

# 63. When Claude Is Asked to Fix a Bug

Follow:

```text
Reproduce
    ↓
Locate root cause
    ↓
Understand affected layer
    ↓
Fix root cause
    ↓
Add regression test when practical
    ↓
Analyze
    ↓
Test
```

Do not blindly patch symptoms. Do not introduce a new package unless
necessary.

---

# 64. When Claude Is Asked to Design a Screen

First consider: Purpose, Primary action, Secondary action, Information
hierarchy, Empty state, Loading state, Error state, Accessibility,
Responsive layout, Animation.

Then implement. Every screen should have one obvious primary action.

---

# 65. Accessibility

Support: sufficient contrast, semantic labels, readable text, large
enough touch targets, screen-reader meaningful labels, reduced-motion
considerations where appropriate.

Do not communicate important information using color alone.

---

# 66. Responsive Design

The primary target is mobile. Do not design the application as a desktop
UI squeezed onto a phone.

Use `SafeArea`, `MediaQuery`, `LayoutBuilder`, `Flexible`, `Expanded` when
appropriate.

Respect: notches, status bars, navigation areas, different screen sizes,
portrait orientation.

---

# 67. Product Rule

When implementing a feature, always ask:

> Does this help people complete a real-life quest together and create a
> memorable photo?

If not, it should not automatically become part of the product.

---

# 68. Final Engineering Rule

The application should feel like:

```text
A beautiful photobooth
+
A shared quest between people who matter to you
+
A private memory box
+
A time capsule
```

not:

```text
A database with a camera attached.
```

Technical architecture exists to support that experience.

Always prioritize:

```text
User experience
    ↓
Product clarity
    ↓
Maintainable architecture
    ↓
Implementation simplicity
```

Do not allow technical complexity to leak into the user experience.
