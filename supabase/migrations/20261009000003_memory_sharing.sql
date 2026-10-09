-- Photo Quest: sharing a memory with friends, by invite code.
--
-- The owner makes a short code for one memory and tells a friend. The friend
-- enters it and can then VIEW that memory and its photos. Nothing else: no
-- editing, no uploading, no access to the owner's other memories.
--
-- Why a code and not "search by email": looking people up would let anyone
-- check who has an account. A code is only useful to someone the owner chose
-- to tell.
--
-- Security design:
--   * Codes are random, 10 characters from a 32-character alphabet (50 bits),
--     made on the server. Clients cannot choose or insert codes.
--   * Only a SHA-256 hash of the code is stored, so a database leak does not
--     reveal live codes. The plain code is shown to the owner once.
--   * A code expires (default 7 days), can be limited to a few uses, and can
--     be revoked.
--   * Redeeming goes through one function that gives the same quiet answer
--     (null) for a wrong, expired, revoked, used-up or own code, and
--     throttles guessing to 10 failed tries per hour per account.
--   * The hash column is not readable by clients at all.
--
-- Who may do what:
--   memory_shares   SELECT owner or viewer; DELETE owner (remove a viewer) or
--                   viewer (leave); INSERT/UPDATE nobody (redeem function only)
--   memory_invites  SELECT/UPDATE(revoked_at)/DELETE owner; INSERT nobody
--                   (create function only)

-- ============================================================ memory_shares

create table public.memory_shares (
  memory_id uuid not null,
  owner_id uuid not null,
  viewer_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (memory_id, viewer_id),
  -- The owner is copied in so policies stay simple and fast, and the
  -- composite key keeps it equal to the memory's real owner.
  foreign key (memory_id, owner_id)
    references public.memories (id, owner_id) on delete cascade,
  check (viewer_id <> owner_id)
);

create index memory_shares_viewer_id_idx on public.memory_shares (viewer_id);
create index memory_shares_owner_id_idx on public.memory_shares (owner_id);

-- ============================================================ memory_invites

create table public.memory_invites (
  id uuid primary key default gen_random_uuid(),
  memory_id uuid not null,
  owner_id uuid not null,
  code_hash text not null unique,
  expires_at timestamptz not null,
  max_uses integer not null check (max_uses between 1 and 20),
  use_count integer not null default 0,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  check (use_count between 0 and max_uses),
  foreign key (memory_id, owner_id)
    references public.memories (id, owner_id) on delete cascade
);

create index memory_invites_memory_id_idx on public.memory_invites (memory_id);
create index memory_invites_owner_id_idx on public.memory_invites (owner_id);

-- Bookkeeping for the guess throttle. Internal: not in the API schema.
create table private.invite_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  attempted_at timestamptz not null default now()
);

create index invite_attempts_user_time_idx
  on private.invite_attempts (user_id, attempted_at);

alter table private.invite_attempts enable row level security;
revoke all on private.invite_attempts from public, anon, authenticated;

-- ============================================================ privileges

revoke all on public.memory_shares, public.memory_invites from anon, authenticated;

grant select, delete on public.memory_shares to authenticated;

-- Column-level SELECT: code_hash is never readable by a client.
grant select (id, memory_id, owner_id, expires_at, max_uses, use_count,
              revoked_at, created_at)
  on public.memory_invites to authenticated;
grant update (revoked_at) on public.memory_invites to authenticated;
grant delete on public.memory_invites to authenticated;

-- ============================================================ row level security

alter table public.memory_shares enable row level security;
alter table public.memory_invites enable row level security;

create policy "memory_shares_select_owner_or_viewer" on public.memory_shares
  for select to authenticated
  using ((select auth.uid()) in (owner_id, viewer_id));

create policy "memory_shares_delete_owner_or_viewer" on public.memory_shares
  for delete to authenticated
  using ((select auth.uid()) in (owner_id, viewer_id));

create policy "memory_invites_select_own" on public.memory_invites
  for select to authenticated using ((select auth.uid()) = owner_id);

create policy "memory_invites_update_own" on public.memory_invites
  for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create policy "memory_invites_delete_own" on public.memory_invites
  for delete to authenticated using ((select auth.uid()) = owner_id);

-- ============================================================ viewers can read

-- A memory is readable by its owner and by anyone it was shared with.
drop policy "memories_select_own" on public.memories;
create policy "memories_select_own_or_shared" on public.memories
  for select to authenticated
  using (
    (select auth.uid()) = owner_id
    or exists (
      select 1 from public.memory_shares s
      where s.memory_id = memories.id
        and s.viewer_id = (select auth.uid())
    )
  );

drop policy "photos_select_own" on public.photos;
create policy "photos_select_own_or_shared" on public.photos
  for select to authenticated
  using (
    (select auth.uid()) = owner_id
    or exists (
      select 1 from public.memory_shares s
      where s.memory_id = photos.memory_id
        and s.viewer_id = (select auth.uid())
    )
  );

-- A shared memory shows who shared it, and the owner sees who can view. Only
-- the people on the other end of a share can read a profile.
drop policy "profiles_select_own" on public.profiles;
create policy "profiles_select_own_or_connected" on public.profiles
  for select to authenticated
  using (
    (select auth.uid()) = id
    or exists (
      select 1 from public.memory_shares s
      where (s.owner_id = profiles.id and s.viewer_id = (select auth.uid()))
         or (s.viewer_id = profiles.id and s.owner_id = (select auth.uid()))
    )
  );

