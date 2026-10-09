-- Photo Quest: real friends, found by a friend code.
--
-- Every account has a friend code: 10 random characters (like TQ7K9-XPM2A)
-- that only its owner can read. Someone who is given the code can send a
-- friend request with it, and the person it belongs to accepts or declines.
-- Nobody can search for people by name or email, and a code can't be guessed
-- (50 bits, and guessing is throttled with the same counter as invite codes),
-- so nobody can check who has an account. The owner can reset their code at
-- any time; the old one stops working.
--
-- Friends see each other's name and photo, and can be invited straight from
-- the People screen to a quest or a memory, with no code to pass along.
--
-- Who may do what:
--   friend_code (on profiles)  readable by NOBODY directly (no column grant);
--                              the owner reads it with my_friend_code()
--   friendships                SELECT the two people (a request someone
--                              declined is only visible to whoever declined);
--                              DELETE either of the two (unfriend / cancel);
--                              INSERT/UPDATE nobody (the functions below only)
--
-- A declined request stays on record, quietly, so the person can't be asked
-- again and again: asking again just looks pending to the asker. The person
-- who declined can still change their mind by entering the other's code.

-- ============================================================ friend codes

alter table public.profiles add column friend_code text;

-- A fresh, unused code. SECURITY DEFINER so it can check every profile.
create function private.new_friend_code()
returns text
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  candidate text;
begin
  loop
    candidate := private.generate_invite_code();
    exit when not exists (
      select 1 from public.profiles p where p.friend_code = candidate
    );
  end loop;
  return candidate;
end;
$$;

revoke execute on function private.new_friend_code() from public, anon, authenticated;

-- Everyone who already has an account gets a code.
do $$
declare
  existing record;
begin
  for existing in select id from public.profiles where friend_code is null loop
    update public.profiles
    set friend_code = private.new_friend_code()
    where id = existing.id;
  end loop;
end $$;

alter table public.profiles alter column friend_code set not null;
alter table public.profiles
  add constraint profiles_friend_code_key unique (friend_code);
alter table public.profiles
  add constraint profiles_friend_code_format
  check (friend_code ~ '^[0-9A-HJKMNP-TV-Z]{10}$');

-- New accounts get one as they are created.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, friend_code)
  values (new.id, private.new_friend_code());
  return new;
end;
$$;

-- The friend code must never be readable by other people, and the profile
-- policy lets connected people read each other's rows. So reading is granted
-- column by column, and friend_code is left out.
revoke select on public.profiles from authenticated;
grant select (id, display_name, avatar_path, created_at, updated_at)
  on public.profiles to authenticated;

-- The owner reads their own code through this.
create function public.my_friend_code()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select p.friend_code
  from public.profiles p
  where p.id = (select auth.uid());
$$;

-- Makes a new code; the old one stops working at once.
create function public.reset_friend_code()
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  fresh text;
begin
  if caller is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;

  fresh := private.new_friend_code();
  update public.profiles set friend_code = fresh where id = caller;
  return fresh;
end;
$$;

revoke execute on function public.my_friend_code() from public, anon;
revoke execute on function public.reset_friend_code() from public, anon;
grant execute on function public.my_friend_code() to authenticated;
grant execute on function public.reset_friend_code() to authenticated;

-- ============================================================ friendships

create table public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles (id) on delete cascade,
  addressee_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'declined')),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  check (requester_id <> addressee_id)
);

-- One row per pair of people, whichever of them asked first.
create unique index friendships_pair_key
  on public.friendships (
    least(requester_id, addressee_id),
    greatest(requester_id, addressee_id)
  );
create index friendships_requester_id_idx on public.friendships (requester_id);
create index friendships_addressee_id_idx on public.friendships (addressee_id);

revoke all on public.friendships from anon, authenticated;
grant select, delete on public.friendships to authenticated;

alter table public.friendships enable row level security;

create policy "friendships_select_participants" on public.friendships
  for select to authenticated
  using (
    (select auth.uid()) = addressee_id
    or ((select auth.uid()) = requester_id and status <> 'declined')
  );

create policy "friendships_delete_participants" on public.friendships
  for delete to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));

-- Are these two people friends? (Accepted, whichever asked.)
create function private.are_friends(p_a uuid, p_b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.friendships f
    where f.status = 'accepted'
      and ((f.requester_id = p_a and f.addressee_id = p_b)
        or (f.requester_id = p_b and f.addressee_id = p_a))
  );
$$;

revoke execute on function private.are_friends(uuid, uuid) from public, anon;
grant execute on function private.are_friends(uuid, uuid) to authenticated;

-- ============================================================ who can see whose profile

-- Adds friends: whoever received a request can see who sent it (even after
-- declining), the sender sees the person while the request is open, and
-- friends see each other. Everything else is as before.
create or replace function private.can_see_profile(p_target uuid)
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
    )
    or exists (
      select 1 from public.friendships f
      where (f.requester_id = p_target and f.addressee_id = (select auth.uid()))
         or (f.addressee_id = p_target and f.requester_id = (select auth.uid())
             and f.status <> 'declined')
    );
$$;

-- ============================================================ send a friend request

