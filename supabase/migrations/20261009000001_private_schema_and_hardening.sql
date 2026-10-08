-- Photo Quest: a private schema for internal helpers, plus documentation.
--
-- Supabase exposes the `public` schema through its API, so anything placed
-- there can be reached by clients. Internal helpers (trigger functions, the
-- SECURITY DEFINER signup trigger, bookkeeping tables) belong in a schema the
-- API does not expose. Nothing here changes behavior; it shrinks the surface
-- an attacker could reach and makes the intent explicit.
--
-- Later migrations put new internal helpers in `private` from the start.

create schema if not exists private;

-- Nobody reaches `private` through the API. Functions that need it are either
-- triggers (no schema access needed when they fire) or SECURITY DEFINER
-- functions that run as their owner.
revoke all on schema private from public, anon, authenticated;

alter function public.set_updated_at() set schema private;
alter function public.handle_new_user() set schema private;

revoke execute on function private.set_updated_at() from public, anon, authenticated;
revoke execute on function private.handle_new_user() from public, anon, authenticated;

comment on schema private is
  'Internal helpers. Not exposed through the API; never grant it to clients.';

comment on table public.profiles is
  'One row per account (same id as auth.users). Display name and avatar only; '
  'credentials stay in auth.users.';
comment on column public.profiles.avatar_path is
  'Path inside the private avatars bucket, always under <user id>/.';
