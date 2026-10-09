-- Photo Quest: Row Level Security and Storage policy checks.
--
-- Run AFTER both migrations, in the Supabase SQL editor (as the default
-- postgres role) or with psql -v ON_ERROR_STOP=1 -f rls_test.sql.
-- Everything happens in one transaction that is rolled back, so no data is
-- left behind. Any failed check raises an exception and stops the script;
-- reaching the final SELECT means every check passed.

begin;

-- Helpers (temporary: gone when the session ends).
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

-- Runs a statement and reports whether it was refused with one of the
-- expected SQLSTATEs (42501 = permission denied / RLS violation,
-- 23514 = check violation).
create function pg_temp.is_refused(stmt text, variadic states text[]) returns boolean
language plpgsql as $$
begin
  execute stmt;
  return false;
exception when others then
  return sqlstate = any (states);
end;
$$;

-- Rows touched by a statement.
create function pg_temp.rows_changed(stmt text) returns bigint
language plpgsql as $$
declare n bigint;
begin
  execute stmt;
  get diagnostics n = row_count;
  return n;
end;
$$;

-- Fixtures: two accounts and one stored avatar each (created as the owner).
insert into auth.users (id, email) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'a@example.com'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'b@example.com');

insert into storage.objects (bucket_id, name, owner) values
  ('avatars', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/avatar.jpg', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  ('avatars', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/avatar.jpg', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');

select pg_temp.check(
  (select count(*) from public.profiles) = 2,
  'signing up creates a profile for each account'
);
select pg_temp.check(
  (select public from storage.buckets where id = 'avatars') = false,
  'avatars bucket is private'
);

-- ===== PROFILES =====

-- Signed out (anon) gets nothing.
select pg_temp.act_as_anon();
select pg_temp.check(
  pg_temp.is_refused('select * from public.profiles', '42501'),
  'anon cannot read profiles'
);
reset role;

-- Account A.
select pg_temp.act_as('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

select pg_temp.check(
  (select count(*) from public.profiles) = 1
    and (select id from public.profiles) = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'A sees only A''s profile'
);
select pg_temp.check(
  pg_temp.rows_changed(
    'update public.profiles set display_name = ''Alex'' where id = ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'''
  ) = 1,
  'A can update A''s display name'
);
select pg_temp.check(
  pg_temp.rows_changed(
    'update public.profiles set display_name = ''Hacked'' where id = ''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'''
  ) = 0,
  'A cannot update B''s profile'
);
select pg_temp.check(
  pg_temp.is_refused(
    'update public.profiles set id = ''cccccccc-cccc-cccc-cccc-cccccccccccc'' where id = ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa''',
    '42501'
  ),
  'A cannot change a profile id'
);
select pg_temp.check(
  pg_temp.is_refused(
    'update public.profiles set avatar_path = ''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/avatar.jpg'' where id = ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa''',
    '23514'
  ),
  'A cannot point their avatar at B''s file'
);
select pg_temp.check(
  pg_temp.is_refused(
    'update public.profiles set display_name = '''' where id = ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa''',
    '23514'
  ),
  'empty display name is refused'
);
select pg_temp.check(
  pg_temp.is_refused(
    'insert into public.profiles (id) values (''cccccccc-cccc-cccc-cccc-cccccccccccc'')',
    '42501'
  ),
  'clients cannot insert profiles'
);
select pg_temp.check(
  pg_temp.is_refused('delete from public.profiles', '42501'),
  'clients cannot delete profiles'
);

-- ===== STORAGE (avatars) =====

select pg_temp.check(
  (select count(*) from storage.objects where bucket_id = 'avatars') = 1
    and (select name from storage.objects where bucket_id = 'avatars')
        = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/avatar.jpg',
  'A can list only A''s avatar files'
);
select pg_temp.check(
  pg_temp.rows_changed(
    'insert into storage.objects (bucket_id, name, owner) values (''avatars'', ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/avatar_2.jpg'', ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'')'
  ) = 1,
  'A can upload into A''s folder'
);
select pg_temp.check(
  pg_temp.is_refused(
    'insert into storage.objects (bucket_id, name, owner) values (''avatars'', ''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/evil.jpg'', ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'')',
    '42501'
  ),
  'A cannot upload into B''s folder'
);
select pg_temp.check(
  pg_temp.is_refused(
    'insert into storage.objects (bucket_id, name, owner) values (''avatars'', ''loose.jpg'', ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'')',
    '42501'
  ),
  'A cannot upload outside any user folder'
);
select pg_temp.check(
  pg_temp.rows_changed(
    'update storage.objects set name = ''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/avatar.jpg'' where name = ''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/avatar.jpg'''
  ) = 0,
  'A cannot overwrite B''s file'
);
select pg_temp.check(
  pg_temp.is_refused(
    'update storage.objects set name = ''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/moved.jpg'' where name = ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/avatar.jpg''',
    '42501'
  ),
  'A cannot move A''s file into B''s folder'
);
select pg_temp.check(
  pg_temp.rows_changed(
    'delete from storage.objects where name = ''bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/avatar.jpg'''
  ) = 0,
  'A cannot delete B''s file'
);
select pg_temp.check(
  pg_temp.rows_changed(
    'delete from storage.objects where name = ''aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa/avatar_2.jpg'''
  ) = 1,
  'A can delete A''s file'
);
reset role;

-- Anon cannot touch storage either.
select pg_temp.act_as_anon();
select pg_temp.check(
  pg_temp.is_refused('select * from storage.objects', '42501')
    or (select count(*) from storage.objects) = 0,
  'anon cannot read avatar files'
);
reset role;

-- Account B still has everything A could not touch.
select pg_temp.act_as('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');
select pg_temp.check(
  (select display_name from public.profiles) is null,
  'B''s profile was not changed by A'
);
select pg_temp.check(
  (select count(*) from storage.objects where bucket_id = 'avatars') = 1,
  'B''s avatar file is intact'
);
reset role;

rollback;

select 'all RLS and storage checks passed' as result;
