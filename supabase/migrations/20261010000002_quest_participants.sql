-- Photo Quest: taking part in a quest together.
--
-- The owner makes a short code for one quest (pair or group, not solo) and
-- tells a friend. The friend enters it and is INVITED; they then accept or
-- decline. An accepted participant can see the quest and its shots (and, in a
-- later migration, the memories made from it and add their own photos).
--
-- This follows the invitation lifecycle in CLAUDE.md §16A:
--   invited -> accepted | declined -> (removed | completed)
-- A person who is removed or leaves simply has their row deleted.
--
-- Codes work exactly like memory invite codes (random, hashed at rest,
-- expiring, limited, revocable, guessing throttled). One function,
-- redeem_invite(), now takes either kind of code and says which it was, so
-- the app needs a single "Got a code?" box. The older redeem_memory_invite()
-- still works.
--
-- Who may do what:
--   quest_participants  SELECT the owner, the participant themself, and (for
--                       accepted rows) other accepted participants;
--                       DELETE the same two (remove / leave);
--                       INSERT/UPDATE nobody (the functions below only)
--   quest_invites       SELECT/UPDATE(revoked_at)/DELETE owner; INSERT nobody
--
-- Crowd size: the quest's max_participants counts everyone, owner included.
-- An invited person holds a place until they decline or are removed.

-- ============================================================ tables

create table public.quest_participants (
  id uuid primary key default gen_random_uuid(),
  quest_id uuid not null,
  owner_id uuid not null,
  user_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'invited'
    check (status in ('invited', 'accepted', 'declined', 'removed', 'completed')),
  invited_at timestamptz not null default now(),
  responded_at timestamptz,
  foreign key (quest_id, owner_id)
    references public.quests (id, owner_id) on delete cascade,
  unique (quest_id, user_id),
  check (user_id <> owner_id)
);

create index quest_participants_user_id_idx on public.quest_participants (user_id);
create index quest_participants_owner_id_idx on public.quest_participants (owner_id);

create table public.quest_invites (
  id uuid primary key default gen_random_uuid(),
  quest_id uuid not null,
  owner_id uuid not null,
  code_hash text not null unique,
  expires_at timestamptz not null,
  max_uses integer not null check (max_uses between 1 and 20),
  use_count integer not null default 0,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  check (use_count between 0 and max_uses),
  foreign key (quest_id, owner_id)
    references public.quests (id, owner_id) on delete cascade
);

create index quest_invites_quest_id_idx on public.quest_invites (quest_id);
create index quest_invites_owner_id_idx on public.quest_invites (owner_id);

-- ============================================================ privileges

revoke all on public.quest_participants, public.quest_invites from anon, authenticated;

grant select, delete on public.quest_participants to authenticated;

grant select (id, quest_id, owner_id, expires_at, max_uses, use_count,
              revoked_at, created_at)
  on public.quest_invites to authenticated;
grant update (revoked_at) on public.quest_invites to authenticated;
grant delete on public.quest_invites to authenticated;

-- ============================================================ row level security

alter table public.quest_participants enable row level security;
alter table public.quest_invites enable row level security;

-- Is the caller an accepted participant of this quest? Used so people taking
-- part can see who else is. SECURITY DEFINER so the check doesn't recurse into
-- the policy it is used by.
create function private.is_accepted_participant(p_quest uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.quest_participants p
    where p.quest_id = p_quest
      and p.user_id = (select auth.uid())
      and p.status = 'accepted'
  );
$$;

revoke execute on function private.is_accepted_participant(uuid) from public, anon;
grant execute on function private.is_accepted_participant(uuid) to authenticated;

-- The owner sees everyone; a participant sees their own row; and people taking
-- part see the others who have accepted (not who declined or is still
-- deciding).
create policy "quest_participants_select_members" on public.quest_participants
  for select to authenticated
  using (
    (select auth.uid()) in (owner_id, user_id)
    or (status = 'accepted' and private.is_accepted_participant(quest_id))
  );

create policy "quest_participants_delete_owner_or_self" on public.quest_participants
  for delete to authenticated
  using ((select auth.uid()) in (owner_id, user_id));

create policy "quest_invites_select_own" on public.quest_invites
  for select to authenticated using ((select auth.uid()) = owner_id);

create policy "quest_invites_update_own" on public.quest_invites
  for update to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create policy "quest_invites_delete_own" on public.quest_invites
  for delete to authenticated using ((select auth.uid()) = owner_id);

-- ============================================================ participants can read the quest

-- Someone who has been invited can read the quest to decide; once they accept
-- they keep reading it. Sessions are only for people who are taking part.

