alter table public.hotels
  add column if not exists google_place_id text,
  add column if not exists google_maps_uri text;

create unique index if not exists hotels_google_place_id_unique
  on public.hotels (google_place_id)
  where google_place_id is not null;

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

grant execute on function public.search_hotels(text, text, integer, numeric) to anon, authenticated;
