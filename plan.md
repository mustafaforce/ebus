# Smart Bus Tracking App - Development Plan

## Project Overview
Semi-real-time bus tracking app where drivers manually update bus location at stops, and passengers view current bus position.

---

## Feature Implementation Status

| # | Feature | Status | SQL | Code | Notes |
|---|---------|--------|-----|------|-------|
| 1 | Route Selection | ✅ Completed | ☑️ | ☑️ | Driver selects bus route |
| 2 | Stop Selection Dropdown | ✅ Completed | ☑️ | ☑️ | Driver picks current stop |
| 3 | Manual Location Update | ✅ Completed | ☑️ | ☑️ | Driver updates bus location |
| 4 | Current Bus Location Display | ✅ Completed | ☑️ | ☑️ | Passenger sees bus position |
| 5 | Next Stop Information | ✅ Completed | ☑️ | ☑️ | Shows upcoming stop |
| 6 | Last Updated Time Display | ✅ Completed | ☑️ | ☑️ | Shows last update timestamp |
| 7 | Route & Stop List View | ⏳ Pending | ☐ | ☐ | Full route with all stops |

---

## Database Schema (Planned)

### Tables

1. **`routes`** - Bus routes
   - `id` (uuid, PK)
   - `name` (text) - e.g., "Route 101"
   - `description` (text)
   - `is_active` (bool)
   - `created_at`, `updated_at`

2. **`stops`** - Bus stops
   - `id` (uuid, PK)
   - `route_id` (uuid, FK -> routes)
   - `name` (text)
   - `sequence_order` (int) - order in route
   - `created_at`, `updated_at`

3. **`bus_locations`** - Current bus positions
   - `id` (uuid, PK)
   - `route_id` (uuid, FK -> routes)
   - `driver_id` (uuid, FK -> users)
   - `current_stop_id` (uuid, FK -> stops)
   - `updated_at` (timestamp)
   - Unique constraint: one active location per route per driver

---

## Implementation Workflow

### For Each Feature:
1. Write SQL migration file in `supabase/sql/`
2. Apply migration to Supabase (user runs manually)
3. Write Dart code (feature folder under `lib/features/`)
4. Update this file - mark SQL and Code as ☑️ Done

---

## Feature Details

### Feature 1: Route Selection
**Description:** Driver selects their assigned bus route from a dropdown
**SQL File:** `supabase/sql/sql_commands_routes.sql`
**Feature Folder:** `lib/features/routes/`
**UI:** Dropdown showing all active routes

### Feature 2: Stop Selection Dropdown
**Description:** Driver selects current stop from predefined list based on selected route
**SQL File:** `supabase/sql/sql_commands_stops.sql`
**Feature Folder:** `lib/features/stops/`
**UI:** Dropdown showing stops in order for selected route

### Feature 3: Manual Location Update
**Description:** Driver presses button to update bus location to selected stop
**SQL File:** `supabase/sql/sql_commands_bus_locations.sql`
**Feature Folder:** `lib/features/tracking/`
**UI:** "Update Location" button

### Feature 4: Current Bus Location Display
**Description:** Passenger sees current bus position on selected route
**SQL File:** (shared from Feature 3)
**Feature Folder:** `lib/features/tracking/`
**UI:** Bus icon showing current stop name

### Feature 5: Next Stop Information
**Description:** Shows the next stop the bus will arrive at
**SQL File:** (shared)
**Feature Folder:** `lib/features/tracking/`
**UI:** "Next Stop: [name]" display

### Feature 6: Last Updated Time Display
**Description:** Shows when driver last updated location
**SQL File:** (shared)
**Feature Folder:** `lib/features/tracking/`
**UI:** "Updated: [time] ago" display

### Feature 7: Route & Stop List View
**Description:** Complete list of all routes and their stops
**SQL File:** (shared)
**Feature Folder:** `lib/features/route_list/`
**UI:** Expandable list of routes with stops

---

## Progress Log

| Date | Feature | Action | Status |
|------|---------|--------|--------|
| 2026-04-29 | Route Selection | SQL + Dart Code | ✅ Completed |
| 2026-04-29 | Stop Selection Dropdown | SQL + Dart Code | ✅ Completed |
| 2026-04-29 | Manual Location Update | SQL + Dart Code | ✅ Completed |
| 2026-04-29 | Passenger Tracking (4,5,6) | SQL + Dart Code | ✅ Completed |

---

## Current Status

**Last Completed:** Features 4, 5, 6 - Passenger Tracking
**Next Feature:** Feature 7 - Route & Stop List View

---