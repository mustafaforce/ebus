-- Supabase SQL: Stops table for Smart Bus Tracking App
-- Run this in Supabase SQL Editor

-- 1) Stops table
create table if not exists public.stops (
  id uuid primary key default gen_random_uuid(),
  route_id uuid not null references public.routes(id) on delete cascade,
  name text not null check (char_length(trim(name)) > 0),
  sequence_order integer not null check (sequence_order >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (route_id, sequence_order)
);

-- 2) Updated_at trigger
drop trigger if exists stops_set_updated_at on public.stops;
create trigger stops_set_updated_at
before update on public.stops
for each row
execute function public.set_updated_at();

-- 3) Indexes
create index if not exists stops_route_id_idx on public.stops(route_id);
create index if not exists stops_sequence_idx on public.stops(route_id, sequence_order);

-- 4) RLS Policies
alter table public.stops enable row level security;

drop policy if exists "Anyone can read stops" on public.stops;
create policy "Anyone can read stops"
on public.stops
for select
to authenticated
using (exists (
  select 1 from public.routes where id = route_id and is_active = true
));

drop policy if exists "Drivers can manage stops" on public.stops;
create policy "Drivers can manage stops"
on public.stops
for all
to authenticated
using (
  exists (
    select 1 from public.users
    where id = auth.uid() and role = 'driver'
  )
);

-- 5) Sample data (optional - remove in production)
-- Route 101 stops
insert into public.stops (route_id, name, sequence_order)
select id, stop_name, seq
from public.routes,
unnest(ARRAY['Downtown Terminal', 'City Center', 'Market Square', 'Hospital Junction', 'University Gate', 'Airport Terminal']) with ordinality as t(stop_name, seq)
where name = 'Route 101';

-- Route 202 stops
insert into public.stops (route_id, name, sequence_order)
select id, stop_name, seq
from public.routes,
unnest(ARRAY['Central Station', 'Harbor View', 'Marina Mall', 'Beach Road', 'Harbor Terminal']) with ordinality as t(stop_name, seq)
where name = 'Route 202';

-- Route 303 stops
insert into public.stops (route_id, name, sequence_order)
select id, stop_name, seq
from public.routes,
unnest(ARRAY['University Main Gate', 'Campus Canteen', 'Sports Complex', 'Shopping Mall', 'City Junction']) with ordinality as t(stop_name, seq)
where name = 'Route 303';