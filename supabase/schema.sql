create extension if not exists pgcrypto;

do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'booking_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.booking_status as enum (
      'pending',
      'confirmed',
      'completed',
      'cancelled',
      'saved'
    );
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'payment_status'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.payment_status as enum (
      'unpaid',
      'pending',
      'paid',
      'failed',
      'refunded'
    );
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'payment_method'
      and typnamespace = 'public'::regnamespace
  ) then
    create type public.payment_method as enum (
      'aba',
      'acleda',
      'wing',
      'cash',
      'card'
    );
  end if;
end
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  phone text,
  avatar_url text,
  date_of_birth date,
  country text default 'Cambodia',
  gender text,
  language text default 'English',
  auth_provider text default 'email',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.hotels (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  city text not null,
  province text,
  country text not null default 'Cambodia',
  address text,
  description text,
  google_place_id text,
  google_maps_uri text,
  latitude double precision,
  longitude double precision,
  rating numeric(2, 1) not null default 0,
  review_count integer not null default 0 check (review_count >= 0),
  hero_image_url text,
  price_from numeric(10, 2) not null default 0 check (price_from >= 0),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists hotels_google_place_id_unique
  on public.hotels (google_place_id)
  where google_place_id is not null;

create table if not exists public.hotel_images (
  id uuid primary key default gen_random_uuid(),
  hotel_id uuid not null references public.hotels (id) on delete cascade,
  image_url text not null,
  sort_order integer not null default 0,
  is_primary boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists hotel_images_primary_unique
  on public.hotel_images (hotel_id)
  where is_primary;

create table if not exists public.amenities (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  icon_key text,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.hotel_amenities (
  hotel_id uuid not null references public.hotels (id) on delete cascade,
  amenity_id uuid not null references public.amenities (id) on delete cascade,
  primary key (hotel_id, amenity_id)
);

create table if not exists public.room_types (
  id uuid primary key default gen_random_uuid(),
  hotel_id uuid not null references public.hotels (id) on delete cascade,
  name text not null,
  description text,
  price_per_night numeric(10, 2) not null check (price_per_night >= 0),
  capacity integer not null check (capacity > 0),
  total_rooms integer not null default 0 check (total_rooms >= 0),
  bed_type text,
  breakfast_included boolean not null default false,
  refundable boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (hotel_id, name)
);

create table if not exists public.room_availability (
  room_type_id uuid not null references public.room_types (id) on delete cascade,
  available_date date not null,
  available_rooms integer not null check (available_rooms >= 0),
  base_price numeric(10, 2) check (base_price >= 0),
  primary key (room_type_id, available_date)
);

create table if not exists public.saved_hotels (
  user_id uuid not null references auth.users (id) on delete cascade,
  hotel_id uuid not null references public.hotels (id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, hotel_id)
);

create table if not exists public.search_history (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  query_text text not null,
  city text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists search_history_user_created_idx
  on public.search_history (user_id, created_at desc);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  hotel_id uuid not null references public.hotels (id),
  room_type_id uuid not null references public.room_types (id),
  status public.booking_status not null default 'pending',
  check_in_date date not null,
  check_out_date date not null,
  guest_count integer not null check (guest_count > 0),
  title text,
  first_name text not null,
  last_name text not null,
  date_of_birth date,
  email text not null,
  phone_number text,
  special_request text,
  payment_method public.payment_method not null default 'cash',
  payment_status public.payment_status not null default 'unpaid',
  subtotal numeric(10, 2) not null check (subtotal >= 0),
  taxes numeric(10, 2) not null default 0 check (taxes >= 0),
  total numeric(10, 2) generated always as (subtotal + taxes) stored,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint bookings_date_order check (check_out_date > check_in_date)
);

create index if not exists bookings_user_created_idx
  on public.bookings (user_id, created_at desc);

create index if not exists bookings_hotel_dates_idx
  on public.bookings (hotel_id, check_in_date, check_out_date);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings (id) on delete cascade,
  provider text not null,
  provider_reference text,
  amount numeric(10, 2) not null check (amount >= 0),
  currency char(3) not null default 'USD',
  status public.payment_status not null default 'pending',
  paid_at timestamptz,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  hotel_id uuid not null references public.hotels (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  booking_id uuid unique references public.bookings (id) on delete set null,
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists reviews_hotel_created_idx
  on public.reviews (hotel_id, created_at desc);

create or replace view public.hotel_listing_view as
select
  h.id,
  h.name,
  h.slug,
  h.city,
  h.country,
  h.rating,
  h.price_from,
  coalesce(
    (
      select hi.image_url
      from public.hotel_images hi
      where hi.hotel_id = h.id
      order by hi.is_primary desc, hi.sort_order asc, hi.created_at asc
      limit 1
    ),
    h.hero_image_url
  ) as image_url
from public.hotels h;

drop function if exists public.search_hotels(text, text, integer, numeric);

create function public.search_hotels(
  search_city text default null,
  search_query text default null,
  guest_capacity integer default 1,
  max_price numeric default null
)
returns table (
  hotel_id uuid,
  hotel_name text,
  city text,
  province text,
  address text,
  latitude double precision,
  longitude double precision,
  google_maps_uri text,
  rating numeric,
  image_url text,
  price_from numeric
)
language sql
stable
as $$
  select
    h.id as hotel_id,
    h.name as hotel_name,
    h.city,
    h.province,
    h.address,
    h.latitude,
    h.longitude,
    h.google_maps_uri,
    h.rating,
    coalesce(
      (
        select hi.image_url
        from public.hotel_images hi
        where hi.hotel_id = h.id
        order by hi.is_primary desc, hi.sort_order asc, hi.created_at asc
        limit 1
      ),
      h.hero_image_url
    ) as image_url,
    min(rt.price_per_night) as price_from
  from public.hotels h
  join public.room_types rt
    on rt.hotel_id = h.id
  where (
      search_city is null
      or coalesce(h.province, h.city) ilike '%' || search_city || '%'
    )
    and (
      search_query is null
      or coalesce(h.province, h.city) ilike '%' || search_query || '%'
    )
    and rt.capacity >= greatest(coalesce(guest_capacity, 1), 1)
    and (max_price is null or rt.price_per_night <= max_price)
  group by
    h.id,
    h.name,
    h.city,
    h.province,
    h.address,
    h.latitude,
    h.longitude,
    h.google_maps_uri,
    h.rating,
    h.hero_image_url
  order by
    coalesce(h.province, h.city) asc,
    h.name asc,
    min(rt.price_per_night) asc;
$$;

create or replace function public.ensure_default_room_inventory(
  target_hotel_id uuid,
  starting_price numeric default 120
)
returns void
language plpgsql
as $$
begin
  insert into public.room_types (
    hotel_id,
    name,
    description,
    price_per_night,
    capacity,
    total_rooms,
    bed_type,
    breakfast_included,
    refundable
  )
  values
    (
      target_hotel_id,
      'Standard Room',
      'Comfortable standard stay for couples or solo travelers.',
      greatest(coalesce(starting_price, 120), 0),
      2,
      12,
      'Queen Bed',
      true,
      false
    ),
    (
      target_hotel_id,
      'Deluxe Room',
      'Upgraded room with more space and a better view.',
      greatest(coalesce(starting_price, 120), 0) + 40,
      3,
      8,
      'King Bed',
      true,
      true
    ),
    (
      target_hotel_id,
      'Family Room',
      'Family-friendly room with extra beds and more space.',
      greatest(coalesce(starting_price, 120), 0) + 80,
      4,
      5,
      '2 Double Beds',
      true,
      true
    )
  on conflict (hotel_id, name) do update
  set
    description = excluded.description,
    price_per_night = excluded.price_per_night,
    capacity = excluded.capacity,
    total_rooms = excluded.total_rooms,
    bed_type = excluded.bed_type,
    breakfast_included = excluded.breakfast_included,
    refundable = excluded.refundable;

  insert into public.room_availability (
    room_type_id,
    available_date,
    available_rooms,
    base_price
  )
  select
    rt.id,
    day_series.available_date::date,
    greatest(rt.total_rooms - 1, 0),
    rt.price_per_night
  from public.room_types rt
  cross join lateral generate_series(
    current_date,
    current_date + interval '60 day',
    interval '1 day'
  ) as day_series (available_date)
  where rt.hotel_id = target_hotel_id
  on conflict (room_type_id, available_date) do update
  set
    available_rooms = excluded.available_rooms,
    base_price = excluded.base_price;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id,
    full_name,
    avatar_url,
    auth_provider
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.email),
    new.raw_user_meta_data ->> 'avatar_url',
    coalesce(new.raw_app_meta_data ->> 'provider', 'email')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();

drop trigger if exists hotels_set_updated_at on public.hotels;
create trigger hotels_set_updated_at
  before update on public.hotels
  for each row execute procedure public.set_updated_at();

drop trigger if exists room_types_set_updated_at on public.room_types;
create trigger room_types_set_updated_at
  before update on public.room_types
  for each row execute procedure public.set_updated_at();

drop trigger if exists bookings_set_updated_at on public.bookings;
create trigger bookings_set_updated_at
  before update on public.bookings
  for each row execute procedure public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.hotels enable row level security;
alter table public.hotel_images enable row level security;
alter table public.amenities enable row level security;
alter table public.hotel_amenities enable row level security;
alter table public.room_types enable row level security;
alter table public.room_availability enable row level security;
alter table public.saved_hotels enable row level security;
alter table public.search_history enable row level security;
alter table public.bookings enable row level security;
alter table public.payments enable row level security;
alter table public.reviews enable row level security;

drop policy if exists "public can read hotels" on public.hotels;
create policy "public can read hotels"
  on public.hotels
  for select
  using (true);

drop policy if exists "public can read hotel images" on public.hotel_images;
create policy "public can read hotel images"
  on public.hotel_images
  for select
  using (true);

drop policy if exists "public can read amenities" on public.amenities;
create policy "public can read amenities"
  on public.amenities
  for select
  using (true);

drop policy if exists "public can read hotel amenities" on public.hotel_amenities;
create policy "public can read hotel amenities"
  on public.hotel_amenities
  for select
  using (true);

drop policy if exists "public can read room types" on public.room_types;
create policy "public can read room types"
  on public.room_types
  for select
  using (true);

drop policy if exists "public can read room availability" on public.room_availability;
create policy "public can read room availability"
  on public.room_availability
  for select
  using (true);

drop policy if exists "public can read reviews" on public.reviews;
create policy "public can read reviews"
  on public.reviews
  for select
  using (true);

drop policy if exists "users can view own profile" on public.profiles;
create policy "users can view own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

drop policy if exists "users can insert own profile" on public.profiles;
create policy "users can insert own profile"
  on public.profiles
  for insert
  with check (auth.uid() = id);

drop policy if exists "users can update own profile" on public.profiles;
create policy "users can update own profile"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "users can manage own saved hotels" on public.saved_hotels;
create policy "users can manage own saved hotels"
  on public.saved_hotels
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "users can manage own search history" on public.search_history;
create policy "users can manage own search history"
  on public.search_history
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "users can read own bookings" on public.bookings;
create policy "users can read own bookings"
  on public.bookings
  for select
  using (auth.uid() = user_id);

drop policy if exists "users can create own bookings" on public.bookings;
create policy "users can create own bookings"
  on public.bookings
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "users can update own bookings" on public.bookings;
create policy "users can update own bookings"
  on public.bookings
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

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

drop policy if exists "users can create own reviews" on public.reviews;
create policy "users can create own reviews"
  on public.reviews
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "users can update own reviews" on public.reviews;
create policy "users can update own reviews"
  on public.reviews
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant usage on schema public to anon, authenticated;

grant select on public.hotels to anon, authenticated;
grant select on public.hotel_images to anon, authenticated;
grant select on public.amenities to anon, authenticated;
grant select on public.hotel_amenities to anon, authenticated;
grant select on public.room_types to anon, authenticated;
grant select on public.room_availability to anon, authenticated;
grant select on public.reviews to anon, authenticated;
grant select on public.hotel_listing_view to anon, authenticated;

grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.saved_hotels to authenticated;
grant select, insert, update, delete on public.search_history to authenticated;
grant select, insert, update on public.bookings to authenticated;
grant select, insert on public.payments to authenticated;
grant select, insert, update on public.reviews to authenticated;

grant usage, select on all sequences in schema public to authenticated;
grant execute on function public.search_hotels(text, text, integer, numeric) to anon, authenticated;
