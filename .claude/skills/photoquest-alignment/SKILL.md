---
name: photoquest-alignment
description: Use before starting any implementation, design, or bug-fix work in this repo, and again before reporting it done. Checks the request and the planned/actual changes against CLAUDE.md (Photo Quest's product principles, architecture, vocabulary, design system, and "do not build yet" list) so work stays aligned with the spec instead of drifting into generic app patterns. Trigger on any feature request, screen design, schema change, or refactor in this project.
---

# Photo Quest Alignment Check

This project's full product and engineering spec lives in `CLAUDE.md` at the repo root. It is long — do not rely on memory of it. Re-read it (or the relevant sections) whenever this skill fires, since the spec is the source of truth, not this checklist.

## When to run this

- **Before implementing** a feature, screen, bug fix, or schema change: run the "Before" check.
- **Before reporting work as done**: run the "After" check.

Skip only for trivial, non-product-affecting edits (typo fixes, formatting, dependency bumps) where nothing below could plausibly apply.

## Before: align the request

1. Read `CLAUDE.md` (or `grep` the specific section that applies — e.g. §18-19 for schema work, §28-30 for UI/design, §54 for scope).
2. Translate the request into Photo Quest vocabulary. Confirm the request doesn't quietly rename or conflate `Quest`, `Quest Session`, `Memory`, `Photo`, or `Person` (§20, §59).
3. Check the request against the **Do Not Build Yet** list (§54): auth, cloud sync, social features, push notifications, AI recognition, payments, ads. If the request implies one of these, flag it to the user before proceeding rather than silently implementing it.
4. Identify which layers are affected (Presentation / Domain / Data) and confirm the plan respects the dependency direction: Presentation → Domain → Data, never the reverse (§14-17, §62).
5. If it's a screen or UI change, check it against:
   - the design system tokens (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadius` — §27-30) rather than hardcoded values
   - the warm/nostalgic/photobooth tone vs. generic SaaS/dashboard patterns (§2.3, §30)
   - product copy rules — human language, not technical terms in user-facing text (§58)
6. If it's a database change, confirm it uses a migration, not a destructive schema rewrite (§48), and that photo binaries still live on the filesystem, not in SQLite (§5).
7. Confirm the smallest clean solution is being chosen — no speculative abstractions, no new use case for a trivial operation (§53, §26).

If anything conflicts with the spec, surface it to the user in one or two sentences with the specific section, and propose the aligned alternative. Don't silently override the user's request, and don't silently override the spec either — ask when genuinely ambiguous.

## After: verify the change

Before reporting a feature/fix as complete, confirm:

- [ ] No direct DB/filesystem/camera access from Presentation-layer code (§15, §47)
- [ ] No SQL inside screens/ViewModels/widgets/use cases (§47)
- [ ] No arbitrary color/spacing/radius values outside the design system tokens (§27)
- [ ] No new user-facing copy that reads as technical/corporate instead of warm and human (§58)
- [ ] No accidental introduction of anything from the "Do Not Build Yet" list (§54)
- [ ] `flutter analyze` and relevant `flutter test` pass, and `dart format` has been applied (§52)
- [ ] No dead code, stray prints, or commented-out implementations left behind (§52)
- [ ] Repeat-able flows (Quest → Session → Memory) still create new records rather than overwriting prior ones, if touched (§21)

Report any item that couldn't be verified (e.g., no device/emulator available to run `flutter analyze`) rather than assuming it passed.

## How to report findings

Keep it short. State only what's relevant:
- If everything aligns: say so in one line, don't enumerate every passed check.
- If something was adjusted to stay aligned, name the section of CLAUDE.md that drove the change.
- If something conflicts and needs the user's call, ask directly instead of proceeding.
