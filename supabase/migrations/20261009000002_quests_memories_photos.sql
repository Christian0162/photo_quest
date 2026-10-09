-- Photo Quest: cloud copies of quests, sessions, memories and photos.
--
-- These mirror the on-device tables so a person's memories can be backed up
-- and later shared. Every row belongs to exactly one owner (owner_id), and in
-- this migration only the owner can touch it. Sharing is added separately in
-- the next migration, so each step is secure on its own.
--
-- Design rules used throughout:
--   * uuid primary keys with a default, but the app may supply its own id so
--     it can create records offline and sync them later;
--   * timestamptz everywhere; updated_at is maintained by a trigger;
--   * text enums are CHECK constraints, with length limits on free text;
--   * every foreign key has an index (Postgres does not add one);
--   * a child row's owner_id must equal its parent's owner_id. That is
--     enforced by composite foreign keys, so nobody can attach their rows to
--     another person's quest or memory, even if they know its id;
--   * RLS is on for every table, one policy per command, all `to
--     authenticated`, using (select auth.uid()) so it is evaluated once;
--   * privileges start from nothing (revoke all) and are granted per command,
--     and for UPDATE per column, so ids, owners and created_at can never be
--     rewritten by a client.
--
-- What deliberately stays on the device: people (local contacts), quest
-- participants, example images and cover image paths, keepsake designs,
-- and the original full-size photos.
--
-- Built-in quest templates have no owner on the device. When one is first
-- used, the app uploads it as the owner's own quest, so nothing here needs a
-- "template" concept.

-- ============================================================ quests

create table public.quests (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 100),
  description text check (description is null or char_length(description) <= 500),
  category text not null check (char_length(category) between 1 and 50),
  type text not null check (type in ('solo', 'pair', 'group')),
  status text not null default 'draft'
    check (status in ('draft', 'published', 'invited', 'active', 'completed')),
  max_participants integer
    check (max_participants is null or max_participants between 1 and 20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- Lets child tables prove they have the same owner.
  unique (id, owner_id)
);

create index quests_owner_id_idx on public.quests (owner_id);

-- ============================================================ quest_shots

create table public.quest_shots (
  id uuid primary key default gen_random_uuid(),
  quest_id uuid not null,
  owner_id uuid not null,
  position integer not null check (position >= 0),
  instruction text not null check (char_length(instruction) between 1 and 200),
  shot_type text not null check (char_length(shot_type) between 1 and 30),
  required boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (quest_id, owner_id)
    references public.quests (id, owner_id) on delete cascade,
  -- Deferred so shots can be reordered inside one transaction.
  constraint quest_shots_quest_position_key
    unique (quest_id, position) deferrable initially deferred,
  unique (id, owner_id)
);

create index quest_shots_owner_id_idx on public.quest_shots (owner_id);

-- ============================================================ quest_sessions

