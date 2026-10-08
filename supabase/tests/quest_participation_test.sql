-- Photo Quest: quest invitations, participants adding photos, and the storage
-- allowance.
--
-- Run AFTER all migrations, in the Supabase SQL editor or with
-- psql -v ON_ERROR_STOP=1 -f quest_participation_test.sql. One transaction,
-- rolled back; any failed check stops the script, and reaching the final
-- SELECT means everything passed.
--
-- Cast: A owns the quests. B joins and accepts. C is invited and declines. D
-- joins, accepts, then leaves. E guesses codes. F is only given a memory code.

begin;

create function pg_temp.act_as(uid uuid) returns void
language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid::text, true);
  perform set_config(
    'request.jwt.claims', json_build_object('sub', uid, 'role', 'authenticated')::text, true
  );
  set local role authenticated;
end;
$$;

create function pg_temp.act_as_anon() returns void
language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claims', '{"role":"anon"}', true);
  set local role anon;
end;
$$;

create function pg_temp.check(ok boolean, label text) returns void
language plpgsql as $$
begin
  if not ok then raise exception 'FAILED: %', label; end if;
end;
$$;

-- 42501 permission / RLS, 23503 foreign key, 23514 check, 22023 bad value,
-- P0002 not found, 54000 throttled, 53400 quest full, 55000 not pending.
create function pg_temp.is_refused(stmt text, variadic states text[]) returns boolean
language plpgsql as $$
begin
  execute stmt;
  return false;
exception when others then
  return sqlstate = any (states);
end;
$$;

create function pg_temp.rows_changed(stmt text) returns bigint
language plpgsql as $$
declare n bigint;
begin
  execute stmt;
  get diagnostics n = row_count;
  return n;
end;
$$;

-- ---------------------------------------------------------------- fixtures
insert into auth.users (id, email) values
  ('a0000000-0000-0000-0000-00000000000a', 'a@example.com'),
  ('b0000000-0000-0000-0000-00000000000b', 'b@example.com'),
  ('c0000000-0000-0000-0000-00000000000c', 'c@example.com'),
  ('d0000000-0000-0000-0000-00000000000d', 'd@example.com'),
  ('e0000000-0000-0000-0000-00000000000e', 'e@example.com'),
  ('f0000000-0000-0000-0000-00000000000f', 'f@example.com');

update public.profiles set display_name = 'Alex' where id = 'a0000000-0000-0000-0000-00000000000a';
update public.profiles set display_name = 'Bo'   where id = 'b0000000-0000-0000-0000-00000000000b';
update public.profiles set display_name = 'Cass' where id = 'c0000000-0000-0000-0000-00000000000c';
update public.profiles set display_name = 'Dee'  where id = 'd0000000-0000-0000-0000-00000000000d';

-- Files that already exist, made as the database owner.
insert into storage.objects (bucket_id, name, owner, metadata) values
  ('photos', 'a0000000-0000-0000-0000-00000000000a/60000000-0000-0000-0000-000000000001/p1.jpg',
   'a0000000-0000-0000-0000-00000000000a', '{"size": 1000}'),
  ('photos', 'a0000000-0000-0000-0000-00000000000a/60000000-0000-0000-0000-000000000002/private.jpg',
   'a0000000-0000-0000-0000-00000000000a', '{"size": 1000}'),
  ('avatars', 'a0000000-0000-0000-0000-00000000000a/avatar.jpg',
   'a0000000-0000-0000-0000-00000000000a', '{"size": 1000}');

-- ================================================================ A's quests
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');

insert into public.quests (id, owner_id, title, category, type, max_participants) values
  ('40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', 'Family day', 'For Family', 'group', 3),
  ('40000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-00000000000a', 'Date night', 'For Us', 'pair', 2),
  ('40000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-00000000000a', 'Just me', 'For Me', 'solo', null);
