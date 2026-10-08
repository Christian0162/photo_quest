-- Photo Quest: policy checks for quests, memories, photos, sharing, invites
-- and the photos bucket.
--
-- Run AFTER all migrations (and after rls_test.sql if you like), in the
-- Supabase SQL editor or with psql -v ON_ERROR_STOP=1 -f cloud_sharing_test.sql.
-- One transaction, rolled back at the end; a failed check raises an exception
-- and stops the script. Reaching the final SELECT means everything passed.
--
-- Cast: A owns the memories. B joins with a code. C and D are strangers. E is
-- used only for the guessing throttle.

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

-- True when the statement is refused with one of the SQLSTATEs.
-- 42501 permission denied / RLS, 23503 foreign key, 23514 check,
-- 23505 unique, P0002 not found, 54000 throttled.
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
  ('e0000000-0000-0000-0000-00000000000e', 'e@example.com');

update public.profiles set display_name = 'Alex'
  where id = 'a0000000-0000-0000-0000-00000000000a';
update public.profiles set display_name = 'Bo'
  where id = 'b0000000-0000-0000-0000-00000000000b';
update public.profiles set display_name = 'Cass'
  where id = 'c0000000-0000-0000-0000-00000000000c';

-- Stored files (created as the owner of the database).
insert into storage.objects (bucket_id, name, owner) values
  ('photos', 'a0000000-0000-0000-0000-00000000000a/11111111-1111-1111-1111-111111111111/p1.jpg', 'a0000000-0000-0000-0000-00000000000a'),
  ('photos', 'a0000000-0000-0000-0000-00000000000a/22222222-2222-2222-2222-222222222222/p9.jpg', 'a0000000-0000-0000-0000-00000000000a'),
  ('avatars', 'a0000000-0000-0000-0000-00000000000a/avatar.jpg', 'a0000000-0000-0000-0000-00000000000a');

select pg_temp.check(
  (select public from storage.buckets where id = 'photos') = false,
  'photos bucket is private'
);

-- ================================================================ A's data
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');

insert into public.quests (id, owner_id, title, category, type)
values ('44444444-4444-4444-4444-444444444444', 'a0000000-0000-0000-0000-00000000000a', 'Anniversary', 'For Us', 'pair');
insert into public.quest_shots (id, quest_id, owner_id, position, instruction, shot_type)
values ('77777777-7777-7777-7777-777777777777', '44444444-4444-4444-4444-444444444444', 'a0000000-0000-0000-0000-00000000000a', 0, 'Stand close', 'group');
insert into public.quest_sessions (id, quest_id, owner_id, started_at)
values ('66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444', 'a0000000-0000-0000-0000-00000000000a', now());
insert into public.memories (id, owner_id, quest_session_id, title, captured_at)
values ('11111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-00000000000a', '66666666-6666-6666-6666-666666666666', 'Our day', now());
insert into public.memories (id, owner_id, title, captured_at)
values ('22222222-2222-2222-2222-222222222222', 'a0000000-0000-0000-0000-00000000000a', 'Private one', now());
insert into public.photos (id, memory_id, owner_id, uploaded_by, shot_id, storage_path, position, captured_at)
values
  ('88888888-8888-8888-8888-888888888888', '11111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-00000000000a', 'a0000000-0000-0000-0000-00000000000a', '77777777-7777-7777-7777-777777777777',
   'a0000000-0000-0000-0000-00000000000a/11111111-1111-1111-1111-111111111111/p1.jpg', 0, now()),
  ('99999999-9999-9999-9999-999999999999', '11111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-00000000000a', 'a0000000-0000-0000-0000-00000000000a', null,
   'a0000000-0000-0000-0000-00000000000a/11111111-1111-1111-1111-111111111111/p2.jpg', 1, now()),
  ('abababab-abab-abab-abab-abababababab', '22222222-2222-2222-2222-222222222222', 'a0000000-0000-0000-0000-00000000000a', 'a0000000-0000-0000-0000-00000000000a', null,
   'a0000000-0000-0000-0000-00000000000a/22222222-2222-2222-2222-222222222222/p9.jpg', 0, now());

