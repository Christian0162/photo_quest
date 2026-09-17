---
name: photoquest-design-system
description: Use before designing or implementing any screen, widget, or UI component in Photo Quest. Defines the visual design system, interaction patterns, screen hierarchy, component behavior, animation, responsive behavior, accessibility, and UX philosophy. This is the source of truth for UI/UX decisions in this repo — do not fall back to generic Material 3 layouts when a Photo Quest-specific pattern is defined here. Trigger on any screen design, new widget/component, navigation change, copy/microcopy work, or camera/photobooth UI work.
---

# Photo Quest UI/UX Design System

## Purpose

You are working on **Photo Quest**, a social real-life quest and photobooth application.

This skill defines the visual design system, interaction patterns, screen hierarchy, component behavior, animation, responsive behavior, accessibility, and overall UX philosophy for the application.

This skill is the **source of truth for UI/UX decisions**.

Do not create UI based on generic assumptions or generic Material 3 layouts when a Photo Quest-specific pattern is defined here.

---

# 1. Product Experience

Photo Quest is:

> **A social app where people create or discover quests, invite others, complete the quest together in real life, and capture a memorable photobooth picture.**

The core experience is:

```text
DISCOVER A QUEST
       ↓
CREATE / JOIN
       ↓
INVITE PEOPLE
       ↓
DO IT IN REAL LIFE
       ↓
FOLLOW THE PHOTO EXAMPLE
       ↓
TAKE THE PHOTO
       ↓
COMPLETE THE QUEST
       ↓
CREATE A MEMORY
       ↓
LOOK BACK
       ↓
DO IT AGAIN
```

The UI must support this journey.

---

# 2. Emotional Design Direction

The product should feel:

* warm
* playful
* exciting
* social
* personal
* spontaneous
* nostalgic
* memorable
* approachable
* youthful without feeling childish

The user should feel:

> "I want to do this with someone."

and:

> "This looks fun."

and after completion:

> "I'm glad we captured this."

---

# 3. What Photo Quest Should NOT Feel Like

Avoid making Photo Quest look like:

* a productivity app
* a task manager
* an enterprise dashboard
* a generic social media platform
* a dating app
* a generic camera application
* a photo editing application
* a fitness tracker
* a project management application

A quest is **not a task**.

A quest is an invitation to experience something together.

---

# 4. Visual Identity

The visual language combines:

```text
Modern Mobile UI
+
Physical Photobooth
+
Disposable Camera
+
Scrapbook
+
Memory Album
```

The result should feel modern but emotionally warm.

Avoid excessive glassmorphism, excessive gradients, overly futuristic UI, or sterile minimalism.

---

# 5. Design Foundation

Use Flutter Material 3 as the underlying UI foundation.

However:

**Do not make the application look like a default Material 3 application.**

Material 3 provides:

* accessibility
* component foundations
* typography
* theming
* interaction behavior
* adaptive UI

Photo Quest provides the product-specific visual identity.

---

# 6. Color System

Primary palette:

```text
Warm Coral
#FF6B5F

Warm Cream
#FFF9F3

Soft Peach
#FFD9C7

Film Yellow
#FFD166

Warm Charcoal
#252323

Soft Green
#A8C7A1
```

Use colors semantically.

Do not randomly apply colors.

Suggested roles:

```text
Primary action:
Warm Coral

Primary background:
Warm Cream

Secondary surfaces:
Soft Peach

Celebration / highlight:
Film Yellow

Primary text:
Warm Charcoal

Success / positive state:
Soft Green
```

Create centralized theme tokens.

Do not hardcode colors inside individual widgets.

---

# 7. Typography

Primary heading font:

**Outfit**

Body font:

**Inter**

Typography should have a strong hierarchy.

Suggested hierarchy:

```text
Display
32–40

Large Heading
26–32

Heading
22–26

Subheading
18–20

Body
15–17

Caption
12–14
```

Do not use too many font sizes.

Typography should communicate hierarchy before decorative elements do.

---

# 8. Spacing System

Use a 4-point spacing system.

Allowed values:

```text
4
8
12
16
20
24
32
40
48
64
```

Centralize these values as:

```text
AppSpacing
```

Do not randomly use values such as:

```text
13
17
27
31
```

unless there is a strong design reason.