create table public.quest_sessions (
  id uuid primary key default gen_random_uuid(),
  quest_id uuid not null,
  owner_id uuid not null,
  started_at timestamptz not null,
  completed_at timestamptz,
  status text not null default 'in_progress'
    check (status in ('in_progress', 'completed', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (completed_at is null or completed_at >= started_at),
  foreign key (quest_id, owner_id)
    references public.quests (id, owner_id) on delete cascade,
  unique (id, owner_id)
);

create index quest_sessions_quest_id_idx on public.quest_sessions (quest_id);
create index quest_sessions_owner_id_idx on public.quest_sessions (owner_id);

-- ============================================================ memories

create table public.memories (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  quest_session_id uuid,
  title text not null check (char_length(title) between 1 and 100),
  note text check (note is null or char_length(note) <= 2000),
  captured_at timestamptz not null,
  cover_photo_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- A memory survives its session being deleted.
  foreign key (quest_session_id, owner_id)
    references public.quest_sessions (id, owner_id)
    on delete set null (quest_session_id),
  unique (id, owner_id)
);

create index memories_owner_id_idx on public.memories (owner_id);
create index memories_quest_session_id_idx on public.memories (quest_session_id);

-- ============================================================ photos

create table public.photos (
  id uuid primary key default gen_random_uuid(),
  memory_id uuid not null,
  owner_id uuid not null,
  shot_id uuid,
  -- Compressed copies in the private `photos` bucket, always under
  -- <owner id>/<memory id>/. The full-size original stays on the device.
  storage_path text not null
    check (storage_path like owner_id::text || '/' || memory_id::text || '/%'),
  thumbnail_path text
    check (
      thumbnail_path is null
      or thumbnail_path like owner_id::text || '/' || memory_id::text || '/%'
    ),
  position integer not null check (position >= 0),
  kind text not null default 'photo'
    check (kind in ('photo', 'gif', 'boomerang', 'video')),
  width integer check (width is null or width > 0),
  height integer check (height is null or height > 0),
  captured_at timestamptz not null,
  created_at timestamptz not null default now(),
  foreign key (memory_id, owner_id)
    references public.memories (id, owner_id) on delete cascade,
  -- The shot must belong to the same owner; deleting it keeps the photo.
  foreign key (shot_id, owner_id)
    references public.quest_shots (id, owner_id)
    on delete set null (shot_id),
  -- Lets a memory prove its cover photo belongs to it.
  unique (id, memory_id),
  constraint photos_memory_position_key
    unique (memory_id, position) deferrable initially deferred
);

create index photos_owner_id_idx on public.photos (owner_id);
create index photos_shot_id_idx on public.photos (shot_id);

-- The cover must be one of the memory's own photos.
alter table public.memories
  add constraint memories_cover_photo_fkey
  foreign key (cover_photo_id, id)
  references public.photos (id, memory_id)
  on delete set null (cover_photo_id);

-- ============================================================ updated_at

create trigger quests_set_updated_at
  before update on public.quests
  for each row execute function private.set_updated_at();
create trigger quest_shots_set_updated_at
  before update on public.quest_shots
  for each row execute function private.set_updated_at();
create trigger quest_sessions_set_updated_at
  before update on public.quest_sessions
  for each row execute function private.set_updated_at();
create trigger memories_set_updated_at
  before update on public.memories
  for each row execute function private.set_updated_at();

-- ============================================================ privileges

revoke all on public.quests, public.quest_shots, public.quest_sessions,
  public.memories, public.photos from anon, authenticated;

grant select, delete on public.quests, public.quest_shots,
  public.quest_sessions, public.memories, public.photos to authenticated;

grant insert (id, owner_id, title, description, category, type, status, max_participants)
  on public.quests to authenticated;
grant update (title, description, category, type, status, max_participants)
  on public.quests to authenticated;

grant insert (id, quest_id, owner_id, position, instruction, shot_type, required)
  on public.quest_shots to authenticated;
grant update (position, instruction, shot_type, required)
  on public.quest_shots to authenticated;

grant insert (id, quest_id, owner_id, started_at, completed_at, status)
  on public.quest_sessions to authenticated;
grant update (completed_at, status)
  on public.quest_sessions to authenticated;

grant insert (id, owner_id, quest_session_id, title, note, captured_at)
  on public.memories to authenticated;
grant update (title, note, cover_photo_id)
  on public.memories to authenticated;

grant insert (id, memory_id, owner_id, shot_id, storage_path, thumbnail_path,
              position, kind, width, height, captured_at)
  on public.photos to authenticated;
grant update (position)
  on public.photos to authenticated;

-- ============================================================ row level security
-- Owner only, for every command. Who may SELECT / INSERT / UPDATE / DELETE:
-- the owner, nobody else, anonymous never.

alter table public.quests enable row level security;
alter table public.quest_shots enable row level security;
alter table public.quest_sessions enable row level security;
alter table public.memories enable row level security;
alter table public.photos enable row level security;

create policy "quests_select_own" on public.quests
  for select to authenticated using ((select auth.uid()) = owner_id);
create policy "quests_insert_own" on public.quests
  for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "quests_update_own" on public.quests
  for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);
create policy "quests_delete_own" on public.quests
  for delete to authenticated using ((select auth.uid()) = owner_id);

create policy "quest_shots_select_own" on public.quest_shots
  for select to authenticated using ((select auth.uid()) = owner_id);
create policy "quest_shots_insert_own" on public.quest_shots
  for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "quest_shots_update_own" on public.quest_shots
  for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);
create policy "quest_shots_delete_own" on public.quest_shots
  for delete to authenticated using ((select auth.uid()) = owner_id);

create policy "quest_sessions_select_own" on public.quest_sessions
  for select to authenticated using ((select auth.uid()) = owner_id);
create policy "quest_sessions_insert_own" on public.quest_sessions
  for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "quest_sessions_update_own" on public.quest_sessions
  for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);
create policy "quest_sessions_delete_own" on public.quest_sessions
  for delete to authenticated using ((select auth.uid()) = owner_id);

create policy "memories_select_own" on public.memories
  for select to authenticated using ((select auth.uid()) = owner_id);
create policy "memories_insert_own" on public.memories
  for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "memories_update_own" on public.memories
  for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);
create policy "memories_delete_own" on public.memories
  for delete to authenticated using ((select auth.uid()) = owner_id);

create policy "photos_select_own" on public.photos
  for select to authenticated using ((select auth.uid()) = owner_id);
create policy "photos_insert_own" on public.photos
  for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "photos_update_own" on public.photos
  for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);
create policy "photos_delete_own" on public.photos
  for delete to authenticated using ((select auth.uid()) = owner_id);

-- ============================================================ documentation

comment on table public.quests is 'A quest an account owns (solo, pair or group).';
comment on table public.quest_shots is 'One instruction / photo slot inside a quest.';
comment on table public.quest_sessions is 'One attempt at a quest. A repeat is a new row, never an overwrite.';
comment on table public.memories is 'The memory a finished session produced. Owned by one account.';
comment on table public.photos is 'A compressed photo/GIF/clip of a memory. Original files stay on the device.';
comment on column public.photos.storage_path is 'Path in the private photos bucket: <owner id>/<memory id>/<file>.';
