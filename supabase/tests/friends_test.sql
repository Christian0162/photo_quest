-- Photo Quest: friend codes, friend requests, and inviting friends directly.
--
-- Run AFTER all migrations, in the Supabase SQL editor or with
-- psql -v ON_ERROR_STOP=1 -f friends_test.sql. One transaction, rolled back;
-- any failed check stops the script, and reaching the final SELECT means
-- everything passed.
--
-- Cast: A and B become friends. C also befriends A. D asks A and is declined.
-- E and D ask each other at the same time. F is a stranger who guesses codes.

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

-- 42501 permission / RLS, 22023 bad value, P0002 not found, 54000 throttled,
-- 53400 quest full, 55000 not pending.
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
update public.profiles set display_name = 'Eli'  where id = 'e0000000-0000-0000-0000-00000000000e';

insert into storage.objects (bucket_id, name, owner, metadata) values
  ('avatars', 'a0000000-0000-0000-0000-00000000000a/avatar.jpg',
   'a0000000-0000-0000-0000-00000000000a', '{"size": 1000}');

select pg_temp.check(
  (select count(*) from public.profiles where friend_code ~ '^[0-9A-HJKMNP-TV-Z]{10}$') = 6
    and (select count(distinct friend_code) from public.profiles) = 6,
  'every account gets its own friend code'
);

-- ================================================================ friend codes are private
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  pg_temp.is_refused($q$select friend_code from public.profiles$q$, '42501')
    and pg_temp.is_refused($q$select * from public.profiles$q$, '42501'),
  'nobody can read friend codes straight from the table'
);
select pg_temp.check(
  pg_temp.is_refused($q$update public.profiles set friend_code = 'AAAAAAAAAA'$q$, '42501'),
  'and nobody can set their own'
);
select set_config('test.a_code', public.my_friend_code(), true);
select pg_temp.check(
  current_setting('test.a_code') ~ '^[0-9A-HJKMNP-TV-Z]{10}$',
  'the owner can read their own code'
);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select set_config('test.b_code', public.my_friend_code(), true);
select pg_temp.check(
  current_setting('test.b_code') <> current_setting('test.a_code'),
  'everyone''s code is different'
);
reset role;

-- A resets their code: the old one stops working at once.
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select set_config('test.a_old', current_setting('test.a_code'), true);
select set_config('test.a_code', public.reset_friend_code(), true);
select pg_temp.check(
  current_setting('test.a_code') <> current_setting('test.a_old')
    and public.my_friend_code() = current_setting('test.a_code'),
  'resetting gives a new code'
);
reset role;

select pg_temp.act_as('f0000000-0000-0000-0000-00000000000f');
select pg_temp.check(
  public.request_friend(current_setting('test.a_old')) is null,
  'the old code no longer works'
);
select pg_temp.check(
  (select count(*) from public.friendships) = 0,
  'and made no request'
);
reset role;

-- ================================================================ a friend request
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  public.request_friend(' ' || lower(substr(current_setting('test.b_code'), 1, 5)) || '-' || substr(current_setting('test.b_code'), 6) || ' ') ->> 'status' = 'pending',
  'A asks B with their code (case and dash forgiven)'
);
select pg_temp.check(
  public.request_friend(current_setting('test.b_code')) ->> 'name' = 'Bo',
  'the answer names who it was for, and asking again is harmless'
);
select pg_temp.check(
  (select count(*) from public.friendships) = 1,
  'only one request exists'
);
select pg_temp.check(
  public.request_friend(current_setting('test.a_code')) is null,
  'your own code does nothing'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.respond_to_friend_request('b0000000-0000-0000-0000-00000000000b', true)$q$, '55000'),
  'the person who asked cannot answer for the other'
);
select pg_temp.check(
  (select display_name from public.profiles where id = 'b0000000-0000-0000-0000-00000000000b') = 'Bo',
  'A can see who they asked while it is open'
);
select pg_temp.check(
  pg_temp.is_refused($q$insert into public.friendships (requester_id, addressee_id) values ('a0000000-0000-0000-0000-00000000000a', 'c0000000-0000-0000-0000-00000000000c')$q$, '42501')
    and pg_temp.is_refused($q$update public.friendships set status = 'accepted'$q$, '42501'),
  'requests can only be made and answered through the functions'
);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  (select count(*) from public.friendships) = 1
    and (select display_name from public.profiles where id = 'a0000000-0000-0000-0000-00000000000a') = 'Alex',
  'B sees the request and who sent it'
);
select pg_temp.check(
  (select count(*) from storage.objects where bucket_id = 'avatars') = 1,
  'and their photo, so they know who is asking'
);
reset role;