---

# 9. Border Radius

Recommended radius system:

```text
Small
10

Medium
14

Large
18

Extra Large
24

Photo / Hero
24–32
```

Cards should feel soft and approachable.

Avoid excessive pill-shaped containers unless the component is genuinely a tag, status, or compact control.

---

# 10. Shadows and Elevation

Use subtle elevation.

Avoid heavy shadows.

Cards should generally feel like:

> physical memory cards / photo prints

rather than floating enterprise panels.

---

# 11. Global Layout Principles

Every screen should have:

```text
Clear hierarchy
↓
Clear primary action
↓
Enough breathing room
↓
Strong visual focus
```

Avoid filling every available space.

Whitespace is part of the design.

---

# 12. Navigation

Primary navigation:

```text
Home
Quests
Create
Memories
Profile
```

The Create/Start action should have stronger visual emphasis.

Depending on the final implementation, the central action can be represented as:

```text
+
Make a Quest
```

or:

```text
Camera / Quest action
```

The exact navigation implementation can evolve, but the primary quest action must remain easy to discover.

---

# 13. Home Screen

The Home screen should answer:

> **What can I do today?**

Recommended hierarchy:

```text
Greeting

Today's Quest

Invitations

Your Active Quests

Recent Memories
```

Do not turn Home into a statistics dashboard.

---

# 14. Today's Quest

Today's Quest is a major hero experience.

Example:

```text
┌───────────────────────────────┐
│ TODAY'S QUEST                 │
│                               │
│ Recreate Your Old Photo       │
│                               │
│ Find an old photo and         │
│ recreate it together.         │
│                               │
│ ┌───────────────────────────┐ │
│ │                           │ │
│ │      EXAMPLE PHOTO        │ │
│ │                           │ │
│ └───────────────────────────┘ │
│                               │
│ 👤 👤                         │
│                               │
│        Start Quest            │
└───────────────────────────────┘
```

The example image should be visually prominent.

---

# 15. Quest Cards

Create a reusable:

```text
PQQuestCard
```

A quest card can contain:

* quest image/example
* title
* short description
* creator
* participant avatars
* participant count
* date
* status
* CTA

Example:

```text
[Example Image]

Weekend Adventure

Take a photo somewhere
you've never been before.

👤 👤 👤 +2

Today

Start Quest
```

Avoid excessive metadata.

---

# 16. Quest Detail Screen

Quest detail should answer:

1. What are we doing?
2. Who is participating?
3. What pictures do we need?
4. When are we doing it?
5. How do I start?

Structure:

```text
Hero image

Quest title

Description

Created by

Participants

Quest Shots

Quest information

Primary CTA
```

---

# 17. Create Quest UX

Creating a quest should feel creative.

Do not present a giant form.

Use a guided flow.

```text
Step 1
What should we do?

        ↓

Step 2
Describe it

        ↓

Step 3
Who should join?

        ↓

Step 4
What pictures should we take?

        ↓

Step 5
Add example photos

        ↓

Step 6
Review

        ↓

Create Quest
```

Each step should have one clear purpose.

---

# 18. Create Quest — Step 1

Question:

> **What should we do?**

Example input:

```text
Recreate our childhood photo
```

Provide suggestions:

```text
Birthday
Family
Friends
Date
Adventure
Funny
Memory
```

Suggestions are optional helpers, not mandatory categories.

---

# 19. Create Quest — Description

Question:

> **What's the idea?**

Use a friendly text field.

Example:

> Find an old childhood photo and recreate the pose together.

The description should explain the real-life activity.

---

# 20. People Selection

Question:

> **Who should join?**

Show users visually.

```text
👤 Christian
Christian

👤 Sarah
Sarah

👤 Mom
Mom

👤 John
John
```

Selected users should have a strong but simple selection state.

Example:

```text
✓
```

or an outlined avatar.

---

# 21. Group Quest

For family/group quests:

```text
Family Christmas Photo

5 people

👤 👤 👤 👤 👤
```

Clearly communicate the group size.

Do not make group quests look like five separate invitations.

It is:

> **One shared quest.**

---

# 22. Invitation UI

Invitations should feel personal.

Example:

```text
Sarah invited you

Weekend Adventure

"Let's make a memory together."

👤 👤

[Accept Quest]

Decline
```