drop policy "quests_select_own" on public.quests;
create policy "quests_select_own_or_participant" on public.quests
  for select to authenticated
  using (
    (select auth.uid()) = owner_id
    or exists (
      select 1 from public.quest_participants p
      where p.quest_id = quests.id
        and p.user_id = (select auth.uid())
        and p.status in ('invited', 'accepted')
    )
  );

drop policy "quest_shots_select_own" on public.quest_shots;
create policy "quest_shots_select_own_or_participant" on public.quest_shots
  for select to authenticated
  using (
    (select auth.uid()) = owner_id
    or exists (
      select 1 from public.quest_participants p
      where p.quest_id = quest_shots.quest_id
        and p.user_id = (select auth.uid())
        and p.status in ('invited', 'accepted')
    )
  );

drop policy "quest_sessions_select_own" on public.quest_sessions;
create policy "quest_sessions_select_own_or_participant" on public.quest_sessions
  for select to authenticated
  using (
    (select auth.uid()) = owner_id
    or exists (
      select 1 from public.quest_participants p
      where p.quest_id = quest_sessions.quest_id
        and p.user_id = (select auth.uid())
        and p.status = 'accepted'
    )
  );

-- ============================================================ who can see whose profile

-- A profile is readable by its owner and by the people on the other end of a
-- memory share or a quest: the owner and each participant see each other
-- (any status, so the owner sees who has been invited and who declined, and
-- an invited person sees who invited them), and accepted participants see one
-- another. Strangers see nothing.
create function private.can_see_profile(p_target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    p_target = (select auth.uid())
    or exists (
      select 1 from public.memory_shares s
      where (s.owner_id = p_target and s.viewer_id = (select auth.uid()))
         or (s.viewer_id = p_target and s.owner_id = (select auth.uid()))
    )
    or exists (
      select 1 from public.quest_participants p
      where (p.owner_id = p_target and p.user_id = (select auth.uid())
             and p.status in ('invited', 'accepted'))
         or (p.user_id = p_target and p.owner_id = (select auth.uid()))
    )
    or exists (
      select 1
      from public.quest_participants mine
      join public.quest_participants theirs on theirs.quest_id = mine.quest_id
      where mine.user_id = (select auth.uid()) and mine.status = 'accepted'
        and theirs.user_id = p_target and theirs.status = 'accepted'
    );
$$;

revoke execute on function private.can_see_profile(uuid) from public, anon;
grant execute on function private.can_see_profile(uuid) to authenticated;

drop policy "profiles_select_own_or_connected" on public.profiles;
create policy "profiles_select_own_or_connected" on public.profiles
  for select to authenticated
  using (private.can_see_profile(id));

-- Avatars follow the same rule. The folder name is text, so it is only turned
-- into a uuid when it really looks like one.
drop policy "avatars_select_own_or_connected" on storage.objects;
create policy "avatars_select_own_or_connected"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'avatars'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or case
        when (storage.foldername(name))[1]
             ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
        then private.can_see_profile(((storage.foldername(name))[1])::uuid)
        else false
      end
    )
  );

-- ============================================================ create a quest invite