select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  (select count(*) from public.friendships) = 0
    and (select count(*) from public.profiles) = 1,
  'a stranger sees neither the request nor either person'
);
reset role;

-- Before they are friends, nothing can be sent directly.
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
insert into public.quests (id, owner_id, title, category, type, max_participants) values
  ('40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', 'Family day', 'For Family', 'group', 3),
  ('40000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-00000000000a', 'Date night', 'For Us', 'pair', 2),
  ('40000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-00000000000a', 'Just me', 'For Me', 'solo', null);
insert into public.memories (id, owner_id, title, captured_at)
values ('60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a', 'Our day', now());
select pg_temp.check(
  pg_temp.is_refused($q$select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b')$q$, '42501')
    and pg_temp.is_refused($q$select public.share_memory_with_friend('60000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b')$q$, '42501'),
  'a pending request is not a friendship'
);
reset role;

-- ================================================================ B says yes
select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select public.respond_to_friend_request('a0000000-0000-0000-0000-00000000000a', true);
select pg_temp.check(
  (select status from public.friendships) = 'accepted',
  'B accepts'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.respond_to_friend_request('a0000000-0000-0000-0000-00000000000a', true)$q$, '55000'),
  'a request can only be answered once'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  (select status from public.friendships) = 'accepted'
    and (select display_name from public.profiles where id = 'b0000000-0000-0000-0000-00000000000b') = 'Bo',
  'A sees them as friends'
);
reset role;

-- ================================================================ inviting a friend directly
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b');
select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  (select count(*) from public.quest_participants where status = 'invited') = 1,
  'a friend is invited to a quest, once'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-00000000000b')$q$, '22023'),
  'but not to a quest you do alone'
);
select public.share_memory_with_friend('60000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b');
select public.share_memory_with_friend('60000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  (select count(*) from public.memory_shares) = 1,
  'a friend is given a memory, once'
);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  (select count(*) from public.quests where id = '40000000-0000-0000-0000-000000000001') = 1
    and (select count(*) from public.memories where id = '60000000-0000-0000-0000-000000000001') = 1,
  'B sees the invited quest and the shared memory'
);
select public.respond_to_quest_invitation('40000000-0000-0000-0000-000000000001', true);
select pg_temp.check(
  (select status from public.quest_participants where user_id = 'b0000000-0000-0000-0000-00000000000b') = 'accepted',
  'B still chooses to accept the quest'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a')$q$, 'P0002')
    and pg_temp.is_refused($q$select public.share_memory_with_friend('60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a')$q$, 'P0002'),
  'only the owner can invite or share'
);
reset role;

-- C becomes A's friend too; the pair quest has room for just one.
select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  public.request_friend(current_setting('test.a_code')) ->> 'status' = 'pending',
  'C asks A'
);
reset role;
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select public.respond_to_friend_request('c0000000-0000-0000-0000-00000000000c', true);
select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  pg_temp.is_refused($q$select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-00000000000c')$q$, '53400'),
  'a full quest turns a friend away too'
);
reset role;

-- ================================================================ declining
select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  public.request_friend(current_setting('test.a_code')) ->> 'status' = 'pending',
  'D asks A'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select public.respond_to_friend_request('d0000000-0000-0000-0000-00000000000d', false);
select pg_temp.check(
  (select count(*) from public.friendships where status = 'declined') = 1
    and (select display_name from public.profiles where id = 'd0000000-0000-0000-0000-00000000000d') = 'Dee',
  'A declined, and still sees who asked'
);
reset role;

select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  (select count(*) from public.friendships) = 0
    and not exists (select 1 from public.profiles where id = 'a0000000-0000-0000-0000-00000000000a'),
  'D is not told, and sees nothing of A'
);
select pg_temp.check(
  public.request_friend(current_setting('test.a_code')) ->> 'status' = 'pending',
  'asking again just looks pending'
);
reset role;
select pg_temp.check(
  (select count(*) from public.friendships where status = 'declined') = 1
    and (select count(*) from public.friendships) = 3,
  'and changes nothing'
);

