insert into public.amenities (name, icon_key)
values
  ('Swimming Pool', 'pool'),
  ('5-Star Rating', 'star'),
  ('Family Gym', 'fitness_center'),
  ('24h Service', 'room_service'),
  ('Good Food', 'restaurant'),
  ('Sky Bar', 'local_bar'),
  ('Free Wifi', 'wifi'),
  ('Parking', 'local_parking')
on conflict (name) do nothing;

insert into public.hotels (
  slug,
  name,
  city,
  province,
  address,
  description,
  latitude,
  longitude,
  rating,
  review_count,
  hero_image_url,
  price_from
)
values
  ('rosewood-phnom-penh', 'Rosewood Phnom Penh', 'Phnom Penh', 'Phnom Penh', 'Vattanac Capital Tower, Phnom Penh', 'Premium skyline hotel with fine dining and city views.', 11.5715, 104.9189, 4.8, 342, 'https://picasso.rosewoodhotelgroup.com/transform/7fae2665-f55a-4fb0-a65d-523f21820bac/RWPPN_3-0_Brand-com_Assets_Accommodation_Bedroom_Executive_King_Room', 300),
  ('palace-gate-hotel', 'Palace Gate Hotel', 'Phnom Penh', 'Phnom Penh', '44 Sothearos Blvd, Phnom Penh', 'Boutique hotel near the Royal Palace with Khmer-inspired interiors.', 11.5564, 104.9313, 4.6, 206, 'https://palacegatepp.com/wp-content/uploads/2023/02/Palace-Gate-Hotel-Pool-1024x683.png', 220),
  ('sofitel-phnom-penh-phokeethra', 'Sofitel Phnom Penh Phokeethra', 'Phnom Penh', 'Phnom Penh', '26 Old August Site, Phnom Penh', 'Riverside luxury stay with club lounge and sports facilities.', 11.5430, 104.9323, 4.5, 268, 'https://www.sofitel-phnompenh-phokeethra.com/wp-content/uploads/sites/90/2022/05/RoomSuites-1-1.jpg', 240),
  ('golden-temple-hotel', 'Golden Temple Hotel', 'Siem Reap', 'Siem Reap', 'Sok San Road, Siem Reap', 'Boutique stay close to Angkor attractions with warm Khmer hospitality.', 13.3553, 103.8552, 4.8, 315, 'https://goldentemplehotel.com/wp-content/uploads/2025/02/Golden-Temple-Hotel-Second-Send-35.jpg', 260),
  ('shinta-mani-angkor', 'Shinta Mani Angkor', 'Siem Reap', 'Siem Reap', 'Junction of Oum Khun and 14th Street, Siem Reap', 'Stylish design hotel with curated experiences and upscale dining.', 13.3627, 103.8580, 4.7, 251, 'https://shintamani.com/wp-content/uploads/2024/08/SMMBC-The-Living-Room-4-32.jpg', 280),
  ('saem-siemreap-hotel', 'Saem Siemreap Hotel', 'Siem Reap', 'Siem Reap', 'Krom 6, Phoum Sala Kanseng, Siem Reap', 'Comfortable urban hotel with large rooms and easy airport access.', 13.3702, 103.8603, 4.3, 128, 'https://www.saemsiemreaphotel.com/wp-content/uploads/2022/11/220A2226.jpg', 190),
  ('kampot-sweet-boutique', 'Kampot Sweet Boutique', 'Kampot', 'Kampot', 'Krang Village, Trapeang Thum Commune, Tuek Chhou District, Kampot Province', 'Riverside boutique stay with peaceful views and modern finishes.', 10.6075, 104.1811, 4.6, 118, 'https://kampotsweetboutique.com/uploads/banner/DSC_3179.jpg', 210),
  ('amber-kampot', 'Amber Kampot', 'Kampot', 'Kampot', 'Tuek Chhou Road, Kampot', 'Riverside resort with stylish rooms, kayaks, and sunset views.', 10.6511, 104.1790, 4.4, 97, 'https://amber-kampot.com/wp-content/uploads/2020/06/PV-exterior-02-min.jpg', 190),
  ('castle-bayview-resort', 'Castle Bayview Resort', 'Kampot', 'Kampot', 'National Road 3, Kampot', 'Comfortable resort stay with hillside views and outdoor pool.', 10.6126, 104.1760, 4.2, 84, 'assets/provinces/kampot.jpg', 175),
  ('veranda-natural-resort', 'Veranda Natural Resort', 'Kep', 'Kep', 'Thmey Village, Kep National Park', 'Popular hillside resort surrounded by tropical gardens.', 10.4902, 104.2951, 4.7, 163, 'https://verandaresortkep.com/wafx_res/verandahome/room/swimmingpoolbar.jpg', 240),
  ('knai-bang-chatt', 'Knai Bang Chatt', 'Kep', 'Kep', 'Phum Thmey, Sangkat Prey Thom, Kep', 'Design-led seaside retreat with curated dining and ocean views.', 10.4835, 104.2925, 4.5, 121, 'https://static.wixstatic.com/media/a31d6e_57ffef39fe3443dd9086e721e62ef7a0~mv2.jpg/v1/fill/w_2500,h_1474,al_c/a31d6e_57ffef39fe3443dd9086e721e62ef7a0~mv2.jpg', 230),
  ('kep-bay-hotel-resort', 'Kep Bay Hotel & Resort', 'Kep', 'Kep', 'Kep Hillside, Kep', 'Scenic coastal resort with spacious rooms and sea breeze.', 10.4868, 104.2977, 4.1, 89, 'assets/provinces/kep.jpg', 170),
  ('battambang-riverside-hotel', 'Battambang Riverside Hotel', 'Battambang', 'Battambang', 'Riverside Road, Battambang', 'Relaxed riverside stay close to galleries, cafes, and the old quarter.', 13.0957, 103.2022, 4.4, 112, 'assets/provinces/battambang.jpg', 155),
  ('battambang-heritage-resort', 'Battambang Heritage Resort', 'Battambang', 'Battambang', 'Wat Kor Village, Battambang', 'Quiet garden retreat with Khmer-inspired architecture and pool villas.', 13.1020, 103.2140, 4.2, 76, 'assets/provinces/battambang.jpg', 180),
  ('classy-hotel-battambang', 'Classy Hotel Battambang', 'Battambang', 'Battambang', 'National Road 5, Battambang', 'Modern city hotel with meeting rooms, rooftop dining, and family suites.', 13.1005, 103.1989, 4.1, 93, 'https://classyhotelspa.com/wp-content/uploads/2025/11/Classy-hotel-1920-x-1080.jpg', 145),
  ('sihanoukville-bay-hotel', 'Sihanoukville Bay Hotel', 'Sihanoukville', 'Preah Sihanouk', 'Victory Beach Road, Sihanoukville', 'Seafront hotel with breezy rooms, sunset views, and easy beach access.', 10.6251, 103.5238, 4.5, 146, 'assets/provinces/preah-sihanouk.jpg', 210),
  ('otres-beach-resort', 'Otres Beach Resort', 'Sihanoukville', 'Preah Sihanouk', 'Otres Beach, Sihanoukville', 'Casual beach resort with tropical gardens, pool, and laid-back social spaces.', 10.5795, 103.5587, 4.3, 101, 'assets/provinces/preah-sihanouk.jpg', 185),
  ('sokha-blue-harbor-hotel', 'Sokha Blue Harbor Hotel', 'Sihanoukville', 'Preah Sihanouk', 'Serendipity Harbor, Sihanoukville', 'Modern harbor-facing hotel with spacious rooms and seafood-focused dining.', 10.6170, 103.5151, 4.2, 88, 'assets/provinces/preah-sihanouk.jpg', 220),
  ('koh-kong-riverside-resort', 'Koh Kong Riverside Resort', 'Koh Kong', 'Koh Kong', 'Koh Kong Riverside, Koh Kong', 'Comfortable waterfront stay with mangrove views and roomy family lodging.', 11.6151, 102.9839, 4.3, 74, 'assets/provinces/koh-kong.jpg', 165),
  ('tatai-eco-lodge', 'Tatai Eco Lodge', 'Koh Kong', 'Koh Kong', 'Koh Andet Village, Tatai Commune, Koh Kong District, Koh Kong Province', 'Nature-focused lodge near the Cardamom Mountains with river excursions.', 11.8890, 103.5070, 4.6, 84, 'https://thansurtataiecoresort.com/wp-content/uploads/2022/07/thansur-tatai-eco-resort-slider-1.jpg', 205),
  ('cardamom-bay-hotel', 'Cardamom Bay Hotel', 'Koh Kong', 'Koh Kong', 'National Road 48, Koh Kong', 'Simple contemporary stay for road-trippers exploring islands and rainforest.', 11.6038, 103.0027, 4.0, 61, 'assets/provinces/koh-kong.jpg', 150),
  ('kratie-mekong-hotel', 'Kratie Mekong Hotel', 'Kratie', 'Kratie', 'Preah Suramarit Quay, Kratie', 'Riverfront hotel with balcony views of the Mekong and the evening promenade.', 12.4884, 106.0180, 4.2, 67, 'assets/provinces/kratie.jpg', 145),
  ('dolphin-view-riverside', 'Dolphin View Riverside', 'Kratie', 'Kratie', 'Kampi Riverside, Kratie', 'Warm boutique stay inspired by the nearby Irrawaddy dolphin sanctuary.', 12.4867, 106.0155, 4.4, 81, 'assets/provinces/kratie.jpg', 160),
  ('soriyabori-riverside-resort', 'Soriyabori Riverside Resort', 'Kratie', 'Kratie', 'Koh Trong Island, Kratie', 'Peaceful island-style retreat with river breezes and relaxed open-air dining.', 12.4629, 106.0252, 4.5, 73, 'assets/provinces/kratie.jpg', 195),
  ('mondulkiri-hill-resort', 'Mondulkiri Hill Resort', 'Mondulkiri', 'Mondulkiri', 'Sen Monorom Hills, Mondulkiri', 'Cool-climate mountain stay with panoramic decks and pine-scented mornings.', 12.4555, 107.1966, 4.5, 79, 'assets/provinces/mondulkiri.jpg', 185),
  ('sen-monorom-nature-lodge', 'Sen Monorom Nature Lodge', 'Mondulkiri', 'Mondulkiri', 'Bou Sra Road, Sen Monorom', 'Cabin-style lodge close to waterfalls, trekking routes, and coffee farms.', 12.4540, 107.1948, 4.3, 64, 'assets/provinces/mondulkiri.jpg', 150),
  ('elephant-valley-retreat-hotel', 'Elephant Valley Retreat Hotel', 'Mondulkiri', 'Mondulkiri', 'Romnea Commune, Mondulkiri', 'Retreat-style hotel blending gentle luxury with the green highland landscape.', 12.4489, 107.2023, 4.6, 92, 'assets/provinces/mondulkiri.jpg', 215),
  ('ratanakiri-lake-view-hotel', 'Ratanakiri Lake View Hotel', 'Ratanakiri', 'Ratanakiri', 'Banlung Lake Road, Ratanakiri', 'Comfortable lakeside base for exploring Banlung and the red-soil highlands.', 13.7394, 106.9876, 4.1, 52, 'assets/provinces/ratanakiri.jpg', 140),
  ('banlung-eco-resort', 'Banlung Eco Resort', 'Ratanakiri', 'Ratanakiri', 'Banlung Forest Edge, Ratanakiri', 'Green hillside resort with airy rooms and easy access to nature trails.', 13.7428, 106.9860, 4.4, 69, 'assets/provinces/ratanakiri.jpg', 175),
  ('yeak-laom-boutique-hotel', 'Yeak Laom Boutique Hotel', 'Ratanakiri', 'Ratanakiri', 'Yeak Laom Road, Banlung', 'Boutique hotel inspired by the crater lake and indigenous craft traditions.', 13.7196, 106.9828, 4.2, 58, 'assets/provinces/ratanakiri.jpg', 160),
  ('kampong-cham-riverside-hotel', 'Kampong Cham Riverside Hotel', 'Kampong Cham', 'Kampong Cham', 'Sisowath Quay, Kampong Cham', 'Riverside city stay near the bamboo bridge, temples, and local night market.', 11.9934, 105.4635, 4.3, 86, 'assets/provinces/kampong-cham.jpg', 150),
  ('mekong-crossing-hotel', 'Mekong Crossing Hotel', 'Kampong Cham', 'Kampong Cham', 'French Colonial Quarter, Kampong Cham', 'Clean modern rooms for business trips and easy weekends along the Mekong.', 11.9950, 105.4602, 4.1, 62, 'assets/provinces/kampong-cham.jpg', 145),
  ('cham-heritage-resort', 'Cham Heritage Resort', 'Kampong Cham', 'Kampong Cham', 'Prey Thom Riverside, Kampong Cham', 'Relaxed heritage-style resort with leafy courtyards and family rooms.', 12.0040, 105.4684, 4.4, 74, 'assets/provinces/kampong-cham.jpg', 180),
  ('kampong-thom-palace-hotel', 'Kampong Thom Palace Hotel', 'Kampong Thom', 'Kampong Thom', 'National Road 6, Kampong Thom', 'Convenient town-center stay on the route to Sambor Prei Kuk.', 12.7112, 104.8885, 4.2, 59, 'assets/provinces/kampong-thom.jpg', 155),
  ('sambor-village-retreat', 'Sambor Village Retreat', 'Kampong Thom', 'Kampong Thom', 'Sambor Village, Kampong Thom', 'Garden retreat with relaxed poolside seating and polished Khmer decor.', 12.7118, 104.8958, 4.5, 82, 'assets/provinces/kampong-thom.jpg', 190),
  ('stung-sen-riverside-hotel', 'Stung Sen Riverside Hotel', 'Kampong Thom', 'Kampong Thom', 'Stung Sen Riverfront, Kampong Thom', 'Easygoing riverside stay with spacious rooms and a calm evening atmosphere.', 12.7064, 104.8942, 4.1, 57, 'assets/provinces/kampong-thom.jpg', 145)
