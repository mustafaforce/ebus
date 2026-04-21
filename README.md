# eBus

Flutter app for eBus driver/passenger auth flow.

## Architecture

Project now follows feature-first clean architecture:

```text
lib/
  app/
    router/
    theme/
  core/
    constants/
    network/
    services/
  features/
    auth/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        errors/
        repositories/
        usecases/
      presentation/
        pages/
        widgets/
      auth_locator.dart
    home/
      presentation/
        pages/
```

Layer direction:

1. `presentation` -> calls `domain/usecases`
2. `domain` -> depends on repository abstractions only
3. `data` -> implements repository abstractions and talks to Supabase

Current state:

- UI pages do not call Supabase directly.
- Auth and profile flow goes through usecases and repository.
- Role model centralized in domain (`UserRole`).

## Setup

1. Create `.env` at project root:
   - `SUPABASE_URL=...`
   - `SUPABASE_ANON_KEY=...`
2. Run `flutter pub get`
3. Run `flutter run`
