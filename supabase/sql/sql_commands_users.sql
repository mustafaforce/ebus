-- Supabase SQL: Users table + auth sync trigger + RLS
-- Paste this into Supabase SQL Editor and run once.

-- 1) Users table linked to auth.users
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (char_length(trim(full_name)) > 0),
  email text not null unique check (position('@' in email) > 1),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Legacy cleanup (safe if these objects do not exist).
drop policy if exists "Admins can read all users" on public.users;
drop index if exists public.users_role_idx;
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_auth_user();

-- If the table already existed with role, remove it.
alter table public.users drop column if exists role;
drop type if exists public.user_role;

create index if not exists users_created_at_idx on public.users(created_at desc);

-- 2) Generic updated_at trigger helper
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at
before update on public.users
for each row
execute function public.set_updated_at();

-- 3) Sync auth.users -> public.users on signup
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_full_name text;
begin
  v_full_name := coalesce(
    nullif(trim(new.raw_user_meta_data->>'full_name'), ''),
    split_part(coalesce(new.email, 'User'), '@', 1),
    'User'
  );

  insert into public.users (id, full_name, email)
  values (new.id, v_full_name, coalesce(new.email, ''))
  on conflict (id) do update
    set full_name = excluded.full_name,
        email = excluded.email,
        updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_auth_user();

-- 4) Row Level Security (RLS)
alter table public.users enable row level security;

drop policy if exists "Users can read own row" on public.users;
create policy "Users can read own row"
on public.users
for select
to authenticated
using (auth.uid() = id);

drop policy if exists "Users can update own row" on public.users;
create policy "Users can update own row"
on public.users
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);
