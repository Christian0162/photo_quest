-- Photo Quest: remember which 360 clips are shown mirrored.
--
-- On the device, a clip recorded with the front camera is flipped when it is
-- shown so it matches the preview. A friend viewing the shared copy needs the
-- same flag. It is set when a memory is uploaded and never changed after
-- (no UPDATE grant), like the other photo facts.

alter table public.photos
  add column mirrored boolean not null default false;

grant insert (mirrored) on public.photos to authenticated;

comment on column public.photos.mirrored is
  'True when the clip is flipped left-right as it is shown, to match the preview.';
