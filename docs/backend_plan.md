# Backend Plan

## Recommended stack

Use **Supabase** for this project.

Why it fits this app:

- Your app is a hotel booking app, so the data is **relational**: users, hotels, room types, availability, bookings, payments, reviews.
- Supabase uses **PostgreSQL**, which is a better fit than a NoSQL database for booking and availability logic.
- Supabase gives you **Auth**, **Database**, **Storage**, **generated REST API**, and **RPC/Edge Functions** in one backend.
- It works well with Flutter through `supabase_flutter`.

## What API to use

Use a mix of Supabase APIs instead of building a separate custom backend first:

1. `supabase.auth`
   - For email/password login
   - For Google login
   - For Facebook login
   - This is the cleanest upgrade path from your current login screens

2. Supabase table API
   - Use `.from('hotels').select()`
   - Use `.from('room_types').select()`
   - Use `.from('bookings').insert()`
   - Good for standard CRUD screens like profile, saved hotels, booking history

3. Supabase RPC
   - Use `rpc('search_hotels', ...)`
   - Best for hotel search filters and room availability lookups
   - Keeps filtering and aggregation in PostgreSQL instead of duplicating it in Flutter

4. Supabase Edge Functions
   - Use for payment workflows
   - Use for booking confirmation/cancellation logic if you need server-side validation
   - Use for webhook handling from a payment provider

## Best choice for each feature in this app

- Home screen: table API on `hotels`, `hotel_images`, `room_types`
- Search screen: RPC `search_hotels`
- Hotel detail screen: table API on `hotels`, `hotel_images`, `hotel_amenities`, `room_types`
- Login/register: `supabase.auth`
- Saved/bookmarked hotels: table API on `saved_hotels`
- Booking flow: table API for inserts, or Edge Function if you want stock validation first
- Payment: Edge Function plus `payments` table
- Search history: table API on `search_history`

## Why not Firestore as the main database

Firestore is good for simple document data, but this project already needs:

- joins between hotels and room types
- date-based availability
- booking status workflows
- payment records
- aggregate search queries

That is much easier and safer in PostgreSQL.

## Suggested Flutter packages

- `supabase_flutter`: primary backend client
- `flutter_dotenv`: keep Supabase URL and anon key outside source code

## Database files added

- `supabase/schema.sql`: full PostgreSQL schema with RLS policies
- `supabase/seed.sql`: sample data that matches your current hotel UI

## Suggested next implementation steps

1. Create a Supabase project
2. Run `supabase/schema.sql`
3. Run `supabase/seed.sql`
4. Add `supabase_flutter` to the Flutter app
5. Replace `AppData` reads with repository calls
6. Replace direct Google/Facebook packages with Supabase Auth providers

## Official references

- Supabase Flutter quickstart: <https://supabase.com/docs/guides/getting-started/quickstarts/flutter>
- Supabase Database: <https://supabase.com/docs/guides/database/overview>
- Supabase Auth: <https://supabase.com/docs/guides/auth>
- Supabase REST API: <https://supabase.com/docs/guides/api>
- Supabase Edge Functions: <https://supabase.com/docs/guides/functions>
- Firebase Firestore overview: <https://firebase.google.com/docs/firestore>