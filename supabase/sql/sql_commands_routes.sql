-- Supabase SQL: Routes table for Smart Bus Tracking App
-- Run this in Supabase SQL Editor

-- 1) Routes table
create table if not exists public.routes (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) > 0),
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2) Updated_at trigger
drop trigger if exists routes_set_updated_at on public.routes;
create trigger routes_set_updated_at
before update on public.routes
for each row
execute function public.set_updated_at();

-- 3) Indexes
create index if not exists routes_name_idx on public.routes(name);
create index if not exists routes_is_active_idx on public.routes(is_active);

-- 4) RLS Policies
alter table public.routes enable row level security;

drop policy if exists "Anyone can read active routes" on public.routes;
create policy "Anyone can read active routes"
on public.routes
for select
to authenticated
using (is_active = true);

drop policy if exists "Drivers can manage routes" on public.routes;
create policy "Drivers can manage routes"
on public.routes
for all
to authenticated
using (
  exists (
    select 1 from public.users
    where id = auth.uid() and role = 'driver'
  )
);

-- 5) Sample data (optional - remove in production)
insert into public.routes (name, description) values
  ('Route 101', 'Downtown - Airport Express'),
  ('Route 202', 'Central Station - Harbor'),
  ('Route 303', 'University - Shopping Mall');