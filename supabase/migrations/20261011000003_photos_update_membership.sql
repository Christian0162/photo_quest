-- Why: photos_files_update_own only checked the uploader's folder, so a friend
-- who left (or was removed from) a quest could still replace the files they
-- had added, and those files stay visible in the owner's memory. Updates now
-- need the same membership check as uploads (private.can_add_photos_path).

drop policy "photos_files_update_own" on storage.objects;
create policy "photos_files_update_by_member"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and private.can_add_photos_path(name)
  )
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and array_length(storage.foldername(name), 1) = 2
    and private.can_add_photos_path(name)
  );
