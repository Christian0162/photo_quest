# Photo Quest backend (Supabase, Free plan)

Photo Quest uses Supabase for **accounts, the profile row, and avatar photos**
only. Quests, memories and photos stay on the phone.

Everything here works on the Supabase **Free** plan.

## What is in this folder

| File | Purpose |
| --- | --- |
| `migrations/20261008000001_profiles.sql` | `profiles` table, Row Level Security, the trigger that creates a profile for each new account. |
| `migrations/20261008000002_avatars_storage.sql` | Private `avatars` bucket and its four Storage policies. |
| `migrations/20261009000001_private_schema_and_hardening.sql` | A `private` schema for internal helpers (not reachable through the API); moves the two helper functions there. |
| `migrations/20261009000002_quests_memories_photos.sql` | `quests`, `quest_shots`, `quest_sessions`, `memories`, `photos`, owner-only RLS, per-column grants. |
| `migrations/20261009000003_memory_sharing.sql` | `memory_shares`, `memory_invites`, invite codes, `create_memory_invite()` / `redeem_memory_invite()`, and viewer read access. |
| `migrations/20261009000004_photos_storage.sql` | Private `photos` bucket and policies; avatars readable between people connected by a share. |
| `migrations/20261009000005_delete_account.sql` | `delete_my_account()`. |
| `migrations/20261009000006_photos_mirrored.sql` | `photos.mirrored`, so a friend sees a front-camera clip the same way you do. |
| `migrations/20261010000001_storage_quota.sql` | A 100 MB online photo allowance per person, enforced on upload, and `my_storage_usage()`. |
| `migrations/20261010000002_quest_participants.sql` | Quest invitations: `quest_participants`, `quest_invites`, `create_quest_invite()`, `redeem_invite()` (one box for memory and quest codes), `respond_to_quest_invitation()`. |
| `migrations/20261010000003_collaborative_photos.sql` | Accepted participants can see a quest's memories and add their own photos (`photos.uploaded_by`). |
| `migrations/20261011000001_friends.sql` | Friend codes on profiles, `friendships`, friend requests, and inviting a friend straight to a quest or memory. |
| `tests/rls_test.sql` | Profiles and avatars: one account cannot read or change another's. Rolls back. |
| `tests/cloud_sharing_test.sql` | Quests, memories, photos, sharing, invites, throttling, files and account deletion. Rolls back. |
| `tests/quest_participation_test.sql` | Quest invitations, crowd limits, who sees what, friends adding photos, the storage allowance. Rolls back. |
| `tests/friends_test.sql` | Friend codes (private), requests, accepting and declining, direct invites, throttling. Rolls back. |
| `tests/local_supabase_stubs.sql` | Stand-ins for Supabase internals so the SQL can be tested on a plain local Postgres. Never run on a real project. |

## One-time setup

1. Create a project at <https://supabase.com> (Free plan).
2. **Run the migrations**, in filename order (oldest first), in *SQL Editor*
   (or `supabase db push` if you use the Supabase CLI). The editor may warn
   that a script creates tables "without RLS"; each script enables RLS itself,
   so *Run and enable RLS* is safe.
3. **Run all four tests** in the SQL Editor. `tests/rls_test.sql` must end with
   `all RLS and storage checks passed`, `tests/cloud_sharing_test.sql` with
   `all cloud, sharing and storage checks passed` and
   `tests/quest_participation_test.sql` with
   `all quest participation and allowance checks passed` and
   `tests/friends_test.sql` with `all friends checks passed`.
4. **Authentication → Sign In / Providers → Email**
   - Enable *Confirm email* (the app expects it).
   - Set the *minimum password length* to **8** (the app checks 8 characters
     with letters and numbers; the server is the real gate).
5. **Authentication → Email Templates** — the app confirms and resets with a
   **6-digit code** instead of a link, so no deep-link setup is needed. Edit
   both templates so the email shows the code:
   - *Confirm sign up*: replace the link with `Your code is {{ .Token }}`
   - *Reset password*: replace the link with `Your code is {{ .Token }}`
