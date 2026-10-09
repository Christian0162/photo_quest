-- Why: the 100 MB allowance was only checked when a file was first uploaded.
-- Someone could stay under it with many small files, then replace each one with
-- a file up to 10 MB and go far past it. An update that makes a file bigger now
-- has to fit in the allowance too: the person's total, with the old size taken
-- out and the new size put in, must stay within it. Replacing a file with the
-- same size or a smaller one is always fine, even for someone at their limit.

create function private.photos_update_fits_quota(p_id uuid, p_new_metadata jsonb)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  with sizes as (
    select
      coalesce((p_new_metadata ->> 'size')::bigint, 0) as new_size,
      coalesce((
        select (o.metadata ->> 'size')::bigint
        from storage.objects o
        where o.id = p_id and o.bucket_id = 'photos'
      ), 0) as old_size
  )
  select s.new_size <= s.old_size
    or private.storage_bytes_used((select auth.uid())) - s.old_size + s.new_size
       <= private.photos_quota_bytes()
  from sizes s;
$$;

revoke execute on function private.photos_update_fits_quota(uuid, jsonb) from public, anon;
grant execute on function private.photos_update_fits_quota(uuid, jsonb) to authenticated;

drop policy "photos_files_update_by_member" on storage.objects;
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
    and private.photos_update_fits_quota(id, metadata)
  );