on conflict (slug) do update
set
  name = excluded.name,
  city = excluded.city,
  province = excluded.province,
  address = excluded.address,
  description = excluded.description,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  rating = excluded.rating,
  review_count = excluded.review_count,
  hero_image_url = excluded.hero_image_url,
  price_from = excluded.price_from;

insert into public.hotel_images (hotel_id, image_url, sort_order, is_primary)
select
  h.id,
  h.hero_image_url,
  0,
  true
from public.hotels h
on conflict do nothing;

insert into public.hotel_amenities (hotel_id, amenity_id)
select
  h.id,
  a.id
from public.hotels h
cross join public.amenities a
where a.name in ('Swimming Pool', '5-Star Rating', 'Family Gym', '24h Service', 'Good Food', 'Sky Bar')
on conflict do nothing;

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
select
  h.id,
  room.name,
  room.description,
  room.price_per_night,
  room.capacity,
  room.total_rooms,
  room.bed_type,
  room.breakfast_included,
  room.refundable
from public.hotels h
cross join lateral (
  values
    (
      'Standard Room',
      'Comfortable standard stay for couples or solo travelers.',
      h.price_from,
      2,
      12,
      'Queen Bed',
      true,
      false
    ),
    (
      'Deluxe Room',
      'Upgraded room with more space and a better view.',
      h.price_from + 40,
      3,
      8,
      'King Bed',
      true,
      true
    ),
    (
      'Family Room',
      'Family-friendly room with extra beds and more space.',
      h.price_from + 80,
      4,
      5,
      '2 Double Beds',
      true,
      true
    )
) as room (
  name,
  description,
  price_per_night,
  capacity,
  total_rooms,
  bed_type,
  breakfast_included,
  refundable
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
  day_series.available_date,
  greatest(rt.total_rooms - 1, 0),
  rt.price_per_night
from public.room_types rt
cross join lateral generate_series(
  current_date,
  current_date + interval '60 day',
  interval '1 day'
) as day_series (available_date)
on conflict (room_type_id, available_date) do update
set
  available_rooms = excluded.available_rooms,
  base_price = excluded.base_price;