6. Copy the project URL and **publishable (anon) key** from *Project Settings →
   API Keys* into `env.json` (copy `env.example.json`; `env.json` is
   gitignored):

   ```bash
   flutter run --dart-define-from-file=env.json
   ```

   `flutter build apk --dart-define-from-file=env.json` for release builds.

## Safe in the app vs. never in the app

| Value | In the Flutter app? |
| --- | --- |
| Project URL | Yes |
| Publishable key (`sb_publishable_…`) or legacy `anon` key | Yes — it is public by design. Security comes from RLS and Storage policies. |
| **Secret key (`sb_secret_…`) / legacy `service_role` key** | **Never.** It bypasses RLS. |
| Database password, JWT secret | **Never.** |

## Sharing a memory (invite codes)

The owner makes a code for one memory (`create_memory_invite`), tells a friend,
and the friend enters it (`redeem_memory_invite`). The friend can then **view**
that memory and its photos, and nothing else.

- Codes are 10 random characters (shown as `ABCDE-FGHJK`), created on the
  server. Only a hash is stored; the plain code is returned once.
- A code lasts 7 days by default (1-30), allows 5 people by default (1-20),
  and can be revoked. A memory can have at most 10 live codes.
- A wrong, expired, revoked, used-up or own code all give the same quiet
  answer (`null`). After 10 wrong tries in an hour an account must wait.
- Viewers can leave; the owner can remove a viewer. Deleting an owner's
  account deletes their memories (and the shares); a viewer deleting theirs
  does not affect the owner.
- Nothing is searchable by email, so nobody can check who has an account.

## Doing a quest together

The owner makes a code for a pair or group quest (`create_quest_invite`) and
sends it. The friend enters it in the same "Got a code?" box (`redeem_invite`
tells the app whether a code is for a memory or a quest). They are then
**invited**, and choose to accept or decline (`respond_to_quest_invitation`).

- A quest holds a fixed number of people, owner included (a pair holds two, a
  group the size chosen or 5). An invited person holds a place until they
  decline or are removed. A full quest turns the next person away.
- An invited person can read the quest and its shots, and see who invited
  them. Only after accepting can they see its sessions and **the memories made
  from it**, and **add their own photos** to those memories. They cannot edit
  or delete the owner's memory or photos, start sessions, or touch any other
  memory.
- Taking part never gives access to the owner's other quests or memories.
- Leaving or being removed just deletes the membership row.
- Friends' photos are stored in the friend's own folder
  (`<their id>/<memory id>/...`) and count against the friend's allowance.
  The memory's owner can delete any photo in their memory, files included.

## Real friends (People)

Every account has a **friend code**: 10 random characters, readable only by its
owner (through `my_friend_code()`; the column has no `SELECT` grant for anyone,
so no policy can ever expose it). To add someone you enter their code. They get
a **request** and choose to accept or decline.

- **Nobody can search for people.** There is no lookup by name or email, and a
  code can't be guessed (50 bits; wrong guesses use the same 10-per-hour limit
  as invite codes, so one box can't be used to probe the other).
- **A request needs a yes.** Until they accept, the sender can only see the
  person's name and photo, and the receiver sees who asked. A declined request
  stays quietly on record: asking again just looks pending, so nobody can be
  pestered. The person who declined can still say yes later by entering the
  other's code. If both ask each other, they become friends straight away.
- **A code can be reset** at any time; the old one stops working at once.
- **Friends can be invited with no code**: `invite_friend_to_quest()` (they
  still accept the quest, and the same size limit applies) and
  `share_memory_with_friend()` (view only). Both refuse anyone who isn't an
  accepted friend, and only the owner can use them.
- Unfriending deletes the friendship row. Things already shared stay shared
  until removed.

## Storage allowance

Each person gets **100 MB** of online photo storage (Free plan storage is 1 GB
for everyone, so keep an eye on how many people that allows). It is enforced by
the upload policy: once a person's files add up to 100 MB they can't upload
more. Storage learns a file's size only after writing it, so a person can go
over by at most one file (10 MB). `my_storage_usage()` reports used and
allowance, and the app shows it in Settings. To free space, remove a memory's
online copy.

## Things the app must do (not enforced by the database)