select pg_temp.check(
  pg_temp.rows_changed($q$update public.memories set cover_photo_id = '88888888-8888-8888-8888-888888888888' where id = '11111111-1111-1111-1111-111111111111'$q$) = 1,
  'A can set a cover photo that belongs to the memory'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$update public.memories set cover_photo_id = 'abababab-abab-abab-abab-abababababab' where id = '11111111-1111-1111-1111-111111111111'$q$,
    '23503'
  ),
  'a cover photo from another memory is refused'
);
select pg_temp.check(
  pg_temp.rows_changed(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at, mirrored)
       values ('11111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-00000000000a', 'a0000000-0000-0000-0000-00000000000a',
               'a0000000-0000-0000-0000-00000000000a/11111111-1111-1111-1111-111111111111/clip.mp4', 8, now(), true)$q$
  ) = 1,
  'a photo can be stored as mirrored'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$update public.photos set mirrored = false where position = 8$q$,
    '42501'
  ),
  'mirrored cannot be changed after upload'
);
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.photos where position = 8$q$) = 1,
  'A can delete their own photo row'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.quests (owner_id, title, category, type) values ('b0000000-0000-0000-0000-00000000000b', 'x', 'x', 'solo')$q$,
    '42501'
  ),
  'A cannot create a quest owned by B'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.quests (owner_id, title, category, type) values ('a0000000-0000-0000-0000-00000000000a', 'x', 'x', 'crowd')$q$,
    '23514'
  ),
  'an unknown quest type is refused'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$update public.memories set owner_id = 'b0000000-0000-0000-0000-00000000000b' where id = '11111111-1111-1111-1111-111111111111'$q$,
    '42501'
  ),
  'ownership of a memory cannot be changed'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('11111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-00000000000a', 'a0000000-0000-0000-0000-00000000000a',
               'b0000000-0000-0000-0000-00000000000b/11111111-1111-1111-1111-111111111111/x.jpg', 5, now())$q$,
    '23514'
  ),
  'a photo cannot point into another person''s folder'
);

-- A invite code for memory 1 (kept in a transaction setting for later steps).
select set_config(
  'test.code',
  public.create_memory_invite('11111111-1111-1111-1111-111111111111'),
  true
);
select pg_temp.check(
  current_setting('test.code') ~ '^[0-9A-HJKMNP-TV-Z]{5}-[0-9A-HJKMNP-TV-Z]{5}$',
  'invite codes look like ABCDE-FGHJK'
);
select pg_temp.check(
  pg_temp.is_refused($q$select code_hash from public.memory_invites$q$, '42501'),
  'the code hash is not readable'
);
select pg_temp.check(
  pg_temp.is_refused($q$select * from public.memory_invites$q$, '42501'),
  'select * on invites is refused because of the hash column'
);
select pg_temp.check(
  (select count(*) from public.memory_invites) = 1,
  'A can list their own invites'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.memory_invites (memory_id, owner_id, code_hash, expires_at, max_uses)
       values ('11111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-00000000000a', 'weak', now() + interval '1 day', 5)$q$,
    '42501'
  ),
  'clients cannot insert invites with codes of their own'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$select public.create_memory_invite('11111111-1111-1111-1111-111111111111', 99, 5)$q$,
    '22023'
  ),
  'invite settings are bounded'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$update public.memory_invites set use_count = 0$q$,
    '42501'
  ),
  'A cannot edit an invite''s use count'
);
select pg_temp.check(
  public.redeem_memory_invite(current_setting('test.code')) is null,
  'the owner cannot redeem their own code'
);
reset role;

-- ================================================================ B's data
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
insert into public.quests (id, owner_id, title, category, type)
values ('55555555-5555-5555-5555-555555555555', 'b0000000-0000-0000-0000-00000000000b', 'Bo''s quest', 'For Me', 'solo');
insert into public.memories (id, owner_id, title, captured_at)
values ('33333333-3333-3333-3333-333333333333', 'b0000000-0000-0000-0000-00000000000b', 'Bo''s memory', now());

