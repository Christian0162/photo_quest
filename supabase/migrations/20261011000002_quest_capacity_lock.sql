-- Two people redeeming different codes (or an owner inviting a friend while a
-- code is redeemed) could each see one free place and both take it, going over
-- the quest's crowd size. Both functions now lock the quest row before they
-- count, so capacity checks for one quest run one at a time. Lock order is
-- always invite row -> quest row -> participant row. Bodies are otherwise
-- unchanged; earlier migrations stay as they were.

create or replace function public.redeem_invite(p_code text)
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
  quest_row public.quests%rowtype;a
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

    -- Serialise place-taking for this quest.
    select * into quest_row
    from public.quests q
    where q.id = quest_invite.quest_id
    for update;

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

-- Invites a friend to one of my quests, with no code. They still choose to
-- accept. Same rules as a code: pair or group only, and room for them.
create or replace function public.invite_friend_to_quest(p_quest uuid, p_friend uuid)
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
  where q.id = p_quest and q.owner_id = caller
  for update;

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