insert into public.quest_shots (id, quest_id, owner_id, position, instruction, shot_type)
values ('80000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', 0, 'Squeeze in', 'group');
insert into public.quest_sessions (id, quest_id, owner_id, started_at)
values ('50000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', now());
insert into public.memories (id, owner_id, quest_session_id, title, captured_at) values
  ('60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', '50000000-0000-0000-0000-000000000001', 'Family day', now()),
  ('60000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-00000000000a', null, 'Private one', now());
insert into public.photos (id, memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
values ('70000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001',
        'a0000000-0000-0000-0000-00000000000a', 'a0000000-0000-0000-0000-00000000000a',
        'a0000000-0000-0000-0000-00000000000a/60000000-0000-0000-0000-000000000001/p1.jpg', 0, now());

select set_config('test.code', public.create_quest_invite('40000000-0000-0000-0000-000000000001'), true);
select set_config('test.paircode', public.create_quest_invite('40000000-0000-0000-0000-000000000002'), true);
select set_config('test.memcode', public.create_memory_invite('60000000-0000-0000-0000-000000000001'), true);

select pg_temp.check(
  current_setting('test.code') ~ '^[0-9A-HJKMNP-TV-Z]{5}-[0-9A-HJKMNP-TV-Z]{5}$',
  'quest invite codes look like ABCDE-FGHJK'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.create_quest_invite('40000000-0000-0000-0000-000000000003')$q$, '22023'),
  'a solo quest cannot be shared'
);
select pg_temp.check(
  pg_temp.is_refused($q$select code_hash from public.quest_invites$q$, '42501'),
  'the quest code hash is not readable'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.quest_invites (quest_id, owner_id, code_hash, expires_at, max_uses)
       values ('40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', 'weak', now() + interval '1 day', 5)$q$,
    '42501'
  ),
  'clients cannot make their own quest codes'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.quest_participants (quest_id, owner_id, user_id)
       values ('40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', 'd0000000-0000-0000-0000-00000000000d')$q$,
    '42501'
  ),
  'the owner cannot add a participant without their code'
);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
insert into public.quests (id, owner_id, title, category, type)
values ('40000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-00000000000b', 'Bo''s quest', 'For Us', 'group');
select pg_temp.check(
  pg_temp.is_refused($q$select public.create_quest_invite('40000000-0000-0000-0000-000000000001')$q$, 'P0002'),
  'B cannot make a code for A''s quest'
);
reset role;

-- ================================================================ B is invited
select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  (select count(*) from public.quests) = 0,
  'a stranger sees no quests'
);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select set_config(
  'test.kind',
  public.redeem_invite(' ' || lower(current_setting('test.code')) || ' ') ->> 'kind',
  true
);
select pg_temp.check(
  current_setting('test.kind') = 'quest'
    and (select count(*) from public.quest_participants where status = 'invited') = 1,
  'B entering the code is invited (case and dash forgiven)'
);
select pg_temp.check(
  (select count(*) from public.quests where id = '40000000-0000-0000-0000-000000000001') = 1
    and (select count(*) from public.quests where id = '40000000-0000-0000-0000-000000000002') = 0
    and (select count(*) from public.quest_shots) = 1,
  'an invited person can read that quest and its shots, not A''s other quests'
);
select pg_temp.check(
  (select count(*) from public.quest_sessions) = 0
    and (select count(*) from public.memories where id = '60000000-0000-0000-0000-000000000001') = 0
    and (select count(*) from public.photos) = 0,
  'but not its sessions or memories until they accept'
);
select pg_temp.check(
  (select count(*) from public.profiles) = 2
    and (select display_name from public.profiles where id = 'a0000000-0000-0000-0000-00000000000a') = 'Alex',
  'an invited person can see who invited them'
);
select pg_temp.check(
  public.redeem_invite(current_setting('test.code')) ->> 'kind' = 'quest',
  'entering the code again is harmless'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.respond_to_quest_invitation('40000000-0000-0000-0000-000000000002', true)$q$, '55000'),
  'you cannot accept a quest you were not invited to'
);
select pg_temp.check(
  pg_temp.is_refused($q$update public.quest_participants set status = 'accepted'$q$, '42501'),
  'status can only change through the accept function'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.quest_participants (quest_id, owner_id, user_id)
       values ('40000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-00000000000a', 'b0000000-0000-0000-0000-00000000000b')$q$,
    '42501'
  ),
  'nobody can add themselves without a code'
);
reset role;