select pg_temp.check(
  pg_temp.is_refused(
    $q$select public.create_memory_invite('11111111-1111-1111-1111-111111111111')$q$,
    'P0002'
  ),
  'B cannot make an invite for A''s memory'
);
select pg_temp.check(
  (select count(*) from public.memories) = 1
    and (select count(*) from public.photos) = 0
    and (select count(*) from public.profiles) = 1,
  'before joining, B sees only their own data'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.quest_shots (quest_id, owner_id, position, instruction, shot_type)
       values ('55555555-5555-5555-5555-555555555555', 'a0000000-0000-0000-0000-00000000000a', 0, 'Sneak', 'group')$q$,
    '23503'
  ),
  'A cannot attach a shot to B''s quest'
);
reset role;

-- ================================================================ strangers
select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  (select count(*) from public.memories) = 0
    and (select count(*) from public.photos) = 0
    and (select count(*) from public.quests) = 0,
  'a stranger sees nothing of A''s'
);
select pg_temp.check(
  public.redeem_memory_invite('ZZZZZ-ZZZZZ') is null
    and public.redeem_memory_invite('nonsense') is null
    and public.redeem_memory_invite(null) is null,
  'wrong codes just return null'
);
reset role;

-- ================================================================ B joins
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
-- Lowercase, spaces and a dash are forgiven.
select pg_temp.check(
  public.redeem_memory_invite(' ' || lower(current_setting('test.code')) || ' ')
    = '11111111-1111-1111-1111-111111111111',
  'B joins with the code (case and dash forgiven)'
);
select pg_temp.check(
  public.redeem_memory_invite(current_setting('test.code'))
    = '11111111-1111-1111-1111-111111111111',
  'redeeming twice is harmless'
);
select pg_temp.check(
  (select count(*) from public.memories where id = '11111111-1111-1111-1111-111111111111') = 1
    and (select count(*) from public.memories where id = '22222222-2222-2222-2222-222222222222') = 0,
  'B sees the shared memory but not A''s other one'
);
select pg_temp.check(
  (select count(*) from public.photos where memory_id = '11111111-1111-1111-1111-111111111111') = 2
    and (select count(*) from public.photos where memory_id = '22222222-2222-2222-2222-222222222222') = 0,
  'B sees the shared photos only'
);
select pg_temp.check(
  (select count(*) from public.quests where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.quest_sessions) = 0
    and (select count(*) from public.quest_shots) = 0,
  'B cannot see A''s quests, sessions or shots'
);
select pg_temp.check(
  (select count(*) from public.profiles) = 2
    and (select display_name from public.profiles where id = 'a0000000-0000-0000-0000-00000000000a') = 'Alex',
  'B can read the profile of whoever shared with them (and own)'
);
select pg_temp.check(
  (select count(*) from public.memory_shares) = 1,
  'B sees their own share row'
);
select pg_temp.check(
  pg_temp.rows_changed($q$update public.memories set title = 'Hacked' where id = '11111111-1111-1111-1111-111111111111'$q$) = 0,
  'a viewer cannot edit the memory'
);
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.memories where id = '11111111-1111-1111-1111-111111111111'$q$) = 0,
  'a viewer cannot delete the memory'
);
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.photos where memory_id = '11111111-1111-1111-1111-111111111111'$q$) = 0,
  'a viewer cannot delete photos'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('11111111-1111-1111-1111-111111111111', 'a0000000-0000-0000-0000-00000000000a', 'a0000000-0000-0000-0000-00000000000a',
               'a0000000-0000-0000-0000-00000000000a/11111111-1111-1111-1111-111111111111/b.jpg', 7, now())$q$,
    '42501'
  ),
  'a viewer cannot add photos as the owner'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.photos (memory_id, owner_id, uploaded_by, storage_path, position, captured_at)
       values ('11111111-1111-1111-1111-111111111111', 'b0000000-0000-0000-0000-00000000000b', 'b0000000-0000-0000-0000-00000000000b',
               'b0000000-0000-0000-0000-00000000000b/11111111-1111-1111-1111-111111111111/b.jpg', 7, now())$q$,
    '42501'
  ),
  'a viewer cannot add photos under their own name either'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into public.memory_shares (memory_id, owner_id, viewer_id)
       values ('33333333-3333-3333-3333-333333333333', 'b0000000-0000-0000-0000-00000000000b', 'c0000000-0000-0000-0000-00000000000c')$q$,
    '42501'
  ),
  'shares can only come from redeeming a code'
);
select pg_temp.check(
  pg_temp.is_refused($q$select * from private.invite_attempts$q$, '42501'),
  'the attempts table is not reachable'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  (select use_count from public.memory_invites) = 1,
  'redeeming twice used only one place'
);
select pg_temp.check(
  (select count(*) from public.memory_shares) = 1
    and (select display_name from public.profiles where id = 'b0000000-0000-0000-0000-00000000000b') = 'Bo',
  'the owner sees who can view, and their name'
);
select pg_temp.check(
  (select count(*) from public.profiles) = 2,
  'A sees only themself and B (not C)'
);
reset role;

