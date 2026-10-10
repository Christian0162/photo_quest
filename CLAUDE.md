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

A quest can be done alone, with friends, or with someone special — and the
memory can be shared, **privately, with the people invited to it** (§54C).
Sharing is invite-only. Photo Quest is never a public feed.

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

# 4A. Backend & Accounts (Supabase, Free plan)

Use:

```yaml
supabase_flutter:
image_picker:        # choosing an avatar from the photo library only
```

Supabase provides accounts (Auth), the cloud database (Postgres) and file
storage. The camera stays the custom `camera` plugin; `image_picker` is
**only** for picking an existing photo (e.g. a profile picture).

Everything must stay within the Supabase **Free** plan. The full rules —
Row Level Security, private buckets, secrets, migrations, the sharing
model — are in §54C. Read it before touching anything under `supabase/`,
auth, profiles, or any code that talks to the cloud.

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
        originals/    # still photos
        thumbnails/   # thumbnails, and poster frames of GIFs/clips
        motion/       # GIFs and boomerangs
        videos/       # 360° clips
        strips/       # printed keepsakes (strip / grid / polaroid)
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
├── settings
├── account
├── intro              (signed out, first launch only)
├── welcome            (signed out; its drawer holds log in + create account)
├── forgot-password    (signed out)
├── verify-email       (awaiting email confirmation)
└── reset-password     (choosing a new password)
```

Who may be on which route is decided in **one** place: the router's
`redirect`, driven by the auth status (`AuthSignedOut`,
`AuthAwaitingVerification`, `AuthRecovering`, `AuthSignedIn`). Screens never
navigate "because auth changed"; they change the status and the router
follows.

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

> **Accounts and the local database (§54C):** The person signs in with a
> Supabase account (`auth.users`, with a `profiles` row). The on-device
> `people` table is unchanged: it still holds everyone a memory can be
> tagged with — friends, family, pets — and the one `person.type == 'self'`
> row stands for the device owner. `people` rows are **local contacts**, not
> accounts. Linking a `self` row to the signed-in account's id, and turning
> a friend into a real invited account, belong to the sharing work planned
> in §54C. Until that is built, `quest_participants.status` still carries
> the invited → accepted/declined lifecycle locally.

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
kind            -- photo, gif, boomerang, video (schema v3)
```

For `gif`, `boomerang` and `video`, `original_path` is the `.gif` / `.mp4`
and `thumbnail_path` is a still poster frame used by cards and keepsakes.

---

## app_settings

```text
key     -- e.g. booth.countdown_seconds
value
```