create function public.create_quest_invite(
  p_quest_id uuid,
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
  quest_type text;
  code text;
  attempts integer := 0;
begin
  if caller is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;

  if p_valid_days not between 1 and 30 or p_max_uses not between 1 and 20 then
    raise exception 'invalid_invite_settings' using errcode = '22023';
  end if;

  select q.type into quest_type
  from public.quests q
  where q.id = p_quest_id and q.owner_id = caller;

  if not found then
    raise exception 'quest_not_found' using errcode = 'P0002';
  end if;

  -- A solo quest has nobody to invite.
  if quest_type = 'solo' then
    raise exception 'quest_not_shareable' using errcode = '22023';
  end if;

  if (
    select count(*) from public.quest_invites i
    where i.quest_id = p_quest_id
      and i.revoked_at is null
      and i.expires_at > now()
      and i.use_count < i.max_uses
  ) >= 10 then
    raise exception 'too_many_invites' using errcode = '54000';
  end if;

  loop
    code := private.generate_invite_code();
    begin
      insert into public.quest_invites
        (quest_id, owner_id, code_hash, expires_at, max_uses)
      values
        (p_quest_id, caller, private.hash_invite_code(code),
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

revoke execute on function public.create_quest_invite(uuid, integer, integer)
  from public, anon;
grant execute on function public.create_quest_invite(uuid, integer, integer)
  to authenticated;

-- ============================================================ redeem any invite code

-- Takes a memory code or a quest code. Returns {"kind": "memory"|"quest",
-- "id": ...}, or null for anything that doesn't work (the same quiet answer
-- for wrong, expired, revoked, used-up or own codes). A quest code makes the
-- caller an INVITED participant; they still have to accept.
create function public.redeem_invite(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  normalized text;
  code_digest text;
  memory_invite public.memory_invites%rowtype;
  quest_invite public.quest_invites%rowtype;
  quest_row public.quests%rowtype;
  participant public.quest_participants%rowtype;
  had_row boolean;
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

  normalized := translate(
    upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g')),
    'OIL', '011'
  );

  if normalized !~ '^[0-9A-HJKMNP-TV-Z]{10}$' then
    insert into private.invite_attempts (user_id) values (caller);
    return null;
  end if;

  code_digest := private.hash_invite_code(normalized);

  -- A memory code?
  select * into memory_invite
  from public.memory_invites i
  where i.code_hash = code_digest
  for update;

  if found then
    if memory_invite.revoked_at is not null
       or memory_invite.expires_at <= now()
       or memory_invite.use_count >= memory_invite.max_uses
       or memory_invite.owner_id = caller then
      insert into private.invite_attempts (user_id) values (caller);
      return null;
    end if;

    insert into public.memory_shares (memory_id, owner_id, viewer_id)
    values (memory_invite.memory_id, memory_invite.owner_id, caller)
    on conflict (memory_id, viewer_id) do nothing;

    get diagnostics inserted = row_count;
    if inserted > 0 then
      update public.memory_invites
      set use_count = use_count + 1
      where id = memory_invite.id;
    end if;

    return jsonb_build_object('kind', 'memory', 'id', memory_invite.memory_id);
  end if;

  -- A quest code?
  select * into quest_invite
  from public.quest_invites i
  where i.code_hash = code_digest
  for update;

  if found then
    if quest_invite.revoked_at is not null
       or quest_invite.expires_at <= now()
       or quest_invite.use_count >= quest_invite.max_uses
       or quest_invite.owner_id = caller then
      insert into private.invite_attempts (user_id) values (caller);
      return null;
    end if;

    select * into quest_row from public.quests q where q.id = quest_invite.quest_id;

    select * into participant
    from public.quest_participants p
    where p.quest_id = quest_invite.quest_id and p.user_id = caller
    for update;
    had_row := found;

    -- Already invited or taking part: nothing to do, no place used up.
    if had_row and participant.status in ('invited', 'accepted') then
      return jsonb_build_object('kind', 'quest', 'id', quest_invite.quest_id);
    end if;

    -- Is there room? Everyone invited or taking part holds a place, plus the
    -- owner. This applies to someone coming back after declining too.
    if quest_row.max_participants is not null
       and (
         select count(*) from public.quest_participants p
         where p.quest_id = quest_row.id
           and p.status in ('invited', 'accepted')
           and p.user_id <> caller
       ) + 1 >= quest_row.max_participants then
      raise exception 'quest_full' using errcode = '53400';
    end if;

    if had_row then
      -- Declined or finished earlier: invite them again.
      update public.quest_participants
      set status = 'invited', invited_at = now(), responded_at = null
      where id = participant.id;
    else
      insert into public.quest_participants (quest_id, owner_id, user_id)
      values (quest_invite.quest_id, quest_invite.owner_id, caller);
    end if;

    update public.quest_invites
    set use_count = use_count + 1
    where id = quest_invite.id;

    return jsonb_build_object('kind', 'quest', 'id', quest_invite.quest_id);
  end if;

  insert into private.invite_attempts (user_id) values (caller);
  return null;
end;
$$;

revoke execute on function public.redeem_invite(text) from public, anon;
grant execute on function public.redeem_invite(text) to authenticated;

-- ============================================================ accept or decline

create function public.respond_to_quest_invitation(
  p_quest_id uuid,
  p_accept boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  participant public.quest_participants%rowtype;
begin
  if caller is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;

  select * into participant
  from public.quest_participants p
  where p.quest_id = p_quest_id and p.user_id = caller
  for update;

  if not found or participant.status <> 'invited' then
    raise exception 'invitation_not_pending' using errcode = '55000';
  end if;

  -- The place was held when they were invited, so accepting needs no room check.
  update public.quest_participants
  set status = case when p_accept then 'accepted' else 'declined' end,
      responded_at = now()
  where id = participant.id;
end;
$$;

revoke execute on function public.respond_to_quest_invitation(uuid, boolean)
  from public, anon;
grant execute on function public.respond_to_quest_invitation(uuid, boolean)
  to authenticated;

-- ============================================================ documentation

comment on table public.quest_participants is
  'One account''s membership of one quest, with the invitation status. Rows come only from redeem_invite() and respond_to_quest_invitation().';
comment on table public.quest_invites is
  'Share codes for one quest. Only a hash of the code is stored; clients cannot read it.';
comment on function public.redeem_invite(text) is
  'Takes a memory or quest code. Returns {kind, id}, or null for any invalid code.';
