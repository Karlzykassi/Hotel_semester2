# Supabase App Setup

The app already supports a real Supabase backend. It switches from local mock
storage to Supabase when both `SUPABASE_URL` and `SUPABASE_ANON_KEY` are
provided at launch time.

## What is already wired

- App startup initializes Supabase when both values are provided.
- Email/password login and register use Supabase Auth.
- Google sign-in exchanges the Google token with Supabase Auth.
- Home, search, bookings, and profile screens read from the repository layer.
- Booking confirmation writes booking and payment records.

## Real backend setup

1. Create a Supabase project.
2. In Supabase, open `Project Settings > API`.
3. Copy the project URL and anon key.
4. Copy [supabase_keys.example.json](/D:/School/RUPP/Year%204/S2/Mobile/Assignment/hote_v2/supabase/supabase_keys.example.json) to `supabase/supabase_keys.json`.
5. Paste your real values into `supabase/supabase_keys.json`.
6. Run [schema.sql](/D:/School/RUPP/Year%204/S2/Mobile/Assignment/hote_v2/supabase/schema.sql) in the Supabase SQL Editor.
7. Run [seed.sql](/D:/School/RUPP/Year%204/S2/Mobile/Assignment/hote_v2/supabase/seed.sql) in the Supabase SQL Editor.

If you already created your database before this Google Places update, also run
[google_places_patch.sql](/D:/School/RUPP/Year%204/S2/Mobile/Assignment/hote_v2/supabase/google_places_patch.sql).

## Run with Supabase

Use one of these options:

```bash
flutter run --dart-define-from-file=supabase/supabase_keys.json
```

```powershell
.\scripts\run_with_supabase.ps1
```

If you use VS Code, there is also a ready-made launch configuration:

- `Khmer Hotel (Supabase)`

## Fallback behavior

If the Supabase keys are missing, the app falls back to local mock data so it
still runs.

## Where client data appears

When the app is running against Supabase, you can view client data here:

- `Authentication > Users` for login accounts
- `Database > Table Editor > profiles` for user profiles
- `Database > Table Editor > bookings` for bookings
- `Database > Table Editor > payments` for payment records
- `Database > Table Editor > search_history` for searches

## Google Places hotel sync

Use this when you want Google Places to provide hotel name, address, rating,
map link, and current primary photo, while Supabase keeps the app's own hotel,
room, booking, and payment records.

1. Copy
   [google_places_sync.example.json](/D:/School/RUPP/Year%204/S2/Mobile/Assignment/hote_v2/supabase/google_places_sync.example.json)
   to `supabase/google_places_sync.json`.
2. Paste these values into the new file:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `GOOGLE_PLACES_API_KEY`
3. Run one of these examples from the project root:

```bash
dart run scripts/sync_google_places_hotels.dart --city "Siem Reap"
dart run scripts/sync_google_places_hotels.dart --query "Palace Gate Hotel"
dart run scripts/sync_google_places_hotels.dart --latitude 13.3611 --longitude 103.8598 --radius 3500
```

What the sync does:

- Calls Google Places text search or nearby search
- Fetches place details for each result
- Resolves the primary photo media URL
- Upserts hotel metadata into `public.hotels`
- Updates the primary image in `public.hotel_images`
- Seeds default room inventory for newly imported hotels so they stay bookable

## Social auth note

Add Google and Facebook providers in Supabase Auth if you want social login in
production.
