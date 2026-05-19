alter table public.bus_locations
add column if not exists estimated_distance numeric check (estimated_distance >= 0);

alter table public.bus_locations
add column if not exists estimated_time_minutes integer check (estimated_time_minutes >= 0);