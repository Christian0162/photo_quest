-- Photo Quest: a storage allowance for each person.
--
-- The Free plan has 1 GB of storage for everyone together, so each person gets
-- 100 MB of photo storage. Compressed photos are a few hundred KB each, so that
-- is a couple of hundred photos.
--
-- How it is enforced: the upload policy for the `photos` bucket refuses a new
-- file once the person's files already add up to the allowance. A person can
-- overshoot by at most one file (the bucket allows 10 MB per file), because
-- Storage only knows a file's size after it has been written.
--
-- The allowance counts files in the person's OWN folder, so friends' photos
-- added to someone else's memory count against the friend who added them.
-- Avatars are not counted (2 MB each, and old ones are removed).
--
-- Helper functions live in `private`. Policies run as the caller, so the
-- caller needs USAGE on that schema and EXECUTE on each helper, and nothing
-- else: the schema is not exposed through the API, and its tables stay closed.

grant usage on schema private to authenticated;

create function private.photos_quota_bytes()
returns bigint
language sql
immutable
set search_path = ''
as $$
  select 104857600::bigint; -- 100 MB
$$;

-- SECURITY DEFINER because ordinary callers can't read other storage rows,
-- and the total has to include every file in the folder.
create function private.storage_bytes_used(p_user uuid)
returns bigint
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(sum(coalesce((o.metadata ->> 'size')::bigint, 0)), 0)::bigint
  from storage.objects o
  where o.bucket_id = 'photos'
    and (storage.foldername(o.name))[1] = p_user::text;
$$;

revoke execute on function private.photos_quota_bytes() from public, anon;
revoke execute on function private.storage_bytes_used(uuid) from public, anon;
grant execute on function private.photos_quota_bytes() to authenticated;
grant execute on function private.storage_bytes_used(uuid) to authenticated;

-- What the app shows: how much of the allowance is used. Always about the
-- caller, never about anyone else.
create function public.my_storage_usage()
returns table (used_bytes bigint, quota_bytes bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select
    private.storage_bytes_used((select auth.uid())),
    private.photos_quota_bytes()
  where (select auth.uid()) is not null;
$$;

revoke execute on function public.my_storage_usage() from public, anon;
grant execute on function public.my_storage_usage() to authenticated;

-- The upload policy, now with the allowance.
drop policy "photos_files_insert_own" on storage.objects;
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
    and private.storage_bytes_used((select auth.uid())) < private.photos_quota_bytes()
  );

comment on function public.my_storage_usage() is
  'Bytes of online photo storage the caller has used, and their allowance.';
