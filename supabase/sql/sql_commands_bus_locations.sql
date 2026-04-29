-- Supabase SQL: Bus Locations table for Smart Bus Tracking App
-- Run this in Supabase SQL Editor

-- 1) Bus Locations table
create table if not exists public.bus_locations (
  id uuid primary key default gen_random_uuid(),
  route_id uuid not null references public.routes(id) on delete cascade,
  driver_id uuid not null references public.users(id) on delete cascade,
  current_stop_id uuid not null references public.stops(id) on delete restrict,
  updated_at timestamptz not null default now(),
  unique (route_id, driver_id)
);

-- 2) Updated_at trigger
drop trigger if exists bus_locations_set_updated_at on public.bus_locations;
create trigger bus_locations_set_updated_at
before update on public.bus_locations
for each row
execute function public.set_updated_at();

-- 3) Indexes
create index if not exists bus_locations_route_id_idx on public.bus_locations(route_id);
create index if not exists bus_locations_driver_id_idx on public.bus_locations(driver_id);

-- 4) RLS Policies
alter table public.bus_locations enable row level security;

drop policy if exists "Anyone can read bus locations" on public.bus_locations;
create policy "Anyone can read bus locations"
on public.bus_locations
for select
to authenticated
using (exists (
  select 1 from public.routes where id = route_id and is_active = true
));

drop policy if exists "Drivers can update their own location" on public.bus_locations;
create policy "Drivers can update their own location"
on public.bus_locations
for insert
to authenticated
with check (driver_id = auth.uid());

drop policy if exists "Drivers can update own location" on public.bus_locations;
create policy "Drivers can update own location"
on public.bus_locations
for update
to authenticated
using (driver_id = auth.uid())
with check (driver_id = auth.uid());