create or replace function public.search_hotels(
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

update public.hotels
set
  hero_image_url = case lower(name)
    when 'amber kampot' then 'https://amber-kampot.com/wp-content/uploads/2020/06/PV-exterior-02-min.jpg'
    when 'castle bayview resort' then 'assets/provinces/kampot.jpg'
    when 'kampot sweet boutique' then 'https://kampotsweetboutique.com/uploads/banner/DSC_3179.jpg'
    when 'rainforest hotel' then 'assets/provinces/kampot.jpg'
    when 'sabay beach' then 'https://static.wixstatic.com/media/368149_2e9445208f674b729d90e519c32e296a~mv2.jpg/v1/fill/w_1268,h_713,al_c/368149_2e9445208f674b729d90e519c32e296a~mv2.jpg'
    when 'kep bay hotel & resort' then 'assets/provinces/kep.jpg'
    when 'knai bang chatt' then 'https://static.wixstatic.com/media/a31d6e_57ffef39fe3443dd9086e721e62ef7a0~mv2.jpg/v1/fill/w_2500,h_1474,al_c/a31d6e_57ffef39fe3443dd9086e721e62ef7a0~mv2.jpg'
    when 'raingsey bungalow' then 'https://raingsey.com/wp-content/uploads/2018/10/homepage-pool.jpg'
    when 'saravoan-kep hotel' then 'assets/provinces/kep.jpg'
    when 'veranda natural resort' then 'https://verandaresortkep.com/wafx_res/verandahome/room/swimmingpoolbar.jpg'
    when 'palace gate hotel' then 'https://palacegatepp.com/wp-content/uploads/2023/02/Palace-Gate-Hotel-Pool-1024x683.png'
    when 'raffles hotel le royal' then 'https://m.ahstatic.com/is/image/accorhotels/aja_p_7238-05?wid=1920'
    when 'rosewood phnom penh' then 'https://picasso.rosewoodhotelgroup.com/transform/7fae2665-f55a-4fb0-a65d-523f21820bac/RWPPN_3-0_Brand-com_Assets_Accommodation_Bedroom_Executive_King_Room'
    when 'shangri-la phnom penh' then 'https://sitecore-cd-imgr.shangri-la.com/MediaFiles/E/F/6/{EF652EA4-BC1B-413B-B901-0673EE76D648}20250319_slpp_exterior_hires.png'
    when 'sofitel phnom penh phokeethra' then 'https://www.sofitel-phnompenh-phokeethra.com/wp-content/uploads/sites/90/2022/05/RoomSuites-1-1.jpg'
    when 'golden temple hotel' then 'https://goldentemplehotel.com/wp-content/uploads/2025/02/Golden-Temple-Hotel-Second-Send-35.jpg'
    when 'koulen central hotel' then 'assets/provinces/siem-reap.jpg'
    when 'saem siemreap hotel' then 'https://www.saemsiemreaphotel.com/wp-content/uploads/2022/11/220A2226.jpg'
    when 'shinta mani angkor' then 'https://shintamani.com/wp-content/uploads/2024/08/SMMBC-The-Living-Room-4-32.jpg'
    when 'sofitel angkor' then 'https://d2e5ushqwiltxm.cloudfront.net/wp-content/uploads/sites/104/2020/09/18085904/Nothing-Like-Siem-Reap.jpg'
    when 'the jungle' then 'assets/provinces/siem-reap.jpg'
    else hero_image_url
  end,
  address = case lower(name)
    when 'kampot sweet boutique' then 'Krang Village, Trapeang Thum Commune, Tuek Chhou District, Kampot Province'
    when 'raingsey bungalow' then 'Thmey Village, Prey Thom Commune, Crab Market, Kep Province'
    when 'rosewood phnom penh' then 'Vattanac Capital Tower, Monivong Boulevard, Sangkat Wat Phnom, Khan Daun Penh, Phnom Penh'
    when 'raffles hotel le royal' then '92 Rukhak Vithei Daun Penh, Sangkat Wat Phnom, Phnom Penh'
    when 'sofitel angkor' then 'Vithei Charles de Gaulle, Khum Svay Dang Kum, Siem Reap Province'
    else address
  end
where lower(name) in (
  'amber kampot',
  'castle bayview resort',
  'kampot sweet boutique',
  'rainforest hotel',
  'sabay beach',
  'kep bay hotel & resort',
  'knai bang chatt',
  'raingsey bungalow',
  'saravoan-kep hotel',
  'veranda natural resort',
  'palace gate hotel',
  'raffles hotel le royal',
  'rosewood phnom penh',
  'shangri-la phnom penh',
  'sofitel phnom penh phokeethra',
  'golden temple hotel',
  'koulen central hotel',
  'saem siemreap hotel',
  'shinta mani angkor',
  'sofitel angkor',
  'the jungle'
);

update public.hotel_images hi
set
  image_url = h.hero_image_url,
  sort_order = case when hi.is_primary then 0 else hi.sort_order end
from public.hotels h
where hi.hotel_id = h.id
  and h.hero_image_url is not null
  and h.hero_image_url <> ''
  and (
    hi.image_url = 'assets/Hotel 1.jpg'
    or (hi.is_primary and hi.image_url is distinct from h.hero_image_url)
  );

insert into public.hotel_images (hotel_id, image_url, sort_order, is_primary)
select
  h.id,
  h.hero_image_url,
  0,
  true
from public.hotels h
where h.hero_image_url is not null
  and h.hero_image_url <> ''
  and not exists (
    select 1
    from public.hotel_images hi
    where hi.hotel_id = h.id
  );