-- ================================================ limits on a single code
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select set_config(
  'test.once',
  public.create_memory_invite('11111111-1111-1111-1111-111111111111', 7, 1),
  true
);
reset role;

select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  public.redeem_memory_invite(current_setting('test.once')) = '11111111-1111-1111-1111-111111111111',
  'a one-use code works once'
);
reset role;

select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  public.redeem_memory_invite(current_setting('test.once')) is null,
  'a used-up code no longer works'
);
select pg_temp.check(
  (select count(*) from public.memories) = 0,
  'and D still sees nothing'
);
reset role;

-- Expired and revoked codes.
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select set_config(
  'test.expiring',
  public.create_memory_invite('11111111-1111-1111-1111-111111111111'),
  true
);
select set_config(
  'test.revoked',
  public.create_memory_invite('11111111-1111-1111-1111-111111111111'),
  true
);
reset role;

-- As the database owner, find each invite by the hash of its code.
select set_config(
  'test.revoked_id',
  (select id::text from public.memory_invites
   where code_hash = private.hash_invite_code(replace(current_setting('test.revoked'), '-', ''))),
  true
);
update public.memory_invites set expires_at = now() - interval '1 minute'
where code_hash = private.hash_invite_code(replace(current_setting('test.expiring'), '-', ''));

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  pg_temp.rows_changed(
    $q$update public.memory_invites set revoked_at = now() where id = current_setting('test.revoked_id')::uuid$q$
  ) = 1,
  'A can revoke an invite'
);
reset role;

select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  public.redeem_memory_invite(current_setting('test.expiring')) is null,
  'an expired code does not work'
);
select pg_temp.check(
  public.redeem_memory_invite(current_setting('test.revoked')) is null,
  'a revoked code does not work'
);
reset role;

-- ================================================================ throttle
select pg_temp.act_as('e0000000-0000-0000-0000-00000000000e');
do $$
declare i integer;
begin
  for i in 1..10 loop
    if public.redeem_memory_invite('ZZZZZ-ZZZZZ') is not null then
      raise exception 'FAILED: a wrong code worked';
    end if;
  end loop;
end $$;
select pg_temp.check(
  pg_temp.is_refused($q$select public.redeem_memory_invite('ZZZZZ-ZZZZZ')$q$, '54000'),
  'after 10 wrong tries the account is asked to wait'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.redeem_memory_invite(current_setting('test.code'))$q$, '54000'),
  'even a right code waits while throttled'
);
reset role;

-- ================================================================ anonymous
select pg_temp.act_as_anon();
select pg_temp.check(
  pg_temp.is_refused($q$select * from public.memories$q$, '42501')
    and pg_temp.is_refused($q$select * from public.photos$q$, '42501')
    and pg_temp.is_refused($q$select * from public.memory_shares$q$, '42501'),
  'anon cannot read memories, photos or shares'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.redeem_memory_invite('ABCDE-FGHJK')$q$, '42501')
    and pg_temp.is_refused($q$select public.create_memory_invite('11111111-1111-1111-1111-111111111111')$q$, '42501')
    and pg_temp.is_refused($q$select public.delete_my_account()$q$, '42501'),
  'anon cannot call the sharing or account functions'
);
reset role;