On-device preferences (photobooth countdown and 360° clip length). Added in
schema v4, together with `memories.keepsake_design` (the saved layout,
paper and stickers of a memory's printed keepsake, as JSON).

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
owner (`type == 'self'`). A local contact, not an account: the signed-in
account is the Supabase user and its `profiles` row (§54C).

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

Use this structure (it matches the repository):

```text
lib/
│
├── main.dart                 # bootstraps: fonts, Supabase session restore
├── app.dart
│
├── config/
│   ├── constant/             # app_colors, app_typography, app_spacing,
│   │                         # app_motion, app_shadows, app_theme, ...
│   ├── env/
│   │   └── app_env.dart      # build-time config (Supabase URL + public key)
│   └── routes/
│       ├── app_router.dart   # routes + auth redirect
│       └── app_shell.dart
│
└── core/
    ├── errors/               # AppFailure and friendly subtypes
    ├── utils/
    │
    ├── domain/               # entities, enums, pure rules (no Flutter UI)
    │   ├── auth/             # account_user, user_profile, auth_status,
    │   │                     # auth_validators
    │   ├── camera/
    │   ├── memories/
    │   ├── people/
    │   └── quests/
    │
    ├── data/
    │   ├── database/         # Drift: app_database, tables/, daos/, seed/
    │   ├── services/         # camera, gallery, image, sharing, storage
    │   └── repositories/     # one per aggregate + its Riverpod provider
    │
    └── presentation/
        ├── screen/           # one subfolder per area (home, quests, camera,
        │                     # memories, people, settings, auth)
        ├── view_model/       # same areas as screen/
        ├── types/            # UI state and display models, per area
        └── widget/
            ├── atoms/
            ├── molecules/
            ├── organisms/
            └── templates/    # one *_template.dart per screen

supabase/                     # backend, at the repository root
├── migrations/               # reproducible SQL: tables, RLS, storage policies
├── tests/                    # SQL policy tests (+ local stubs for Docker)
└── README.md                 # setup, dashboard steps, Free-plan notes
```

`app.dart` holds the root `MaterialApp.router` widget; `main.dart` only
bootstraps it.

`core/presentation/screen/` and `core/presentation/view_model/` are
grouped by domain area (`quests`, `camera`, `memories`, `people`, `home`,
`settings`) so related screens and their ViewModels stay easy to find.
`core/presentation/widget/` follows atomic design (`atoms` → `molecules` →
`organisms` → `templates`) instead of being duplicated per domain area,
since most UI components are shared or composed from small pieces.

`core/domain/` holds entities (and use cases, when needed — see §53) grouped
by domain area, not by technical layer.

`core/data/repositories/` is flat: one repository per aggregate
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
├── atoms/       # MdPrimaryButton, MdLoadingIndicator, MdPersonAvatar
├── molecules/   # MdAppCard, MdEmptyState, MdAuthTextField
├── organisms/   # MdAppScaffold, MdQuestCard, MdMemoryCard, MdAuthLayout
└── templates/   # one *_template.dart per screen (+ *_template_preview.dart
                 # where a preview exists), preview_samples.dart
```

Shared widgets carry the `Md` prefix and sit in a subfolder per area
(`common`, `camera`, `memories`, `people`, `quests`, `auth`, ...).

Every screen is split in three:

```text
Screen     (screen/)            ConsumerWidget: watches ViewModels, wires
                                callbacks, navigation, dialogs, sheets,
                                snackbars. No layout, no business logic.
ViewModel  (view_model/)        state, validation, derived data, actions.
Template   (widget/templates/)  the full page design. Plain data + callbacks
                                in; never touches `ref`, the router, or
                                repositories/services.
```

**Fetching and loading live in the Screen, never in a Template.** The Screen
watches the providers and decides what to show: while the data the page is
made of has not arrived (`AsyncValue.isFirstFetch`, from
`presentation/types/async_value_loading.dart`), it returns
`MdAppScaffold(body: MdScreenLoading(...))` and nothing else, so the tab bar
stays but no content is drawn. Once it has arrived it passes the data into the
Template. A re-fetch that already has data keeps the page up. A Template never
checks `isLoading`/`isFirstFetch` to swap in a whole-page loader and never
fetches; it only draws the `AsyncValue` sections it is handed (a small
section-level skeleton or error is fine). The loader is the shared molecule
`MdScreenLoading` (`widget/molecules/common/`).

Templates build on the shared, reusable `MdAppScaffold`
(`widget/organisms/common/md_app_scaffold.dart`) — app bar, safe area, pinned bottom
action, back-button interception — and use `showAppMessage` for snackbars.
Do not assemble a raw `Scaffold` in a screen or template.

Previews live next to their template as `<name>_template_preview.dart` in
`widget/templates/`. They render the template directly (no providers, no
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

People are private entities used to organize memories and participate in
quests. On this device they are local contacts (friends, family, pets).
The People screen also lists **real friends on Photo Quest** (accounts),
added with a friend code and only once they accept (§54C); real friends can
be invited straight to a quest or memory with no code.

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
discovery feeds). Invitation is always explicit and scoped to one quest
or memory.

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
* auth flows against a fake `AuthRepository` (register, confirm with code,
  log in, wrong password, existing email, reset password, log out)
* Row Level Security and Storage policies (`supabase/tests/`) — any new
  table or bucket ships with checks that one account cannot read or change
  another's data

### Widget tests

* Home
* Quest selection / creation
* Memory detail
* Participant picker / invitations list
* auth screens at small/large phone sizes, with the keyboard open and at
  large text scale
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

# 54A. Do Not Build Yet (Out of Scope)

Accounts and a Supabase backend are **in scope** (§54C). Unless
specifically requested, still do NOT implement:

* any backend other than Supabase (Firebase, custom servers, other auth
  providers)
* paid Supabase features, paid third-party services, or Edge Functions that
  aren't clearly needed — everything stays on the Supabase **Free** plan
* push notifications
* public profiles, followers, likes, comments, reactions
* public discovery / recommendation / trending feeds
* AI photo generation
* AI face recognition
* payments / subscriptions / ads
* cloud copies of quests, memories or photos, and real cross-user
  invitations, **until the plan in §54C is confirmed** — they change who can
  read someone's photos, so they are designed first and built second

The product is social through invitation, not through a feed: people are
invited to a specific quest or memory and can see only what they were
invited to.

---

# 54B. Architecture Direction

The app is local-first with an account on top.

```text
Repository
    │
    ├── Local DB (Drift / SQLite)     ← every device, works offline
    └── Remote (Supabase)             ← accounts, profile, (planned) backup
                                         and sharing
```

Today: accounts (`AuthRepository`), the profile row and avatar
(`ProfileRepository`) use Supabase; quests, memories, photos and people use
only the local database. When cloud copies are added (§54C), the repository
interface stays the same, the local database remains the offline source of
truth for the device, and the remote side is added behind the repository —
presentation and domain do not change shape.

---

# 54C. Supabase Backend, Accounts & Sharing

## Status

Built (in `supabase/`, tested; the Flutter side for sharing is not built yet):

```text
Auth            email + password, email confirmed with a 6-digit code (no deep
                links), password reset with a code, session persisted
profiles        one row per account (display_name, avatar_path)
quests, quest_shots, quest_sessions, memories, photos
                cloud copies, owner-only, composite keys keep children under
                the same owner
memory_shares   who may VIEW a memory besides its owner
memory_invites  share codes (hashed), expiring, limited, revocable
friendships     friend requests; profiles.friend_code is private (no grant)
quest_participants / quest_invites
                taking part in a quest: invited -> accepted | declined
photos.uploaded_by  who added a photo (owner or a friend on the quest)
my_storage_usage()  100 MB online allowance per person
avatars         private bucket, 2 MB
photos          private bucket, 10 MB, <owner id>/<memory id>/<file>
delete_my_account()   deletes the caller's account and all their data
```

Built in Flutter:

* Account screen with **Delete my account** (confirms, deletes the person's
  Storage files first, then calls `delete_my_account()`, then returns to the
  welcome screen). Photos saved on the phone are kept.
* **Invite a friend** on a memory (`CloudMemoryRepository`): saves the memory
  online if needed (compressed copies only, resumable), makes a code, shows it
  to copy or send, and lists friends who can see it (removable). It can also
  take the memory's online copy away again.
* **Real friends** (`CloudFriendsRepository`, People screen): every account
  has a private **friend code**. You enter a friend's code, they get a request
  and accept or decline (nobody is added without their OK). Friends appear in
  People under "Friends on Photo Quest", and the invite sheets list them so
  you can invite one to a quest or share a memory in one tap, with no code.
* **Do a quest together** (`CloudQuestRepository`): an invite code on a pair or
  group quest. A friend enters it in the same box, is invited, and accepts or
  declines. Once in, they see the quest, who else is taking part and the
  memories made from it, and can **add their own photos** to them. They can
  leave; the owner can remove them.
* **Got a code?** and **Shared with you**: enter a code, see the list of
  memories friends shared, open one (photos, GIFs and clips, view only), and
  remove it from the list. Reached from Memories.

* **Back up my memories** (Settings): off by default. When on, new memories
  are saved online **on Wi-Fi only**, and the app catches up older ones when
  it opens. "Back up now" does it on any connection. It stops at once when
  storage is full, and a capture is never delayed or lost by it.
* **Storage allowance:** 100 MB of online photos per person (Free storage is
  1 GB for everyone). The upload policy enforces it; Settings shows the meter.

Nothing is uploaded unless the person invites someone or turns backup on.

Not built: restoring memories from the cloud onto a new phone (backup saves
them online, but they can't be brought back into the app yet), revoking a
single invite code from the app, deleting an online copy automatically when a
memory is deleted on the phone, a choice to also clear on-device photos when
deleting an account, and cleaning up friends' leftover files when a quest
owner's account is deleted.

## Rules that never bend

1. **Free plan only.** No paid features or services. Photos are large and
   Free storage is 1 GB: upload compressed copies, keep originals on the
   device.
2. **Row Level Security on every table**, written down per table as who may
   SELECT, INSERT, UPDATE and DELETE. Never a broad "authenticated can do
   everything" policy. Start from `revoke all`, then grant only what the app
   needs (column-level for UPDATE and, for secrets, SELECT).
3. **Private buckets.** Files live at `<owner user id>/...` and every Storage
   policy checks that first folder. Show private files through short-lived
   signed URLs, never public URLs.
4. **The client never supplies a user id.** Read it from the Supabase session
   (`auth.currentUser`); the database also checks `auth.uid()`.
5. **No secrets in the app.** Only the project URL and the publishable (anon)
   key, passed with `--dart-define-from-file=env.json` (gitignored; commit
   only `env.example.json`). Never a `service_role` / `sb_secret_` key, the
   database password or the JWT secret.
6. **Authorization lives in the database**, not in Flutter code.
7. **Migrations are the source of truth.** Every schema, RLS and Storage
   change is a new SQL file in `supabase/migrations/` with a comment saying
   why. Never edit a migration that may already have been applied; add a new
   one. Never change the schema only through the dashboard, and never disable
   RLS to make development easier.
8. **Every migration ships with policy tests** in `supabase/tests/`, and the
   tests must be shown to fail when a policy is loosened. Run them (Docker
   locally, or the SQL editor) before calling the work done. Don't run the
   local stub file on a real project.
9. **Passwords stay in Supabase Auth.** Never store them, or anything
   sensitive copied from `auth.users`, in our tables.
10. **Friendly errors.** Map Supabase error codes to warm, actionable copy in
    the repository; raw codes and exceptions never reach the screen (§42).

## Table conventions

* uuid primary keys with a default; the app may supply the id (offline
  creation).
* `timestamptz`; `updated_at` kept by a trigger.
* Enums are `CHECK` constraints; free text has length limits.
* Every foreign key has an index.
* Child rows carry `owner_id`, tied to the parent's owner with a composite
  foreign key.
* Internal helpers and bookkeeping live in the `private` schema. Functions
  clients may call are `SECURITY DEFINER` with `set search_path = ''`, have
  `execute` revoked from `public`/`anon`, and are granted to `authenticated`
  only.
* Policies use `(select auth.uid())`, one per command, `to authenticated`.

## Sharing model

Sharing is invite-only and, for now, view-only. Nothing is visible to anyone
except its owner and the accounts the memory was shared with.

```text
Owner makes an invite code for one memory   create_memory_invite()
    |
Owner tells a friend (message, in person)
    |
Friend enters the code                      redeem_memory_invite()
    |
Friend can VIEW that memory and its photos  memory_shares row
```

Decisions:

* **Find people by code, never by search**, so nobody can check who has an
  account. This covers invite codes and the **friend code** every account has
  (private to its owner, resettable, guessing throttled across all code kinds).
  Adding a friend needs their approval. Codes are random, hashed at rest, expire (7 days by default), have
  a use limit, can be revoked, and guessing is throttled (10 wrong tries per
  hour).
* **A friend with a memory code can only view.** A friend who has accepted a
  quest can also **add their own photos** to memories made from it (view and
  add; never edit or delete the owner's). Their files live in their own folder
  and count against their own allowance.
* **A quest holds a fixed number of people** (a pair two, a group the chosen
  size or 5, owner included). An invited person holds a place until they
  decline or are removed.
* **If an owner deletes their account, their memories are deleted** (and the
  shares with them). A viewer deleting theirs does not affect the owner.
* Local `people` without an account (pets, family who won't join) stay
  local-only tags; only accounts can view a shared memory.
* Network-backed providers use `@Riverpod(retry: neverRetry)` so a failed load
  shows the friendly error and "Try again" at once instead of retrying behind
  a skeleton.
* Capture is always local first: a photo is saved on the device, then
  uploaded in the background when the person is signed in and online. An
  upload failure never blocks or loses a capture.
* Deleting a memory or an account removes rows by cascade but **not Storage
  files**; the app deletes the person's files through the Storage API first.

Still open: how a friend learns the code (copy and paste for now; a link
later), restoring memories onto a new phone, and whether participants should
also be able to start sessions of a shared quest from their own phones.

---

# 55. Local-First Principle

Capturing and keeping a memory must not need the network.

The person signs in once; a restored session opens the app offline. Then they
should be able to:

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

Photobooth capture, saving a memory and browsing memories require no
internet. Only account actions (sign up, log in, reset, profile, and — when
built — sharing and backup) need it. Always save to the device first.

---

# 56. Security / Privacy

Photos and quest/participant data are personal.

Treat all memories and quests as private by default. A memory is visible only
to its owner and to people the owner explicitly invited (§54C). Quest
participation requires an explicit invite/accept step.

Photos stay on the device unless the person shares or backs them up (§54C).
When they are uploaded, they go to a private bucket under the owner's folder
and are read through signed URLs. Do not add analytics that collect photo
contents. Do not expose filesystem paths or storage paths in the UI. Do not
expose one person's private information to another without cause. Settings
copy must say honestly what is stored online (today: email, name and profile
photo only).

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

Invitation flow (local today; becomes real with accounts, §54C):

```text
Creator
   ↓
Creates Quest
   ↓
Selects People
   ↓
quest_participants rows created (status: invited)
   ↓
Accept / Decline
   (locally simulated today; the invited account answers once cloud
    invitations exist)
   ↓
Accepted participants join the Quest Session and can view the memory
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
9. Check the request against §54A ("Do Not Build Yet") and §54C —
   anything that changes who can see someone's photos (sharing, cloud
   copies, invitations) needs the §54C plan confirmed first; a new table or
   bucket needs RLS/Storage policies and policy tests.
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