-- ============================================================ code generation

-- 10 characters from a 32-character alphabet without look-alikes (no I, L,
-- O, U). Random bytes come from gen_random_uuid(), which is cryptographically
-- strong; bytes 6 and 8 are skipped because they hold fixed version bits.
create function private.generate_invite_code()
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  alphabet constant text := '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  random_bytes bytea := decode(replace(gen_random_uuid()::text, '-', ''), 'hex');
  positions constant integer[] := array[0, 1, 2, 3, 4, 5, 7, 9, 10, 11];
  code text := '';
  position_index integer;
begin
  foreach position_index in array positions loop
    code := code || substr(alphabet, (get_byte(random_bytes, position_index) % 32) + 1, 1);
  end loop;
  return code;
end;
$$;

revoke execute on function private.generate_invite_code() from public, anon, authenticated;

create function private.hash_invite_code(code text)
returns text
language sql
immutable
set search_path = ''
as $$
  select encode(sha256(convert_to(code, 'utf8')), 'hex');
$$;

revoke execute on function private.hash_invite_code(text) from public, anon, authenticated;

-- ============================================================ create an invite

-- Returns the plain code, formatted like ABCDE-FGHJK. This is the only time it
-- can be seen; only its hash is stored.
create function public.create_memory_invite(
  p_memory_id uuid,
  p_valid_days integer default 7,
  p_max_uses integer default 5
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  code text;
  attempts integer := 0;
begin
  if caller is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;

  if p_valid_days not between 1 and 30 or p_max_uses not between 1 and 20 then
    raise exception 'invalid_invite_settings' using errcode = '22023';
  end if;

  -- Only the owner can invite to a memory. Same answer whether the memory is
  -- missing or someone else's.
  if not exists (
    select 1 from public.memories m
    where m.id = p_memory_id and m.owner_id = caller
  ) then
    raise exception 'memory_not_found' using errcode = 'P0002';
  end if;

  -- Keeps a memory from piling up live codes.
  if (
    select count(*) from public.memory_invites i
    where i.memory_id = p_memory_id
      and i.revoked_at is null
      and i.expires_at > now()
      and i.use_count < i.max_uses
  ) >= 10 then
    raise exception 'too_many_invites' using errcode = '54000';
  end if;

  loop
    code := private.generate_invite_code();
    begin
      insert into public.memory_invites
        (memory_id, owner_id, code_hash, expires_at, max_uses)
      values
        (p_memory_id, caller, private.hash_invite_code(code),
         now() + make_interval(days => p_valid_days), p_max_uses);
      exit;
    exception when unique_violation then
      attempts := attempts + 1;
      if attempts >= 5 then raise; end if;
    end;
  end loop;

  return substr(code, 1, 5) || '-' || substr(code, 6, 5);
end;
$$;

revoke execute on function public.create_memory_invite(uuid, integer, integer)
  from public, anon;
grant execute on function public.create_memory_invite(uuid, integer, integer)
  to authenticated;

-- ============================================================ redeem an invite

-- Returns the memory id on success, otherwise null. The answer is the same
-- for every kind of failure so a guesser learns nothing. After 10 failed
-- tries in an hour the account is asked to wait.
create function public.redeem_memory_invite(p_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  normalized text;
  invite public.memory_invites%rowtype;
  inserted integer;
begin
  if caller is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;

  delete from private.invite_attempts
  where attempted_at < now() - interval '1 day';

  if (
    select count(*) from private.invite_attempts a
    where a.user_id = caller and a.attempted_at > now() - interval '1 hour'
  ) >= 10 then
    raise exception 'too_many_attempts' using errcode = '54000';
  end if;

  -- Forgive spaces, dashes, lowercase and look-alike characters.
  normalized := translate(
    upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g')),
    'OIL', '011'
  );

  if normalized !~ '^[0-9A-HJKMNP-TV-Z]{10}$' then
    insert into private.invite_attempts (user_id) values (caller);
    return null;
  end if;

  select * into invite
  from public.memory_invites i
  where i.code_hash = private.hash_invite_code(normalized)
  for update;

  if not found
     or invite.revoked_at is not null
     or invite.expires_at <= now()
     or invite.use_count >= invite.max_uses
     or invite.owner_id = caller then
    insert into private.invite_attempts (user_id) values (caller);
    return null;
  end if;

  insert into public.memory_shares (memory_id, owner_id, viewer_id)
  values (invite.memory_id, invite.owner_id, caller)
  on conflict (memory_id, viewer_id) do nothing;

  get diagnostics inserted = row_count;

  -- Someone who already has access doesn't use up a place.
  if inserted > 0 then
    update public.memory_invites
    set use_count = use_count + 1
    where id = invite.id;
  end if;

  return invite.memory_id;
end;
$$;

revoke execute on function public.redeem_memory_invite(text) from public, anon;
grant execute on function public.redeem_memory_invite(text) to authenticated;

-- ============================================================ documentation

comment on table public.memory_shares is
  'Who can VIEW a memory besides its owner. Rows are created only by redeem_memory_invite().';
comment on table public.memory_invites is
  'Share codes for one memory. Only a hash of the code is stored; clients cannot read it.';
comment on function public.create_memory_invite(uuid, integer, integer) is
  'Owner-only. Returns the plain invite code once, e.g. ABCDE-FGHJK.';
comment on function public.redeem_memory_invite(text) is
  'Adds the caller as a viewer of the memory. Returns the memory id, or null for any invalid code.';