The Accept button should be visually dominant.

---

# 23. Active Quest Screen

Once a user starts a quest, transition the UI from planning to doing.

The interface should become focused.

Show:

```text
Quest title

Progress

Current instruction

Example

Start Camera
```

Avoid unrelated navigation or information.

---

# 24. Photobooth Experience

The photobooth is one of the most important screens in Photo Quest.

The camera preview should dominate the screen.

Basic hierarchy:

```text
Top:
Close
Quest progress

Center:
Camera preview
Example / instruction

Bottom:
Capture button
Camera controls
```

---

# 25. Camera Example

The current shot must have a visual example.

Example:

```text
Shot 2 of 3

Make the funniest face!

        ┌─────────────┐
        │             │
        │   EXAMPLE   │
        │             │
        └─────────────┘

    ┌─────────────────┐
    │                 │
    │ CAMERA PREVIEW  │
    │                 │
    └─────────────────┘

             ●
```

The example should help users immediately understand what to do.

---

# 26. Example Overlay

For pose-based quests, an example may optionally appear as a subtle overlay.

Do not obstruct the user's camera preview.

The example should never become visually stronger than the real people in the camera.

---

# 27. Photobooth Instructions

Instructions should be:

* short
* playful
* actionable
* easy to understand

Good:

> "Everyone squeeze together!"

Good:

> "Give your funniest face!"

Good:

> "Copy the pose!"

Avoid:

> "Please position all participants approximately 50 centimeters apart from one another."

---

# 28. Countdown

Use:

```text
3
2
1
```

with a strong but simple animation.

The countdown should create anticipation.

---

# 29. Capture Interaction

Capture button:

```text
PQCaptureButton
```

should feel physical.

Possible interaction:

```text
Press
↓
Scale down slightly
↓
Shutter animation
↓
Photo captured
```

Provide immediate feedback.

---

# 30. Photo Review

After capturing:

```text
Photo Preview

Looks good?

[Retake]

[Keep Photo]
```

Keep Photo should be the primary action.

Retake should remain easy to access.

---

# 31. Quest Progress

For multiple shots:

```text
● ● ○
```

or:

```text
Shot 2 of 3
```

Use both when helpful.

The user should always understand progress.

---

# 32. Quest Completion

Quest completion should feel special.

Example:

```text
✨ QUEST COMPLETE

You made a memory together.

[Large Photo]

Christian · Sarah · Mom · Dad

September 17, 2026

[Keep This Memory]
```

Use subtle celebration animation.

Do not turn it into an excessive game victory screen.

---

# 33. Memory Detail

Memory detail should feel like opening a physical photo album.

Hierarchy:

```text
Large photo

Quest title

Date

Participants

Description

Additional photos

Repeat Quest
```

The photo should dominate.

---

# 34. Photo Strip

The photobooth result can be represented as a physical photo strip.

Example:

```text
┌───────────────┐
│               │
│    PHOTO 1    │
│               │
├───────────────┤
│    PHOTO 2    │
├───────────────┤
│    PHOTO 3    │
│               │
│  PHOTO QUEST  │
│  Sep 17 2026  │
└───────────────┘
```

The strip should feel collectible.

---

# 35. Memories Screen

Memories should feel like a personal visual collection.

Possible layouts:

```text
Timeline
```

or:

```text
Photo grid
```

Use date grouping where useful.

Example:

```text
September 2026

[Photo] [Photo]

August 2026

[Photo] [Photo] [Photo]
```

---

# 36. Repeated Quest Memories

When the same quest is repeated, visually connect the memories.

Example:

```text
Family Christmas Photo

2024
[Photo]

2025
[Photo]

2026
[Photo]
```

This is one of the emotional differentiators of the product.

---

# 37. Profile

Profile should focus on:

```text
Profile photo
Username
Display name

Quests created
Quests completed
Memories
People
```

Keep statistics secondary.

The profile should not become a social-media profile.

---

# 38. User Identity

Username should be visually recognizable.

Example:

```text
Christian
@christian
```

Use the unique internal user ID for relationships, not username.

---

# 39. Status Design

Use clear semantic states.

Examples:

```text
Invited
Accepted
Active
Completed
Declined
```

Avoid using color alone to communicate status.

---

