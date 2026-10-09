-- Photo Quest: private storage for memory photos.
--
-- The `photos` bucket holds compressed copies of a memory's photos, GIFs and
-- clips (full-size originals stay on the device, which also keeps us inside
-- the Free plan's 1 GB). It is PRIVATE: files are read through short-lived
-- signed URLs, never public links.
--
-- Files live at  <owner id>/<memory id>/<file>.
--
--   SELECT  the owner, and anyone the memory was shared with
--   INSERT  the owner only, into a memory they own
--   UPDATE  the owner only
--   DELETE  the owner only
--
-- Free plan: 10 MB per file here (the plan allows up to 50 MB).
--
-- Deleting a memory or an account removes its rows, but Storage files are not
-- removed by database cascades. The app must delete the files through the
-- Storage API first (the delete policy below allows it), then delete the rows.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'photos',
  'photos',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'video/mp4']
)
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "photos_files_select_own_or_shared"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'photos'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or exists (
        select 1 from public.memory_shares s
        where s.viewer_id = (select auth.uid())
          and s.owner_id::text = (storage.foldername(name))[1]
          and s.memory_id::text = (storage.foldername(name))[2]
      )
    )
  );

-- Exactly <owner>/<memory>/<file>, and the memory must already exist and be
-- the caller's, so nobody can park files in made-up folders.
create policy "photos_files_insert_own"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and array_length(storage.foldername(name), 1) = 2
    and exists (
      select 1 from public.memories m
      where m.owner_id = (select auth.uid())
        and m.id::text = (storage.foldername(name))[2]
    )
  );

create policy "photos_files_update_own"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and array_length(storage.foldername(name), 1) = 2
  );

create policy "photos_files_delete_own"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- Avatars: people on either end of a share can see each other's avatar, so a
-- shared memory can show who it came from. Replaces the owner-only read.
drop policy "avatars_select_own" on storage.objects;
create policy "avatars_select_own_or_connected"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'avatars'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or exists (
        select 1 from public.memory_shares s
        where (s.owner_id::text = (storage.foldername(name))[1]
               and s.viewer_id = (select auth.uid()))
           or (s.viewer_id::text = (storage.foldername(name))[1]
               and s.owner_id = (select auth.uid()))
      )
    )
  );
