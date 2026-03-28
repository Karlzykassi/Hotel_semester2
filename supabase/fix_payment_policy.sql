-- Run this in the Supabase SQL Editor if booking creation fails when
-- inserting into public.payments.

drop policy if exists "users can read own payments" on public.payments;
create policy "users can read own payments"
  on public.payments
  for select
  to authenticated
  using (
    booking_id in (
      select b.id
      from public.bookings b
      where b.user_id = (select auth.uid())
    )
  );

drop policy if exists "users can create own payments" on public.payments;
create policy "users can create own payments"
  on public.payments
  for insert
  to authenticated
  with check (
    booking_id in (
      select b.id
      from public.bookings b
      where b.user_id = (select auth.uid())
    )
  );

grant select, insert on public.payments to authenticated;
