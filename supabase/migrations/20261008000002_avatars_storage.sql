-- Photo Quest: private avatar storage.
--
-- One bucket, "avatars", and it is PRIVATE: nothing is readable without a
-- signed-in session. The app shows avatars through short-lived signed URLs.
-- Photos and memories are deliberately not stored in Supabase, so there is no
-- "photos" bucket.
--
-- Files live under  <user id>/<file>  and every policy requires the first
-- folder to be the caller's own id, so ownership comes from the path the
-- server checks, not from a filename or anything the client claims.
--
--   SELECT  own folder only
--   INSERT  own folder only
--   UPDATE  own folder only (and it must stay in the own folder)
--   DELETE  own folder only
--
-- Free plan: 1 GB of storage and 50 MB per file overall; this bucket caps
-- files at 2 MB and accepts only JPEG, PNG or WebP.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'avatars',
  'avatars',
  false,
  2097152,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "avatars_select_own"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars_insert_own"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars_update_own"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars_delete_own"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