-- ================================================================ the quest fills up
-- Family day holds 3 people: A, B and one more.
select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  public.redeem_invite(current_setting('test.code')) ->> 'kind' = 'quest',
  'C joins with the code'
);
reset role;

select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  pg_temp.is_refused($q$select public.redeem_invite(current_setting('test.code'))$q$, '53400'),
  'a full quest turns the next person away'
);
reset role;

select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select public.respond_to_quest_invitation('40000000-0000-0000-0000-000000000001', false);
select pg_temp.check(
  (select status from public.quest_participants where user_id = 'c0000000-0000-0000-0000-00000000000c') = 'declined'
    and (select responded_at from public.quest_participants where user_id = 'c0000000-0000-0000-0000-00000000000c') is not null,
  'C declined'
);
select pg_temp.check(
  (select count(*) from public.quests) = 0 and (select count(*) from public.memories) = 0,
  'a declined person no longer reads the quest'
);
reset role;

select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  public.redeem_invite(current_setting('test.code')) ->> 'kind' = 'quest',
  'declining frees a place for D'
);
select public.respond_to_quest_invitation('40000000-0000-0000-0000-000000000001', true);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select public.respond_to_quest_invitation('40000000-0000-0000-0000-000000000001', true);
select pg_temp.check(
  pg_temp.is_refused($q$select public.respond_to_quest_invitation('40000000-0000-0000-0000-000000000001', true)$q$, '55000'),
  'you cannot accept twice'
);
reset role;

select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  pg_temp.is_refused($q$select public.redeem_invite(current_setting('test.code'))$q$, '53400'),
  'C coming back after declining does not get round the limit'
);
reset role;

-- ================================================================ what an accepted participant sees
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  (select count(*) from public.quest_sessions) = 1
    and (select count(*) from public.memories where id = '60000000-0000-0000-0000-000000000001') = 1
    and (select count(*) from public.memories where id = '60000000-0000-0000-0000-000000000002') = 0
    and (select count(*) from public.photos) = 1,
  'B sees the quest''s session, memory and photos, but not A''s other memory'
);
select pg_temp.check(
  (select count(*) from public.quests where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 1,
  'and only that one of A''s quests'
);
select pg_temp.check(
  (select count(*) from public.profiles) = 3
    and not exists (select 1 from public.profiles where id = 'c0000000-0000-0000-0000-00000000000c'),
  'B sees A and the other accepted participant, not someone who declined'
);
select pg_temp.check(
  (select count(*) from public.quest_participants where quest_id = '40000000-0000-0000-0000-000000000001') = 2
    and not exists (
      select 1 from public.quest_participants where user_id = 'c0000000-0000-0000-0000-00000000000c'
    ),
  'B sees who else has accepted, not who declined'
);
select pg_temp.check(
  pg_temp.rows_changed($q$update public.quests set title = 'Hacked' where owner_id = 'a0000000-0000-0000-0000-00000000000a'$q$) = 0
    and pg_temp.rows_changed($q$update public.memories set title = 'Hacked' where id = '60000000-0000-0000-0000-000000000001'$q$) = 0
    and pg_temp.rows_changed($q$delete from public.memories where id = '60000000-0000-0000-0000-000000000001'$q$) = 0
    and pg_temp.rows_changed($q$delete from public.quest_shots where owner_id = 'a0000000-0000-0000-0000-00000000000a'$q$) = 0,
  'a participant cannot change or delete the owner''s quest, shots or memory'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.quest_sessions (quest_id, owner_id, started_at)
       values ('40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', now())$q$,
    '42501'
  ),
  'a participant cannot start sessions on the owner''s quest'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  (select count(*) from public.profiles) = 4
    and (select count(*) from public.quest_participants) = 3,
  'A sees everyone invited, including who declined, and their names'
);
select pg_temp.check(
  pg_temp.is_refused($q$update public.photos set uploaded_by = 'a0000000-0000-0000-0000-00000000000a'$q$, '42501'),
  'who added a photo can never be rewritten'
);
reset role;

