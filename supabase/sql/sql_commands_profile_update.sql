-- Supabase SQL: profile fields for users + safe constraints.
-- Run after sql_commands_users.sql

alter table public.users
add column if not exists phone text;

alter table public.users
add column if not exists avatar_url text;

alter table public.users
add column if not exists bio text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'users_phone_format_chk'
      and conrelid = 'public.users'::regclass
  ) then
    alter table public.users
      add constraint users_phone_format_chk
      check (
        phone is null
        or phone ~ '^[+0-9][0-9\\-\\s]{6,24}$'
      );
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'users_bio_length_chk'
      and conrelid = 'public.users'::regclass
  ) then
    alter table public.users
      add constraint users_bio_length_chk
      check (bio is null or char_length(bio) <= 240);
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'users_avatar_url_length_chk'
      and conrelid = 'public.users'::regclass
  ) then
    alter table public.users
      add constraint users_avatar_url_length_chk
      check (avatar_url is null or char_length(avatar_url) <= 512);
  end if;
end
$$;

-- keep/update own-row RLS update policy
alter table public.users enable row level security;

drop policy if exists "Users can update own row" on public.users;
create policy "Users can update own row"
on public.users
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);