-- A can still change their mind by entering D's code.
select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select set_config('test.d_code', public.my_friend_code(), true);
reset role;
select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  public.request_friend(current_setting('test.d_code')) ->> 'status' = 'accepted',
  'the person who declined can say yes later by entering the code'
);
reset role;

-- ================================================================ asking each other at once
select pg_temp.act_as('e0000000-0000-0000-0000-00000000000e');
select set_config('test.e_code', public.my_friend_code(), true);
reset role;
select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select pg_temp.check(
  public.request_friend(current_setting('test.e_code')) ->> 'status' = 'pending',
  'D asks E'
);
reset role;
select pg_temp.act_as('e0000000-0000-0000-0000-00000000000e');
select pg_temp.check(
  public.request_friend(current_setting('test.d_code')) ->> 'status' = 'accepted',
  'E asking D back makes them friends straight away'
);
reset role;

-- ================================================================ guessing is throttled
select pg_temp.act_as('f0000000-0000-0000-0000-00000000000f');
select pg_temp.check(
  public.request_friend('nonsense') is null and public.request_friend(null) is null,
  'wrong codes just return null'
);
do $$
declare i integer;
begin
  for i in 1..7 loop
    if public.request_friend('ZZZZZ-ZZZZZ') is not null then
      raise exception 'FAILED: a wrong code worked';
    end if;
  end loop;
end $$;
select pg_temp.check(
  pg_temp.is_refused($q$select public.request_friend('ZZZZZ-ZZZZZ')$q$, '54000')
    and pg_temp.is_refused($q$select public.request_friend(current_setting('test.a_code'))$q$, '54000'),
  'after 10 wrong tries the account waits, even with a right code'
);
select pg_temp.check(
  pg_temp.is_refused($q$select public.redeem_invite(current_setting('test.a_code'))$q$, '54000'),
  'and the wait covers invite codes too'
);
reset role;

-- ================================================================ unfriending
select pg_temp.act_as('c0000000-0000-0000-0000-00000000000c');
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.friendships where requester_id = 'a0000000-0000-0000-0000-00000000000a' or addressee_id = 'a0000000-0000-0000-0000-00000000000a'$q$) = 1,
  'C can only remove their own friendship with A'
);
reset role;

select pg_temp.act_as('b0000000-0000-0000-0000-00000000000b');
select pg_temp.check(
  pg_temp.rows_changed($q$delete from public.friendships where requester_id = 'a0000000-0000-0000-0000-00000000000a'$q$) = 1,
  'B can unfriend A'
);
reset role;

select pg_temp.act_as('a0000000-0000-0000-0000-00000000000a');
select pg_temp.check(
  pg_temp.is_refused($q$select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b')$q$, '42501')
    and pg_temp.is_refused($q$select public.share_memory_with_friend('60000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000000b')$q$, '42501'),
  'after unfriending, nothing more can be sent directly'
);
reset role;

-- ================================================================ signed out
select pg_temp.act_as_anon();
select pg_temp.check(
  pg_temp.is_refused($q$select * from public.friendships$q$, '42501')
    and pg_temp.is_refused($q$select public.my_friend_code()$q$, '42501')
    and pg_temp.is_refused($q$select public.reset_friend_code()$q$, '42501')
    and pg_temp.is_refused($q$select public.request_friend('ABCDE-FGHJK')$q$, '42501')
    and pg_temp.is_refused($q$select public.respond_to_friend_request('a0000000-0000-0000-0000-00000000000a', true)$q$, '42501')
    and pg_temp.is_refused($q$select public.invite_friend_to_quest('40000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a')$q$, '42501')
    and pg_temp.is_refused($q$select public.share_memory_with_friend('60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-00000000000a')$q$, '42501'),
  'signed-out visitors can do none of it'
);
reset role;

-- ================================================================ deleting an account
select pg_temp.act_as('d0000000-0000-0000-0000-00000000000d');
select public.delete_my_account();
reset role;
select pg_temp.check(
  not exists (
    select 1 from public.friendships
    where requester_id = 'd0000000-0000-0000-0000-00000000000d'
       or addressee_id = 'd0000000-0000-0000-0000-00000000000d'
  )
    and exists (select 1 from public.profiles where id = 'a0000000-0000-0000-0000-00000000000a'),
  'deleting an account removes their friendships and nobody else'
);

rollback;

select 'all friends checks passed' as result;