select pg_temp.act_as('e0000000-0000-0000-0000-00000000000e');
select pg_temp.check(
  (select count(*) from public.quests) = 0
    and (select count(*) from public.profiles) = 1
    and (select count(*) from public.quest_participants) = 0,
  'a stranger sees no quests, no participants and no one''s profile'
);
reset role;

-- ================================================================ the pair quest holds two
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  public.redeem_invite(current_setting('test.paircode')) ->> 'kind' = 'quest',
  'B can be invited to the pair quest'
);
reset role;
select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  pg_temp.is_refused($q$select public.redeem_invite(current_setting('test.paircode'))$q$, '53400'),
  'a pair quest has room for one friend'
);
reset role;

-- ================================================================ participants add photos
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  pg_temp.rows_changed(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/b1.jpg', 'b0000000-0000-0000-0000-00000000000b')$q$
  ) = 1,
  'B can upload into their own folder for the quest''s memory'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000002/b2.jpg', 'b0000000-0000-0000-0000-00000000000b')$q$,
    '42501'
  ),
  'but not for a memory outside the quest'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'a0000000-0000-0000-0000-00000000000a/60000000-0000-0000-0000-000000000001/evil.jpg', 'b0000000-0000-0000-0000-00000000000b')$q$,
    '42501'
  ),
  'and not into A''s folder'
);
select pg_temp.check(
  pg_temp.rows_changed(
    $q$insert into public.photos (id, memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('70000000-0000-0000-0000-000000000002', '60000000-0000-0000-0000-000000000001',
               'a0000000-0000-0000-0000-00000000000a', 'b0000000-0000-0000-0000-00000000000b',
               'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/b1.jpg', 0, now())$q$
  ) = 1,
  'B can record the photo, as themself, in A''s memory (same position as A''s is fine)'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a',
               'a0000000-0000-0000-0000-00000000000a',
               'a0000000-0000-0000-0000-00000000000a/60000000-0000-0000-0000-000000000001/fake.jpg', 3, now())$q$,
    '42501'
  ),
  'B cannot add a photo in A''s name'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('60000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b',
               'b0000000-0000-0000-0000-00000000000b',
               'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/z.jpg', 4, now())$q$,
    '23503'
  ),
  'a photo must carry the memory''s real owner'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a',
               'b0000000-0000-0000-0000-00000000000b',
               'a0000000-0000-0000-0000-00000000000a/60000000-0000-0000-0000-000000000001/z.jpg', 4, now())$q$,
    '23514'
  ),
  'a photo''s file must be in the uploader''s own folder'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('60000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-00000000000a',
               'b0000000-0000-0000-0000-00000000000b',
               'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000002/z.jpg', 4, now())$q$,
    '42501'
  ),
  'B cannot add a photo to a memory outside the quest'
);
select pg_temp.check(
  (select count(*) from public.photos where memory_id = '60000000-0000-0000-0000-000000000001') = 2
    and (select count(*) from storage.objects where bucket_id = 'photos') = 2,
  'B sees A''s photo and their own, in rows and files'
);
select pg_temp.check(
  pg_temp.rows_changed($q$update public.photos set position = 9$q$) = 0
    and pg_temp.rows_changed($q$delete from public.photos where uploaded_by = 'a0000000-0000-0000-0000-00000000000a'$q$) = 0,
  'B cannot reorder or delete A''s photos'
);
reset role;

-- A second photo, so B can delete one of their own and A can delete the other.
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
insert into storage.objects (bucket_id, name, owner) values
  ('photos', 'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/b2.jpg', 'b0000000-0000-0000-0000-00000000000b');
