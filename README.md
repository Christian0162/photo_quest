# Photo Quest

> **Do something together. Take the picture. Keep the memory.**

Photo Quest is a social, real-life quest and photobooth app for Android and
iOS, built with Flutter. A **Quest** gets people off their phones to do
something together. A photobooth-style camera guides them through the shots.
The photos become a private **Memory** that can be repeated year after year.

```text
QUEST → PEOPLE → REAL-LIFE ACTIVITY → PHOTOBOOTH → MEMORY
```

It isn't a social feed: no likes, no followers, no public profiles. V1 is
**local-first**. There's no account or backend, and everything stays on the
device.

The full product and engineering spec is in [CLAUDE.md](CLAUDE.md). Read it
before building a feature.

---

## Tech stack

| Concern             | Package                                      |
| ------------------- | -------------------------------------------- |
| Camera / photobooth | `camera`                                     |
| Local database      | `drift`, `drift_flutter` (SQLite)            |
| State & DI          | `flutter_riverpod`, `riverpod_annotation`    |
| Navigation          | `go_router`                                  |
| Image processing    | `image`                                      |
| Files & sharing     | `path_provider`, `share_plus`                |
| Utilities           | `uuid`, `intl`, `path`                       |
| Code generation     | `build_runner`, `drift_dev`, `riverpod_generator` |

Rule of thumb: **photos are files, memories are data.** Photo binaries live
on the filesystem. SQLite holds only metadata.

---

## Getting started

Requires Flutter 3.47+ (Dart 3.13+).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Run `build_runner` again after changing any Drift table or DAO, or any
`@riverpod` provider. Generated `*.g.dart` files are committed.

### Before you commit

```bash
dart format lib test
flutter analyze
flutter test
```

All three must pass.

---

## Architecture

Layered, with a one-way dependency: **Presentation → Domain → Data.**

```text
lib/
├── main.dart / app.dart        # bootstrap + root MaterialApp.router
├── config/
│   ├── constant/               # AppColors, AppTypography, AppSpacing, AppTheme, …
│   └── routes/                 # go_router config + bottom-nav shell
└── core/
    ├── domain/                 # entities (Quest, Person, Memory, Photo, …)
    ├── data/
    │   ├── database/           # Drift tables, DAOs, seed data
    │   ├── repositories/       # source of truth for app data
    │   └── services/           # camera, storage, image processing, sharing
    └── presentation/
        ├── screen/             # thin screens, grouped by area
        ├── view_model/         # Riverpod view models, grouped by area
        ├── types/              # display labels / icons
        └── widget/             # atomic design
            ├── atoms/
            ├── molecules/      # … + AppWidgetPreview
            ├── organisms/      # … + AppScaffold
            └── template/       # one page design per screen + its preview
```

### Screen → View model → Template

Every screen is split into three parts:

| Part           | Lives in            | Responsibility |
| -------------- | ------------------- | -------------- |
| **Screen**     | `screen/`           | `ConsumerWidget` that watches view models, wires callbacks, and handles navigation, dialogs, sheets and snackbars. No layout, no business logic. |
| **View model** | `view_model/`       | State, validation, derived data, and actions. Talks to repositories and services. |
| **Template**   | `widget/template/`  | The full page design. Takes plain data and callbacks, and never touches `ref`, the router, repositories or services. |

Templates are built on the shared **`AppScaffold`**
(`widget/organisms/app_scaffold.dart`). It handles the app bar, safe area, a
pinned bottom action, and back-button interception. Use `showAppMessage()`
for snackbars. Don't build a raw `Scaffold` in a screen or template.

---

## Widget previews

Every template has a `*_template_preview.dart` file next to it. Previews
render the template directly, with no providers and no database. All of
them use one shared sample cast from
[`preview_samples.dart`](lib/core/presentation/widget/template/preview_samples.dart).
Edit that file to change the example data.

Open them in VS Code (Flutter widget preview) or from the terminal:

```bash
flutter widget-preview start
```

They appear under the **templates** group.

The previewer generates a `.widget_preview/` folder inside the project. It's
gitignored and excluded in `analysis_options.yaml`, and it's safe to delete.
If previews stop showing up, stop the previewer, run **Dart: Restart
Analysis Server**, delete `.widget_preview/`, and start it again.

---

## Testing

```text
test/
├── config/        # design-system checks (e.g. color contrast)
├── data/          # repositories, image processing
└── presentation/  # view models, screens, and a smoke test that renders every template preview
```

Put business logic in view models or the data layer, so it can be
unit-tested without widgets.

---

## Conventions

- Use the design-system tokens (`AppColors`, `AppSpacing`, `AppRadius`,
  `AppTypography`). Never hardcode colors or spacing.
- Write warm, human copy ("You made a memory.", not "Session completed").
- Keep the vocabulary consistent: **Person, Quest, Quest Participant, Shot,
  Quest Session, Photo, Memory.**
- Every schema change goes through a Drift migration.
- Commits follow `feat:` / `fix:` / `refactor:` / `test:`.
- Not in V1: backend, auth, cloud sync, push notifications, or social
  features. See CLAUDE.md §54A.