- **Delete Storage files before rows.** (Deleting a memory's online copy and
  deleting an account both do this in the app.) Deleting a memory or an account removes
  rows by cascade, but Storage files stay behind. Remove everything under
  `<user id>/` in `photos` and `avatars` through the Storage API first, then
  delete the rows or call `delete_my_account()`. Account deletion already
  does this (`ProfileRepository.deleteMyAccount`, files first, then the
  account); deleting a single memory will need the same order.
- **Upload order:** create the `memories` row first, then upload files to
  `<owner id>/<memory id>/<file>`, then insert the `photos` rows. The upload
  policy refuses files for a memory that doesn't exist yet. The app does this
  in `CloudMemoryRepository.backUpMemory`, and only when the owner invites a
  friend to that memory (nothing is uploaded otherwise). It is safe to run
  again, so an interrupted upload resumes.
- **Syncing writes:** clients may only change certain columns (ids, owners and
  `created_at` are immutable). Use insert, then update of the editable
  columns; a PostgREST `upsert` that rewrites every column will be refused.
- **Built-in quests** are stored on each phone with their own random ids, so
  they are uploaded as the owner's own `quests` row along with the first
  memory that used them.
- **Compress before uploading** (the bucket allows 10 MB per file, but Free
  storage is 1 GB in total). Originals stay on the phone. Photos are resized to
  1600 px on the long side as JPEG; a GIF or clip over 10 MB is shared as its
  still poster instead.

## Security model

- `profiles`: each account can **read** and **update** (only `display_name` and
  `avatar_path`) its **own** row. Clients cannot insert or delete rows; the
  `on_auth_user_created` trigger creates the row and deleting an account
  removes it. `anon` has no access at all.
- `avatars` bucket: **private**, 2 MB per file, JPEG/PNG/WebP only. Files live
  at `<user id>/<file>`; insert, update and delete require the first folder to
  equal the caller's own id. Reading is allowed for the owner and for people
  connected to them by a share. The app shows avatars through 1-hour signed
  URLs.
- `photos` bucket: **private**, 10 MB per file, JPEG/PNG/WebP/GIF/MP4. Files
  live at `<owner id>/<memory id>/<file>`. The owner can read and write;
  viewers of a shared memory can read only that memory's files.
- Every table has RLS, one policy per command, and privileges granted per
  command and per column. Child rows must have the same owner as their parent
  (composite foreign keys), so no one can attach data to another person's
  quest or memory.
- Internal helpers live in the `private` schema, which clients cannot reach.
- `profiles.avatar_path` must start with the owner's id, so a profile can
  never point at someone else's file.
- The app never sends a user id: it reads it from the signed-in session.

## Free plan notes and limits

- **Orphaned files:** if a quest owner deletes their account, friends' photos
  in that owner's memories lose their records, but the files sit in the
  friends' own folders and stay until the friend removes them or deletes their
  account. They still count against that friend's 100 MB.

- **Auth emails**: Supabase's built-in email service is meant for trying
  things out and is limited to a **very small number of emails per hour**
  (about 2). Sign-up and reset codes will start failing with "Too many tries
  for now" if you test a lot. Before real users, configure **custom SMTP**
  (*Authentication → Emails → SMTP Settings*). Custom SMTP is allowed on Free,
  but needs an outside email provider (many have free tiers).
- **Inactivity**: Free projects pause after about a week without activity;
  the first request after that fails until you restore the project in the
  dashboard.
- **Storage**: 1 GB total and 50 MB per file on Free; this app caps avatars at
  2 MB. 50,000 monthly active users and 500 MB of database are included.
- **Limits change**: re-check <https://supabase.com/pricing> before launch.

## Testing the SQL without a Supabase project

Needs Docker. This runs the migrations and all three tests on a throwaway
Postgres with Supabase's pieces stubbed:

```bash
docker run -d --name pq-sql -e POSTGRES_PASSWORD=x postgres:16-alpine
cd supabase
docker cp . pq-sql:/sb
for f in tests/local_supabase_stubs.sql \
         migrations/*.sql \
         tests/rls_test.sql \
         tests/cloud_sharing_test.sql \
         tests/quest_participation_test.sql; do
  docker exec pq-sql psql -U postgres -v ON_ERROR_STOP=1 -q -f /sb/$f
done
docker rm -f pq-sql
```