insert into public.photos (id, memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
values ('70000000-0000-0000-0000-000000000003', '60000000-0000-0000-0000-000000000001',
        'a0000000-0000-0000-0000-00000000000a', 'b0000000-0000-0000-0000-00000000000b',
        'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/b2.jpg', 1, now());
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.photos where id = '70000000-0000-0000-0000-000000000003'$q$) = 1
    and pg_temp.rows_changed($q$delete from storage.objects where name like 'b0000000-%/60000000-0000-0000-0000-000000000001/b2.jpg'$q$) = 1,
  'B can delete a photo they added, row and file'
);
reset role;

-- ================================================================ others looking at the photos
select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  (select count(*) from public.photos) = 0
    and (select count(*) from storage.objects where bucket_id = 'photos') = 0
    and pg_temp.is_refused(
      $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'c0000000-0000-0000-0000-00000000000c/60000000-0000-0000-0000-000000000001/c1.jpg', 'c0000000-0000-0000-0000-00000000000c')$q$,
      '42501'
    ),
  'someone who declined sees and adds nothing'
);
reset role;

select pg_temp.act_as('f0000000-0000-0000-0000-00000000000f');
select pg_temp.check(
  public.redeem_invite(current_setting('test.memcode')) ->> 'kind' = 'memory',
  'one box takes memory codes too'
);
select pg_temp.check(
  (select count(*) from public.photos) = 2
    and (select count(*) from storage.objects where bucket_id = 'photos') = 2,
  'a friend with a memory code sees all of its photos, including B''s'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'f0000000-0000-0000-0000-00000000000f/60000000-0000-0000-0000-000000000001/f1.jpg', 'f0000000-0000-0000-0000-00000000000f')$q$,
    '42501'
  )
  and pg_temp.is_refused(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a',
               'f0000000-0000-0000-0000-00000000000f',
               'f0000000-0000-0000-0000-00000000000f/60000000-0000-0000-0000-000000000001/f1.jpg', 5, now())$q$,
    '42501'
  ),
  'but a code viewer cannot add photos'
);
select pg_temp.check(
  (select count(*) from public.quests) = 0,
  'and a memory code gives no access to the quest'
);
reset role;

select pg_temp.act_as('e0000000-0000-0000-0000-00000000000e');
select pg_temp.check(
  (select count(*) from public.photos) = 0
    and (select count(*) from storage.objects) = 0,
  'a stranger sees no photos or files'
);
reset role;

-- ================================================================ the owner
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  (select count(*) from public.photos where memory_id = '60000000-0000-0000-0000-000000000001') = 2
    and (select count(*) from storage.objects where name like 'b0000000-%') = 1,
  'A sees B''s photo and file in A''s memory'
);
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.photos where id = '70000000-0000-0000-0000-000000000002'$q$) = 1
    and pg_temp.rows_changed($q$delete from storage.objects where name like 'b0000000-%'$q$) = 1,
  'A can remove a friend''s photo from A''s memory, row and file'
);
select pg_temp.check(
  pg_temp.rows_changed($q$delete from storage.objects where name like 'a0000000-%/60000000-0000-0000-0000-000000000002/%'$q$) = 1,
  'and their own files, as before'
);
reset role;

-- B adds one more, to see what deleting an account does to it.
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
insert into storage.objects (bucket_id, name, owner) values
  ('photos', 'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/b3.jpg', 'b0000000-0000-0000-0000-00000000000b');
