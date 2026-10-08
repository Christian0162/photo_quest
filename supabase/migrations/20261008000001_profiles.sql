-- Photo Quest: user profiles.
--
-- One row per account, keyed by the auth user's id. Passwords and tokens stay
-- in auth.users (managed by Supabase Auth); nothing sensitive is copied here.
-- Quests, memories and photos stay on the device, so there is no table for
-- them.
--
-- Access rules (enforced by Row Level Security, not by the app):
--   SELECT  own row only
--   INSERT  nobody from the client; the trigger below creates the row
--   UPDATE  own row only, and only display_name / avatar_path
--   DELETE  nobody from the client; the row is removed with the account

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text
    check (display_name is null or char_length(display_name) between 1 and 50),
  -- Path inside the private "avatars" bucket. It must live in the owner's own
  -- folder, so a profile can never point at someone else's file.
  avatar_path text
    check (avatar_path is null or avatar_path like id::text || '/%'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Least privilege: start from nothing, then grant only what the app needs.
revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant update (display_name, avatar_path) on public.profiles to authenticated;

create policy "profiles_select_own"
  on public.profiles
  for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_update_own"
  on public.profiles
  for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Keep updated_at honest.
create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Every new account gets an empty profile. SECURITY DEFINER so it can insert
-- even though clients have no INSERT right; it takes the id from the new auth
-- row, never from anything a client sends.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Accounts created before this migration.
insert into public.profiles (id)
select id from auth.users
on conflict (id) do nothing;
