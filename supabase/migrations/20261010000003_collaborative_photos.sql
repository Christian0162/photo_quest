-- Photo Quest: friends adding their own photos to a shared quest memory.
--
-- A quest memory is made by its owner. Accepted participants of that quest can
-- see the memory and add their OWN photos to it; they can't edit it, delete
-- the owner's photos, or touch any other memory. People who were only given a
-- memory code can still just view.
--
-- Who may do what (photos):
--   SELECT  owner, accepted participants of the memory's quest, code viewers
--   INSERT  the owner or an accepted participant, as themselves (uploaded_by)
--   UPDATE  the owner (position only)
--   DELETE  the owner (any photo) or the person who added it (their own)
--
-- Files live at  <uploader id>/<memory id>/<file>. A photo row says who added
-- it (uploaded_by) and keeps owner_id = the memory's owner, so the composite
-- keys still tie every photo to its memory's owner. The path in a row must sit
-- in the uploader's own folder.
--
-- Storage (photos bucket):
--   SELECT  your own folder, or any file of a memory you can see
--   INSERT  your own folder, into a memory you may add to, within your allowance
--   UPDATE  your own folder
--   DELETE  your own folder, or any file of a memory you own (so removing a
--           memory can also remove friends' files)
--
-- Photo order: several people add photos, so two can pick the same position.
-- Position is now only a hint for ordering, not a unique key.

-- ============================================================ photos: who added it

alter table public.photos add column uploaded_by uuid;
update public.photos set uploaded_by = owner_id;
alter table public.photos alter column uploaded_by set not null;
alter table public.photos
  add constraint photos_uploaded_by_fkey
  foreign key (uploaded_by) references public.profiles (id) on delete cascade;

create index photos_uploaded_by_idx on public.photos (uploaded_by);

-- The two path checks were created without names, so find them by what they
-- check (they mention the path column and owner_id) instead of guessing.
do $$
declare
  old_check record;
begin
  for old_check in
    select c.conname
    from pg_constraint c
    where c.conrelid = 'public.photos'::regclass
      and c.contype = 'c'
      and (pg_get_constraintdef(c.oid) like '%storage_path%owner_id%'
           or pg_get_constraintdef(c.oid) like '%thumbnail_path%owner_id%')
  loop
    execute format('alter table public.photos drop constraint %I', old_check.conname);
  end loop;
end $$;
alter table public.photos
  add constraint photos_storage_path_check
  check (storage_path like uploaded_by::text || '/' || memory_id::text || '/%');
alter table public.photos
  add constraint photos_thumbnail_path_check
  check (
    thumbnail_path is null
    or thumbnail_path like uploaded_by::text || '/' || memory_id::text || '/%'
  );

alter table public.photos drop constraint photos_memory_position_key;

grant insert (uploaded_by) on public.photos to authenticated;

-- ============================================================ helpers

-- Can the caller see this memory: owner, a friend given its code, or an
-- accepted participant of the quest it came from.
create function private.can_view_memory(p_memory uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memories m
    where m.id = p_memory
      and (
        m.owner_id = (select auth.uid())
        or exists (
          select 1 from public.memory_shares s
          where s.memory_id = m.id and s.viewer_id = (select auth.uid())
        )
        or exists (
          select 1
          from public.quest_sessions qs
          join public.quest_participants p on p.quest_id = qs.quest_id
          where qs.id = m.quest_session_id
            and p.user_id = (select auth.uid())
            and p.status = 'accepted'
        )
      )
  );
$$;

-- May the caller add photos to this memory: its owner, or an accepted
-- participant of the quest it came from. Code viewers may not.
create function private.can_add_photos(p_memory uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memories m
    where m.id = p_memory
      and (
        m.owner_id = (select auth.uid())
        or exists (
          select 1
          from public.quest_sessions qs
          join public.quest_participants p on p.quest_id = qs.quest_id
          where qs.id = m.quest_session_id
            and p.user_id = (select auth.uid())
            and p.status = 'accepted'
        )
      )
  );
$$;

-- Storage paths are <uploader>/<memory>/<file>. These read the memory id out of
-- a path, only turning it into a uuid when it really looks like one.
create function private.memory_of_path(p_name text)
returns uuid
language sql
immutable
set search_path = ''
as $$
  select case
    when (storage.foldername(p_name))[2]
         ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    then ((storage.foldername(p_name))[2])::uuid
    else null
  end;
$$;

create function private.can_view_memory_path(p_name text)
returns boolean
language sql
stable
set search_path = ''
as $$
  select coalesce(private.can_view_memory(private.memory_of_path(p_name)), false);
$$;

create function private.can_add_photos_path(p_name text)
returns boolean
language sql
stable
set search_path = ''
as $$
  select coalesce(private.can_add_photos(private.memory_of_path(p_name)), false);
$$;

create function private.owns_memory_path(p_name text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memories m
    where m.id = private.memory_of_path(p_name)
      and m.owner_id = (select auth.uid())
  );
$$;

revoke execute on function
  private.can_view_memory(uuid),
  private.can_add_photos(uuid),
  private.memory_of_path(text),
  private.can_view_memory_path(text),
  private.can_add_photos_path(text),
  private.owns_memory_path(text)
  from public, anon;
grant execute on function
  private.can_view_memory(uuid),
  private.can_add_photos(uuid),
  private.memory_of_path(text),
  private.can_view_memory_path(text),
  private.can_add_photos_path(text),
  private.owns_memory_path(text)
  to authenticated;

-- ============================================================ row level security

drop policy "memories_select_own_or_shared" on public.memories;
create policy "memories_select_visible" on public.memories
  for select to authenticated
  using (private.can_view_memory(id));

drop policy "photos_select_own_or_shared" on public.photos;
create policy "photos_select_visible" on public.photos
  for select to authenticated
  using (private.can_view_memory(memory_id));

drop policy "photos_insert_own" on public.photos;
create policy "photos_insert_by_member" on public.photos
  for insert to authenticated
  with check (
    uploaded_by = (select auth.uid())
    and private.can_add_photos(memory_id)
  );

drop policy "photos_delete_own" on public.photos;
create policy "photos_delete_owner_or_uploader" on public.photos
  for delete to authenticated
  using (
    (select auth.uid()) = owner_id
    or (select auth.uid()) = uploaded_by
  );

-- ============================================================ storage policies

drop policy "photos_files_select_own_or_shared" on storage.objects;
create policy "photos_files_select_visible"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'photos'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or private.can_view_memory_path(name)
    )
  );

drop policy "photos_files_insert_own" on storage.objects;
create policy "photos_files_insert_by_member"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and array_length(storage.foldername(name), 1) = 2
    and private.can_add_photos_path(name)
    and private.storage_bytes_used((select auth.uid())) < private.photos_quota_bytes()
  );

drop policy "photos_files_delete_own" on storage.objects;
create policy "photos_files_delete_own_or_memory_owner"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'photos'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or private.owns_memory_path(name)
    )
  );

comment on column public.photos.uploaded_by is
  'Who added this photo: the memory''s owner or an accepted participant. Files sit in their folder.';
