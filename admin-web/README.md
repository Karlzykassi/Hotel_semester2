# Khmer Hotel Admin Web

This Next.js app is a desktop-first admin panel for the existing Flutter hotel-booking project in the parent workspace.

## What It Connects To

- `hotels`
- `bookings`
- `room_types`
- `profiles`
- `auth.users` via the Supabase Admin API

It uses the same Supabase project as the Flutter app. The public URL and anon key default to the values already used in the mobile project.

## Setup

1. Copy `.env.example` to `.env.local`
2. Add your real `SUPABASE_SERVICE_ROLE_KEY`
3. Replace `ADMIN_SESSION_SECRET` with a random secret
4. Set `ADMIN_EMAILS` to the comma-separated admin accounts you want to allow

Example:

```env
ADMIN_EMAILS=hong@example.com,manager@example.com
```

## Run

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

## Notes

- Sign-in uses Supabase email/password auth.
- Admin access is granted by `ADMIN_EMAILS` or `app_metadata.role = admin`.
- Live admin data and member management require `SUPABASE_SERVICE_ROLE_KEY`.
