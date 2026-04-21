-- Supabase SQL: Users table + auth sync trigger + RLS
-- Paste this into Supabase SQL Editor and run once.

-- 0) User role enum (driver/passenger)
do $$
begin
  create type public.user_role as enum ('driver', 'passenger');
exception
  when duplicate_object then null;
end
$$;

-- 1) Users table linked to auth.users
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (char_length(trim(full_name)) > 0),
  email text not null unique check (position('@' in email) > 1),
  role public.user_role not null default 'passenger',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Legacy cleanup (safe if these objects do not exist).
drop policy if exists "Admins can read all users" on public.users;
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_auth_user();

-- Ensure role exists for older tables created before role feature.
alter table public.users
add column if not exists role public.user_role;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'users'
      and column_name = 'role'
      and udt_name <> 'user_role'
  ) then
    alter table public.users
    alter column role type public.user_role
    using case lower(trim(role::text))
      when 'driver' then 'driver'::public.user_role
      else 'passenger'::public.user_role
    end;
  end if;
end
$$;

alter table public.users
alter column role set default 'passenger';

update public.users
set role = 'passenger'
where role is null;

alter table public.users
alter column role set not null;

create index if not exists users_created_at_idx on public.users(created_at desc);
create index if not exists users_role_idx on public.users(role);

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
  v_role public.user_role;
begin
  v_full_name := coalesce(
    nullif(trim(new.raw_user_meta_data->>'full_name'), ''),
    split_part(coalesce(new.email, 'User'), '@', 1),
    'User'
  );

  v_role := case lower(coalesce(new.raw_user_meta_data->>'role', 'passenger'))
    when 'driver' then 'driver'::public.user_role
    else 'passenger'::public.user_role
  end;

  insert into public.users (id, full_name, email, role)
  values (new.id, v_full_name, coalesce(new.email, ''), v_role)
  on conflict (id) do update
    set full_name = excluded.full_name,
        email = excluded.email,
        role = excluded.role,
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