-- Takes a friend code. Returns {user_id, name, status} for the person it
-- belongs to ("pending" while they haven't answered, "accepted" when they
-- already asked you or you are already friends), or null for a code that
-- doesn't work (wrong, or your own: the same quiet answer). Wrong codes count
-- towards the same hourly limit as invite codes.
create function public.request_friend(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  normalized text;
  target uuid;
  target_name text;
  existing public.friendships%rowtype;
  result_status text;
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

  select p.id, p.display_name into target, target_name
  from public.profiles p
  where p.friend_code = normalized;

  if target is null or target = caller then
    insert into private.invite_attempts (user_id) values (caller);
    return null;
  end if;

  select * into existing
  from public.friendships f
  where least(f.requester_id, f.addressee_id) = least(caller, target)
    and greatest(f.requester_id, f.addressee_id) = greatest(caller, target)
  for update;

  if not found then
    insert into public.friendships (requester_id, addressee_id)
    values (caller, target);
    result_status := 'pending';
  elsif existing.status = 'accepted' then
    result_status := 'accepted';
  elsif existing.requester_id = target then
    -- They had asked me (and I may have said no): entering their code now
    -- means yes.
    update public.friendships
    set status = 'accepted', responded_at = now()
    where id = existing.id;
    result_status := 'accepted';
  else
    -- I had already asked them. If they declined, I'm not told.
    result_status := 'pending';
  end if;

  return jsonb_build_object(
    'user_id', target,
    'name', target_name,
    'status', result_status
  );
end;
$$;

revoke execute on function public.request_friend(text) from public, anon;
grant execute on function public.request_friend(text) to authenticated;

-- ============================================================ answer a friend request

create function public.respond_to_friend_request(
  p_user uuid,
  p_accept boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  request public.friendships%rowtype;
begin
  if caller is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;

  select * into request
  from public.friendships f
  where f.requester_id = p_user
    and f.addressee_id = caller
    and f.status = 'pending'
  for update;

  if not found then
    raise exception 'request_not_pending' using errcode = '55000';
  end if;

  update public.friendships
  set status = case when p_accept then 'accepted' else 'declined' end,
      responded_at = now()
  where id = request.id;
end;
$$;

revoke execute on function public.respond_to_friend_request(uuid, boolean)
  from public, anon;
grant execute on function public.respond_to_friend_request(uuid, boolean)
  to authenticated;

-- ============================================================ invite a friend directly

-- Invites a friend to one of my quests, with no code. They still choose to
-- accept. Same rules as a code: pair or group only, and room for them.
create function public.invite_friend_to_quest(p_quest uuid, p_friend uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  quest_row public.quests%rowtype;
  participant public.quest_participants%rowtype;
  had_row boolean;
begin
  if caller is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;

  select * into quest_row
  from public.quests q
  where q.id = p_quest and q.owner_id = caller;

  if not found then
    raise exception 'quest_not_found' using errcode = 'P0002';
  end if;

  if quest_row.type = 'solo' then
    raise exception 'quest_not_shareable' using errcode = '22023';
  end if;

  if not private.are_friends(caller, p_friend) then
    raise exception 'not_friends' using errcode = '42501';
  end if;

  select * into participant
  from public.quest_participants p
  where p.quest_id = p_quest and p.user_id = p_friend
  for update;
  had_row := found;

  if had_row and participant.status in ('invited', 'accepted') then
    return;
  end if;

  if quest_row.max_participants is not null
     and (
       select count(*) from public.quest_participants p
       where p.quest_id = p_quest
         and p.status in ('invited', 'accepted')
         and p.user_id <> p_friend
     ) + 1 >= quest_row.max_participants then
    raise exception 'quest_full' using errcode = '53400';
  end if;

  if had_row then
    update public.quest_participants
    set status = 'invited', invited_at = now(), responded_at = null
    where id = participant.id;
  else
    insert into public.quest_participants (quest_id, owner_id, user_id)
    values (p_quest, caller, p_friend);
  end if;
end;
$$;

-- Lets a friend view one of my memories, with no code.
create function public.share_memory_with_friend(p_memory uuid, p_friend uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
begin
  if caller is null then
    raise exception 'not_signed_in' using errcode = '28000';
  end if;

  if not exists (
    select 1 from public.memories m
    where m.id = p_memory and m.owner_id = caller
  ) then
    raise exception 'memory_not_found' using errcode = 'P0002';
  end if;

  if not private.are_friends(caller, p_friend) then
    raise exception 'not_friends' using errcode = '42501';
  end if;

  insert into public.memory_shares (memory_id, owner_id, viewer_id)
  values (p_memory, caller, p_friend)
  on conflict (memory_id, viewer_id) do nothing;
end;
$$;

revoke execute on function public.invite_friend_to_quest(uuid, uuid) from public, anon;
revoke execute on function public.share_memory_with_friend(uuid, uuid) from public, anon;
grant execute on function public.invite_friend_to_quest(uuid, uuid) to authenticated;
grant execute on function public.share_memory_with_friend(uuid, uuid) to authenticated;

-- ============================================================ documentation

comment on column public.profiles.friend_code is
  'Random code others use to send a friend request. Not readable by clients; the owner reads it with my_friend_code().';
comment on table public.friendships is
  'A friend request and its answer. Rows come only from request_friend() and respond_to_friend_request().';
