<p align="center">
  <img src="assets/icon/app_icon.png" alt="Photo Quest app icon" width="120" />
</p>

<h1 align="center">Photo Quest</h1>

<p align="center">
  <strong>Do something together. Take the picture. Keep the memory.</strong>
</p>

<p align="center">
  <a href="https://github.com/Christian0162/photoquest/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/Christian0162/photoquest/actions/workflows/ci.yml/badge.svg" /></a>
  <img alt="Version 1.0.0" src="https://img.shields.io/badge/version-1.0.0-FF6B5F" />
  <img alt="Flutter 3.47+" src="https://img.shields.io/badge/Flutter-3.47%2B-02569B?logo=flutter" />
  <img alt="Dart 3.13+" src="https://img.shields.io/badge/Dart-3.13%2B-0175C2?logo=dart" />
  <img alt="Android and iOS" src="https://img.shields.io/badge/platform-Android%20%7C%20iOS-252323" />
</p>

Photo Quest is a social real-life quest and photobooth app. Pick a quest, do it
together in real life, and a playful photobooth turns it into a memory you can
repeat year after year.

It's private by design: no feed, no likes, no followers. The app is
**local-first** (capture and browse memories offline). A Supabase account
handles sign-in and profile, and sharing is invite-only.

<p align="center">
  <img src="docs/screenshots/launch.png" alt="Launch screen" width="200" />
  <img src="docs/screenshots/home.png" alt="Home with today's quest" width="200" />
  <img src="docs/screenshots/memories.png" alt="Memories as journal pages" width="200" />
  <img src="docs/screenshots/people.png" alt="People grouped by relationship" width="200" />
</p>

## Features

- **Quests:** guided activities for couples, families, friends, pets or solo.
- **Photobooth:** countdown, pose ideas, Photo / GIF / Boomerang / 360° modes.
- **Memories:** a private journal of everything you captured.
- **Keepsakes:** printed strips, grids and polaroids to decorate and share.
- **People & friends:** your circle, plus real friends added by friend code.
- **Do it again:** repeat a quest and watch the memories grow.

## Tech stack

Flutter · `camera` · Drift (SQLite) · Riverpod · `go_router` · `image` ·
Supabase (`supabase_flutter`, Free plan). Fonts: Outfit, Inter, Caveat.

## Getting started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and
   [Android Studio](https://developer.android.com/studio) (for the Android
   SDK and `adb`), then check your setup:

   ```bash
   flutter doctor --android-licenses
   flutter doctor -v
   ```

2. Install, generate code and run:

   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run --dart-define-from-file=env.json
   ```

   Without `--dart-define-from-file=env.json` sign-in won't work. In VS Code,
   add `"args": ["--dart-define-from-file=env.json"]` to your launch config.

The camera needs real hardware, so test on a physical phone.

### Connecting an Android phone

Enable Developer options (Settings → About phone → tap **Build number** 7
times), then either:

- **USB:** turn on **USB debugging**, plug in, accept the prompt, and check
  `flutter devices`.
- **Wireless (Android 11+, same Wi-Fi):** turn on **Wireless debugging**, then
  `adb pair <pairing-ip:port>` (enter the 6-digit code) and
  `adb connect <ip:port>`. The pairing and connect ports differ. If it fails,
  run `adb kill-server` and retry.

Then `flutter run -d <device-id> --dart-define-from-file=env.json`. iOS needs a
Mac with Xcode.

## Before you commit

```bash
dart format lib test
flutter analyze
flutter test
```

Re-run `build_runner` after changing a Drift table, a DAO or a `@riverpod`
provider; generated `*.g.dart` files are committed. [CI](.github/workflows/ci.yml)
runs the same checks, verifies generated code is current and builds an APK.

## Architecture

Layered and one-way: **Presentation → Domain → Data.** Photos are files;
memories are data (SQLite holds only metadata).

```text
lib/
├── main.dart, app.dart       # bootstrap and root MaterialApp.router
├── config/                   # constant/ (design system), env/, routes/ (all navigation)
└── core/
    ├── domain/               # entities and rules, one folder per area
    ├── data/                 # database/ (Drift), services/, repositories/
    └── presentation/
        ├── screen/           # logic: watches ViewModels, wires navigation/dialogs
        ├── view_model/       # state and actions (Riverpod Notifier)
        └── widget/           # atoms → molecules → organisms → templates
supabase/                     # migrations, RLS policy tests, setup guide
```

Every screen is three files with matching names:

| Part       | Location                       | Job                                           |
| ---------- | ------------------------------ | --------------------------------------------- |
| Screen     | `screen/<area>/*_screen.dart`  | Logic and wiring. No layout.                  |
| ViewModel  | `view_model/<area>/*_view_model.dart` | State, validation, actions.            |
| Template   | `widget/templates/*_template.dart` | Layout only: plain data and callbacks in. |

Loading and fetching live in the Screen, never in a Template. Only create a
domain-area folder or atomic-tier entry when a screen or component actually
needs it. The full product and engineering spec is [CLAUDE.md](CLAUDE.md).

### Naming conventions

| What          | Convention             | Example                          |
| ------------- | ----------------------- | --------------------------------- |
| Files         | `snake_case.dart`        | `memory_detail_view_model.dart`  |
| Classes       | `PascalCase`             | `MemoryDetailViewModel`          |
| Variables     | `camelCase`              | `selectedParticipants`           |
| Screens (logic)   | `<name>_screen.dart` | `memory_detail_screen.dart`      |
| View models   | `<name>_view_model.dart` | `memory_detail_view_model.dart`  |
| Templates (no logic) | `<name>_template.dart` | `memory_detail_template.dart` |
| Template previews | `<name>_template_preview.dart` | `memory_detail_template_preview.dart` |
| Atoms         | `md_<name>.dart` in `widget/atoms/` | `md_primary_button.dart` → `MdPrimaryButton` |
| Molecules     | `md_<name>.dart` in `widget/molecules/` | `md_app_card.dart` → `MdAppCard` |
| Organisms     | `md_<name>.dart` in `widget/organisms/` | `md_app_scaffold.dart` → `MdAppScaffold` |
| Repositories  | `<aggregate>_repository.dart` | `quest_repository.dart`    |
| Drift tables  | `<name>_table.dart`      | `quest_shots_table.dart`         |
| DAOs          | `<name>_dao.dart`        | `quests_dao.dart`                |

Atoms, molecules and organisms all carry the `md_` file prefix (classes:
`Md` + `PascalCase`); the tier is expressed only by the folder. A screen, its
ViewModel and its template share the same base name (`memory_detail_*`)
across their three folders. Avoid vague names like `helper.dart`,
`manager.dart` or `utils2.dart`; prefer specific ones
(`photo_storage_service.dart`).

## Versioning

[Semantic Versioning](https://semver.org) in `pubspec.yaml` as
`MAJOR.MINOR.PATCH+BUILD` (e.g. `1.0.0+1`). Bump the build number on every
store upload and record releases in [CHANGELOG.md](CHANGELOG.md).

## Credits

Example quest photos are from [Unsplash](https://unsplash.com), listed in
[`assets/images/quests/CREDITS.md`](assets/images/quests/CREDITS.md). The app
icon is [`assets/icon/app_icon.png`](assets/icon/app_icon.png); replace the
generated Android and iOS icons together if it changes.