-- ================================================================ files
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  pg_temp.rows_changed(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'a0000000-0000-0000-0000-00000000000a/11111111-1111-1111-1111-111111111111/p3.jpg', 'a0000000-0000-0000-0000-00000000000a')$q$
  ) = 1,
  'A can upload into one of their memories'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'a0000000-0000-0000-0000-00000000000a/99999999-0000-0000-0000-000000000000/x.jpg', 'a0000000-0000-0000-0000-00000000000a')$q$,
    '42501'
  ),
  'A cannot upload into a memory that does not exist'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'a0000000-0000-0000-0000-00000000000a/11111111-1111-1111-1111-111111111111/deeper/x.jpg', 'a0000000-0000-0000-0000-00000000000a')$q$,
    '42501'
  ),
  'files must sit directly in <owner>/<memory>/'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'b0000000-0000-0000-0000-00000000000b/33333333-3333-3333-3333-333333333333/x.jpg', 'a0000000-0000-0000-0000-00000000000a')$q$,
    '42501'
  ),
  'A cannot upload into B''s folder'
);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  (select count(*) from storage.objects where bucket_id = 'photos'
     and name like 'a0000000-0000-0000-0000-00000000000a/11111111-%') = 2,
  'B can read the photos files of the memory shared with them'
);
select pg_temp.check(
  (select count(*) from storage.objects where bucket_id = 'photos'
     and name like 'a0000000-0000-0000-0000-00000000000a/22222222-%') = 0,
  'B cannot read A''s other memory''s files'
);
select pg_temp.check(
  (select count(*) from storage.objects where bucket_id = 'avatars') = 1,
  'B can see A''s avatar (they are connected by a share)'
);
select pg_temp.check(
  pg_temp.is_refused(
    $q$insert into storage.objects (bucket_id, name, owner) values ('photos', 'a0000000-0000-0000-0000-00000000000a/11111111-1111-1111-1111-111111111111/b.jpg', 'b0000000-0000-0000-0000-00000000000b')$q$,
    '42501'
  ),
  'a viewer cannot upload into the owner''s folder'
);
select pg_temp.check(
  pg_temp.rows_changed(
    $q$delete from storage.objects where bucket_id = 'photos' and name like 'a0000000-0000-0000-0000-00000000000a/%'$q$
  ) = 0,
  'a viewer cannot delete the owner''s files'
);
reset role;

select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  (select count(*) from storage.objects where bucket_id in ('photos', 'avatars')) = 0,
  'a stranger can read none of A''s files or avatar'
);
reset role;

-- ================================================================ leaving
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.memory_shares where viewer_id = 'b0000000-0000-0000-0000-00000000000b'$q$) = 1,
  'a viewer can leave a shared memory'
);
select pg_temp.check(
  (select count(*) from public.memories where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from storage.objects where bucket_id = 'photos') = 0,
  'after leaving, B can no longer see the memory or its files'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.memory_shares where viewer_id = 'c0000000-0000-0000-0000-00000000000c'$q$) = 1,
  'the owner can remove a viewer'
);
reset role;

select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  (select count(*) from public.memories where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0,
  'a removed viewer loses access'
);
reset role;

-- ================================================================ deleting accounts
-- A viewer leaving the app does not delete the owner's memory.
select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select public.delete_my_account();
reset role;
select pg_temp.check(
  not exists (select 1 from auth.users where id = 'c0000000-0000-0000-0000-00000000000c')
    and not exists (select 1 from public.profiles where id = 'c0000000-0000-0000-0000-00000000000c')
    and exists (select 1 from public.memories where id = '11111111-1111-1111-1111-111111111111'),
  'deleting a viewer''s account leaves the owner''s memory alone'
);

-- The owner deleting their account takes their memories with them.
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select public.delete_my_account();
reset role;
select pg_temp.check(
  not exists (select 1 from auth.users where id = 'a0000000-0000-0000-0000-00000000000a')
    and (select count(*) from public.quests where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.quest_shots where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.quest_sessions where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.memories where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.photos where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.memory_invites where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0
    and (select count(*) from public.memory_shares where owner_id = 'a0000000-0000-0000-0000-00000000000a') = 0,
  'deleting the owner''s account deletes everything they owned'
);
select pg_temp.check(
  exists (select 1 from public.memories where id = '33333333-3333-3333-3333-333333333333')
    and exists (select 1 from public.profiles where id = 'b0000000-0000-0000-0000-00000000000b'),
  'and nobody else''s data is touched'
);

rollback;

select 'all cloud, sharing and storage checks passed' as result;
