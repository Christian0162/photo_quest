-- Photo Quest: let a person delete their own account.
--
-- App stores expect in-app account deletion, and a signed-in client cannot
-- delete itself from auth.users. This function does exactly that for the
-- CALLER only: it takes the id from the session, never from an argument, so
-- it can't be pointed at someone else.
--
-- Deleting the auth user cascades to their profile and from there to every
-- quest, session, memory, photo row, share and invite they own. Memories they
-- shared are deleted with them, by design.
--
-- Storage files are NOT removed by cascades. Before calling this, the app
-- must delete the person's files through the Storage API (their own delete
-- policies allow it): everything under <user id>/ in `photos` and `avatars`.

create function public.delete_my_account()
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

  delete from auth.users where id = caller;
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

comment on function public.delete_my_account() is
  'Deletes the caller''s account and, by cascade, all their data. Delete their Storage files first.';