# 40. Empty States

Empty states should encourage action.

Bad:

> No quests.

Better:

> **No quests yet.**

> Create something fun and invite someone to join you.

```text
[Create a Quest]
```

---

# 41. Loading States

Prefer skeletons or contextual loading states over blank screens.

Camera loading should communicate:

> Preparing your photobooth...

Do not display generic loading indicators everywhere.

---

# 42. Error States

Errors should explain:

1. What happened.
2. What the user can do.

Example:

> We couldn't save that photo.

> Try again.

```text
[Retry]
```

Avoid technical error messages.

---

# 43. Permission UX

Camera permission should be requested in context.

Before requesting:

> Photo Quest needs your camera to capture the memory for this quest.

Then request permission.

Do not request camera access immediately on first launch unless required.

---

# 44. Bottom Sheets

Use bottom sheets for:

* participant selection
* quest options
* photo actions
* filters
* confirmation actions

Do not use bottom sheets for every interaction.

---

# 45. Dialogs

Use dialogs only when an action needs explicit confirmation.

Examples:

```text
Leave Quest?

Your progress will be lost.

[Stay] [Leave]
```

or:

```text
Delete Memory?

This cannot be undone.

[Cancel] [Delete]
```

Avoid unnecessary confirmation dialogs.

---

# 46. Buttons

Primary:

```text
PQButton
```

Use for:

* Start Quest
* Create Quest
* Accept Quest
* Capture
* Keep Photo
* Repeat Quest

Secondary:

```text
PQSecondaryButton
```

Use for:

* Cancel
* Retake
* Decline
* Back

---

# 47. Icons

Use a consistent icon library.

Icons should communicate meaning clearly.

Do not use icons merely for decoration.

Avoid mixing many unrelated icon styles.

---

# 48. Animation System

Animation should be:

* quick
* natural
* purposeful

Suggested durations:

```text
Micro interaction
100–180ms

Small transition
180–250ms

Normal transition
250–350ms

Emotional reveal
350–600ms
```

Avoid excessive animation.

---

# 49. Important Animations

Recommended animations:

### Quest Start

Card → camera transition.

### Countdown

Scale/fade numbers.

### Capture

Shutter effect.

### Photo Accepted

Photo → progress transition.

### Quest Complete

Photo strip reveal.

### Invitation Accepted

Invitation → active quest transition.

---

# 50. Reduced Motion

Respect system reduced-motion preferences.

If reduced motion is enabled:

* reduce scale animations
* remove unnecessary movement
* reduce transition distance
* retain essential state feedback

---

# 51. Responsive Design

Design for common mobile sizes first.

Do not assume every device has the same aspect ratio.

Pay special attention to:

* camera cutouts
* safe areas
* small phones
* large phones
* landscape camera behavior

Use:

```text
SafeArea
MediaQuery
LayoutBuilder
```

when appropriate.

---

# 52. Touch Targets

Interactive controls should have sufficiently large touch areas.

Important controls such as:

* Capture
* Back
* Camera switch
* Flash
* Accept
* Retake

must be easy to tap.

Do not sacrifice usability for visual compactness.

---

# 53. Accessibility

Support:

* scalable text
* semantic labels
* sufficient contrast
* keyboard navigation where applicable
* screen readers
* large touch targets
* meaningful button labels
* reduced motion

Do not communicate important information using color alone.

---

# 54. Component Architecture

Create reusable Photo Quest components.

Examples:

```text
PQButton
PQSecondaryButton
PQIconButton

PQCard
PQQuestCard
PQTodayQuestCard
PQInvitationCard
PQMemoryCard

PQPersonAvatar
PQParticipantRow
PQParticipantStack

PQSectionHeader

PQQuestProgress
PQQuestShotCard

PQCameraExample
PQCameraInstruction
PQCaptureButton
PQCountdown

PQPhotoStrip
PQPhotoGrid

PQEmptyState
PQLoadingState
PQErrorState

PQBottomSheet
PQConfirmationDialog
```

---

# 55. Component Rules

Before creating a new component:

1. Search for an existing component.
2. Determine whether it can be reused.
3. Extend it if appropriate.
4. Only create a new component when there is a meaningful reusable pattern.

Do not create multiple components that solve the same problem.

---

# 56. Design Tokens

