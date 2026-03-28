update public.hotels
set hero_image_url = case lower(name)
  when 'rosewood phnom penh' then 'https://picasso.rosewoodhotelgroup.com/transform/7fae2665-f55a-4fb0-a65d-523f21820bac/RWPPN_3-0_Brand-com_Assets_Accommodation_Bedroom_Executive_King_Room'
  when 'palace gate hotel' then 'https://palacegatepp.com/wp-content/uploads/2023/02/Palace-Gate-Hotel-Pool-1024x683.png'
  when 'sofitel phnom penh phokeethra' then 'https://www.sofitel-phnompenh-phokeethra.com/wp-content/uploads/sites/90/2022/05/RoomSuites-1-1.jpg'
  when 'golden temple hotel' then 'https://goldentemplehotel.com/wp-content/uploads/2025/02/Golden-Temple-Hotel-Second-Send-35.jpg'
  when 'shinta mani angkor' then 'https://shintamani.com/wp-content/uploads/2024/08/SMMBC-The-Living-Room-4-32.jpg'
  when 'saem siemreap hotel' then 'https://www.saemsiemreaphotel.com/wp-content/uploads/2022/11/220A2226.jpg'
  when 'kampot sweet boutique' then 'https://kampotsweetboutique.com/uploads/banner/DSC_3179.jpg'
  when 'amber kampot' then 'https://amber-kampot.com/wp-content/uploads/2020/06/PV-exterior-02-min.jpg'
  when 'veranda natural resort' then 'https://verandaresortkep.com/wafx_res/verandahome/room/swimmingpoolbar.jpg'
  when 'knai bang chatt' then 'https://static.wixstatic.com/media/a31d6e_57ffef39fe3443dd9086e721e62ef7a0~mv2.jpg/v1/fill/w_2500,h_1474,al_c/a31d6e_57ffef39fe3443dd9086e721e62ef7a0~mv2.jpg'
  when 'classy hotel battambang' then 'https://classyhotelspa.com/wp-content/uploads/2025/11/Classy-hotel-1920-x-1080.jpg'
  when 'tatai eco lodge' then 'https://thansurtataiecoresort.com/wp-content/uploads/2022/07/thansur-tatai-eco-resort-slider-1.jpg'
  else case coalesce(province, city)
    when 'Phnom Penh' then 'assets/provinces/phnom-penh.jpg'
    when 'Siem Reap' then 'assets/provinces/siem-reap.jpg'
    when 'Kampot' then 'assets/provinces/kampot.jpg'
    when 'Kep' then 'assets/provinces/kep.jpg'
    when 'Battambang' then 'assets/provinces/battambang.jpg'
    when 'Preah Sihanouk' then 'assets/provinces/preah-sihanouk.jpg'
    when 'Koh Kong' then 'assets/provinces/koh-kong.jpg'
    when 'Kratie' then 'assets/provinces/kratie.jpg'
    when 'Mondulkiri' then 'assets/provinces/mondulkiri.jpg'
    when 'Ratanakiri' then 'assets/provinces/ratanakiri.jpg'
    when 'Kampong Cham' then 'assets/provinces/kampong-cham.jpg'
    when 'Kampong Thom' then 'assets/provinces/kampong-thom.jpg'
    else hero_image_url
  end
end;

update public.hotel_images hi
set image_url = h.hero_image_url,
    is_primary = true,
    sort_order = 0
from public.hotels h
where hi.hotel_id = h.id;

insert into public.hotel_images (hotel_id, image_url, sort_order, is_primary)
select
  h.id,
  h.hero_image_url,
  0,
  true
from public.hotels h
where not exists (
  select 1
  from public.hotel_images hi
  where hi.hotel_id = h.id
);
