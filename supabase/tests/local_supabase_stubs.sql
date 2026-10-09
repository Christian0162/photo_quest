-- Minimal stand-ins for the parts of Supabase that the migrations rely on
-- (roles, auth.users, auth.uid(), storage.buckets / objects /
-- foldername()), so the migrations and rls_test.sql can be exercised on a
-- plain throwaway Postgres. NEVER run this on a real Supabase project.
--
--   psql -v ON_ERROR_STOP=1 -f local_supabase_stubs.sql
--   psql -v ON_ERROR_STOP=1 -f ../migrations/20261008000001_profiles.sql
--   psql -v ON_ERROR_STOP=1 -f ../migrations/20261008000002_avatars_storage.sql
--   psql -v ON_ERROR_STOP=1 -f rls_test.sql

create role anon nologin;
create role authenticated nologin;

create schema auth;
create table auth.users (id uuid primary key, email text);
create function auth.uid() returns uuid
language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;
grant usage on schema auth to anon, authenticated;

create schema storage;
create table storage.buckets (
  id text primary key,
  name text not null,
  public boolean default false,
  file_size_limit bigint,
  allowed_mime_types text[]
);
create table storage.objects (
  id uuid primary key default gen_random_uuid(),
  bucket_id text references storage.buckets (id),
  name text,
  owner uuid,
  -- Real Storage records each file's size in metadata -> 'size'.
  metadata jsonb,
  created_at timestamptz default now()
);
alter table storage.objects enable row level security;
create function storage.foldername(name text) returns text[]
language sql immutable as $$
  select _parts[1:array_length(_parts, 1) - 1]
  from (select string_to_array(name, '/') as _parts) as p
$$;

-- Supabase hands every new public table to the API roles; the migration then
-- revokes what it does not want. Mirror that so the revoke is really tested.
grant usage on schema public, storage to anon, authenticated;
grant all on storage.objects to anon, authenticated;
grant select on storage.buckets to anon, authenticated;
alter default privileges in schema public grant all on tables to anon, authenticated;