insert into public.photos (id, memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
values ('70000000-0000-0000-0000-000000000004', '60000000-0000-0000-0000-000000000001',
        'a0000000-0000-0000-0000-00000000000a', 'b0000000-0000-0000-0000-00000000000b',
        'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/b3.jpg', 2, now());
reset role;

-- ================================================================ the storage allowance
-- B already used 100 MB elsewhere.
insert into storage.objects (bucket_id, name, owner, metadata) values
  ('photos', 'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000009/big.jpg',
   'b0000000-0000-0000-0000-00000000000b', '{"size": 104857600}');

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  (select used_bytes from public.my_storage_usage()) >= 104857600
    and (select quota_bytes from public.my_storage_usage()) = 104857600,
  'B can see how much of their allowance is used'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/over.jpg', 'b0000000-0000-0000-0000-00000000000b')$q$,
    '42501'
  ),
  'a person at their allowance cannot upload more'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  (select used_bytes from public.my_storage_usage()) < 104857600
    and pg_temp.rows_changed(
      $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'a0000000-0000-0000-0000-00000000000a/60000000-0000-0000-0000-000000000001/ok.jpg', 'a0000000-0000-0000-0000-00000000000a')$q$
    ) = 1,
  'everyone has their own allowance: A can still upload'
);
select pg_temp.check(
  (select used_bytes from public.my_storage_usage()) >= 0
    and (select count(*) from public.my_storage_usage()) = 1,
  'the usage numbers are about the caller only'
);
select pg_temp.check(
  pg_temp.rows_changed(
    $q$update storage.objects set metadata = '{"size": 1000}' where name = 'a0000000-0000-0000-0000-00000000000a/60000000-0000-0000-0000-000000000001/ok.jpg'$q$
  ) = 1,
  'A, under the allowance, can replace a file with a bigger one'
);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  pg_temp.is_refused(
    $q$update storage.objects set metadata = '{"size": 1000}' where name = 'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/b3.jpg'$q$,
    '42501'
  ),
  'a person at their allowance cannot grow a file by replacing it'
);
select pg_temp.check(
  pg_temp.rows_changed(
    $q$update storage.objects set metadata = '{"size": 0}' where name = 'b0000000-0000-0000-0000-00000000000b/60000000-0000-0000-0000-000000000001/b3.jpg'$q$
  ) = 1,
  'but replacing a file with one no bigger is still fine'
);
reset role;

-- ================================================================ leaving, removing, coming back
insert into storage.objects (bucket_id, name, owner) values
  ('photos', 'd0000000-0000-0000-0000-00000000000d/60000000-0000-0000-0000-000000000001/d1.jpg', 'd0000000-0000-0000-0000-00000000000d');

select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  pg_temp.rows_changed(
    $q$update storage.objects set name = 'd0000000-0000-0000-0000-00000000000d/60000000-0000-0000-0000-000000000001/d1b.jpg' where name like 'd0000000-%/d1.jpg'$q$
  ) = 1,
  'while in the quest, D can replace a file they added'
);
select pg_temp.check(
  pg_temp.rows_changed(
    $q$delete from public.quest_participants where quest_id = '40000000-0000-0000-0000-000000000001'$q$
  ) = 1,
  'D can leave the quest'
);
select pg_temp.check(
  pg_temp.rows_changed(
    $q$update storage.objects set name = 'd0000000-0000-0000-0000-00000000000d/60000000-0000-0000-0000-000000000001/d1.jpg' where name like 'd0000000-%/d1b.jpg'$q$
  ) = 0,
  'after leaving, D can no longer replace the files they added'
);
select pg_temp.check(
  (select count(*) from public.memories) = 0 and (select count(*) from public.quests) = 0,
  'and then sees nothing of it'
);
reset role;

select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select set_config('test.kind', public.redeem_invite(current_setting('test.code')) ->> 'kind', true);
select pg_temp.check(
  current_setting('test.kind') = 'quest'
    and (select status from public.quest_participants where user_id = 'c0000000-0000-0000-0000-00000000000c') = 'invited',
  'with room again, C can be invited again after declining'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  pg_temp.rows_changed(
    $q$delete from public.quest_participants where user_id = 'c0000000-0000-0000-0000-00000000000c'$q$
  ) = 1,
  'A can remove a participant'
);
reset role;

-- ================================================================ codes that stop working
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select set_config('test.revoked', public.create_quest_invite('40000000-0000-0000-0000-000000000001'), true);
select set_config('test.expiring', public.create_quest_invite('40000000-0000-0000-0000-000000000001'), true);
select set_config('test.once', public.create_quest_invite('40000000-0000-0000-0000-000000000001', 7, 1), true);
reset role;