Create centralized tokens for:

```text
AppColors
AppTypography
AppSpacing
AppRadius
AppElevation
AppMotion
AppIconSizes
```

Components should consume these tokens.

Do not place arbitrary design values inside screen widgets.

---

# 57. Screen Hierarchy

Every screen should have one primary purpose.

For example:

```text
Home
→ Discover / start

Quest Detail
→ Understand / join

Create Quest
→ Create

People
→ Select participants

Photobooth
→ Capture

Completion
→ Celebrate / preserve

Memory
→ Remember / revisit
```

Avoid screens that try to do everything.

---

# 58. Primary Action Rule

Every important screen should have an obvious primary action.

Examples:

```text
Home
→ Start Quest

Quest Detail
→ Join / Start Quest

Create Quest
→ Continue

People Selection
→ Continue

Photobooth
→ Capture

Review
→ Keep Photo

Completion
→ Keep Memory

Memory
→ Repeat Quest
```

---

# 59. Information Hierarchy

Use this general priority:

```text
1. What are we doing?
2. Who are we doing it with?
3. What should the picture look like?
4. What do I need to do next?
5. Supporting information
6. Decoration
```

Never allow secondary information to overpower the primary action.

---

# 60. Social UX Principle

Always make participation understandable.

Users should easily see:

```text
Who created this?
Who is invited?
Who accepted?
Who is participating?
Who completed?
```

Avoid ambiguous participant states.

---

# 61. Real-Life UX Principle

The UI should encourage users to leave the screen and perform the quest.

For example:

> "Meet Sarah at the park."

is better than creating ten in-app interactions before the user can start.

The app facilitates the moment.

It does not replace the moment.

---

# 62. No Social Media Patterns

Do not implement these as default UI patterns:

* likes
* follower counts
* infinite feed
* trending quests
* engagement scores
* public popularity
* comment sections

Photo Quest is social because **people participate together**, not because people consume a public feed.

---

# 63. Copywriting Style

Use short, human language.

Prefer:

> Let's make a memory.

over:

> Initiate photobooth quest.

Prefer:

> Who should join?

over:

> Select quest participants.

Prefer:

> Take the shot!

over:

> Capture required image.

The interface should sound like a friend inviting you to do something.

---

# 64. Microcopy

Examples:

```text
Today's Quest

Let's make a memory.

Who should join?

Invite your people.

Ready?

Let's do it.

3... 2... 1...

Nice one!

Take another?

Keep this one.

Quest Complete!

You made this moment together.

Do this again.
```

---

# 65. Design Anti-Patterns

Never:

* overcrowd the home screen
* use giant amounts of text
* make every card look identical
* overuse rounded containers
* overuse gradients
* overuse animations
* make every action a button
* create unnecessary dashboards
* hide important actions
* make the camera screen complicated
* use technical language
* make quests feel like chores
* turn memories into analytics

---

# 66. Implementation Rules for Claude

Before implementing UI:

1. Read this skill.
2. Inspect the existing screen.
3. Inspect existing components.
4. Inspect existing design tokens.
5. Reuse established patterns.
6. Do not introduce conflicting styles.
7. Keep the screen hierarchy clear.
8. Consider loading, empty, error, and permission states.
9. Test on small mobile screens.
10. Test accessibility.
11. Keep interactions understandable without explanation.
12. Do not redesign unrelated screens unless requested.

---

# 67. When Requirements Are Ambiguous

When a requirement is unclear:

1. Preserve the established Photo Quest visual language.
2. Prefer the simpler interaction.
3. Prefer real-life activity over in-app interaction.
4. Prefer people and quest context over metadata.
5. Prefer photography over decoration.
6. Prefer reusable components.
7. Do not invent major product behavior.

If a decision affects product behavior rather than UI implementation, inspect the Product/Quest skill (`photoquest-alignment`) before deciding.

---

# 68. Final Design Principle

Every important Photo Quest screen should reinforce:

```text
PEOPLE
   +
QUEST
   +
REAL LIFE
   +
PHOTO
   =
MEMORY
```

The UI exists to make that experience feel effortless, exciting, and memorable.

The ultimate goal is not for users to spend more time inside Photo Quest.

The goal is for Photo Quest to help users create moments they will remember after they leave the app.