select set_config(
  'test.revoked_id',
  (select id::text from public.quest_invites
   where code_hash = private.hash_invite_code(replace(current_setting('test.revoked'), '-', ''))),
  true
);
update public.quest_invites set expires_at = now() - interval '1 minute'
where code_hash = private.hash_invite_code(replace(current_setting('test.expiring'), '-', ''));

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  pg_temp.rows_changed(
    $q$update public.quest_invites set revoked_at = now() where id = current_setting('test.revoked_id')::uuid$q$
  ) = 1,
  'A can revoke a quest code'
);
select pg_temp.check(
  public.redeem_invite(current_setting('test.code')) is null,
  'the owner cannot use their own code'
);
reset role;

select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  public.redeem_invite(current_setting('test.revoked')) is null
    and public.redeem_invite(current_setting('test.expiring')) is null,
  'revoked and expired quest codes do not work'
);
select pg_temp.check(
  public.redeem_invite(current_setting('test.once')) ->> 'kind' = 'quest',
  'a one-use code works once'
);
reset role;

select pg_temp.act_as('f0000000-0000-0000-0000-00000000000f');
select pg_temp.check(
  public.redeem_invite(current_setting('test.once')) is null,
  'and then no longer'
);
reset role;

-- ================================================================ guessing is throttled across both kinds
select pg_temp.act_as('e0000000-0000-0000-0000-00000000000e');
do $$
declare i integer;
begin
  for i in 1..10 loop
    if public.redeem_invite('ZZZZZ-ZZZZZ') is not null then
      raise exception 'FAILED: a wrong code worked';
    end if;
  end loop;
end $$;
select pg_temp.check(
  pg_temp.is_refused($q$select public.redeem_invite('ZZZZZ-ZZZZZ')$q$, '54000')
    and pg_temp.is_refused($q$select public.redeem_invite(current_setting('test.paircode'))$q$, '54000')
    and pg_temp.is_refused($q$select public.redeem_memory_invite(current_setting('test.memcode'))$q$, '54000'),
  'after 10 wrong tries the account waits, for every kind of code'
);
reset role;

-- ================================================================ signed out
select pg_temp.act_as_anon();
select pg_temp.check(
  pg_temp.is_refused($q$select * from public.quest_participants$q$, '42501')
    and pg_temp.is_refused($q$select * from public.quest_invites$q$, '42501')
    and pg_temp.is_refused($q$select public.redeem_invite('ABCDE-FGHJK')$q$, '42501')
    and pg_temp.is_refused($q$select public.create_quest_invite('40000000-0000-0000-0000-000000000001')$q$, '42501')
    and pg_temp.is_refused($q$select public.respond_to_quest_invitation('40000000-0000-0000-0000-000000000001', true)$q$, '42501')
    and pg_temp.is_refused($q$select * from public.my_storage_usage()$q$, '42501'),
  'signed-out visitors can do none of it'
);
reset role;

-- ================================================================ avatars between people on a quest
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  (select count(*) from storage.objects where bucket_id = 'avatars') = 1,
  'a participant can see the owner''s avatar'
);
reset role;
select pg_temp.act_as('e0000000-0000-0000-0000-00000000000e');
select pg_temp.check(
  (select count(*) from storage.objects where bucket_id = 'avatars') = 0,
  'a stranger cannot'
);
reset role;

-- ================================================================ deleting accounts
-- A participant leaving the app removes what they added, not the owner's memory.
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select public.delete_my_account();
reset role;
select pg_temp.check(
  not exists (select 1 from public.photos where id = '70000000-0000-0000-0000-000000000004')
    and not exists (select 1 from public.quest_participants where user_id = 'b0000000-0000-0000-0000-00000000000b')
    and exists (select 1 from public.memories where id = '60000000-0000-0000-0000-000000000001')
    and exists (select 1 from public.quests where id = '40000000-0000-0000-0000-000000000001'),
  'deleting a participant''s account removes their photos and place, not the owner''s memory'
);

-- The owner leaving takes the quests, invitations and memories with them.
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select public.delete_my_account();
reset role;
select pg_temp.check(
  (select count(*) from public.quests where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.quest_participants where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.quest_invites where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.memories where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.photos where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0,
  'deleting the owner''s account deletes the quests, invitations and memories'
);

rollback;

select 'all quest participation and allowance checks passed' as result;
