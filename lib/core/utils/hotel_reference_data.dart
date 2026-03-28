class HotelReferenceData {
  HotelReferenceData._();

  static const Map<String, String> _officialHotelImages = <String, String>{
    'rosewood phnom penh':
        'https://picasso.rosewoodhotelgroup.com/transform/7fae2665-f55a-4fb0-a65d-523f21820bac/RWPPN_3-0_Brand-com_Assets_Accommodation_Bedroom_Executive_King_Room',
    'palace gate hotel':
        'https://palacegatepp.com/wp-content/uploads/2023/02/Palace-Gate-Hotel-Pool-1024x683.png',
    'sofitel phnom penh phokeethra':
        'https://www.sofitel-phnompenh-phokeethra.com/wp-content/uploads/sites/90/2022/05/RoomSuites-1-1.jpg',
    'raffles hotel le royal':
        'https://m.ahstatic.com/is/image/accorhotels/aja_p_7238-05?wid=1920',
    'shangri-la phnom penh':
        'https://sitecore-cd-imgr.shangri-la.com/MediaFiles/E/F/6/{EF652EA4-BC1B-413B-B901-0673EE76D648}20250319_slpp_exterior_hires.png',
    'golden temple hotel':
        'https://goldentemplehotel.com/wp-content/uploads/2025/02/Golden-Temple-Hotel-Second-Send-35.jpg',
    'shinta mani angkor':
        'https://shintamani.com/wp-content/uploads/2024/08/SMMBC-The-Living-Room-4-32.jpg',
    'saem siemreap hotel':
        'https://www.saemsiemreaphotel.com/wp-content/uploads/2022/11/220A2226.jpg',
    'sofitel angkor':
        'https://d2e5ushqwiltxm.cloudfront.net/wp-content/uploads/sites/104/2020/09/18085904/Nothing-Like-Siem-Reap.jpg',
    'kampot sweet boutique':
        'https://kampotsweetboutique.com/uploads/banner/DSC_3179.jpg',
    'amber kampot':
        'https://amber-kampot.com/wp-content/uploads/2020/06/PV-exterior-02-min.jpg',
    'sabay beach':
        'https://static.wixstatic.com/media/368149_2e9445208f674b729d90e519c32e296a~mv2.jpg/v1/fill/w_1268,h_713,al_c/368149_2e9445208f674b729d90e519c32e296a~mv2.jpg',
    'veranda natural resort':
        'https://verandaresortkep.com/wafx_res/verandahome/room/swimmingpoolbar.jpg',
    'knai bang chatt':
        'https://static.wixstatic.com/media/a31d6e_57ffef39fe3443dd9086e721e62ef7a0~mv2.jpg/v1/fill/w_2500,h_1474,al_c/a31d6e_57ffef39fe3443dd9086e721e62ef7a0~mv2.jpg',
    'raingsey bungalow':
        'https://raingsey.com/wp-content/uploads/2018/10/homepage-pool.jpg',
    'classy hotel battambang':
        'https://classyhotelspa.com/wp-content/uploads/2025/11/Classy-hotel-1920-x-1080.jpg',
    'tatai eco lodge':
        'https://thansurtataiecoresort.com/wp-content/uploads/2022/07/thansur-tatai-eco-resort-slider-1.jpg',
  };

  static const Map<String, String> _officialHotelAddresses = <String, String>{
    'rosewood phnom penh':
        'Vattanac Capital Tower, Monivong Boulevard, Sangkat Wat Phnom, Khan Daun Penh, Phnom Penh',
    'kampot sweet boutique':
        'Krang Village, Trapeang Thum Commune, Tuek Chhou District, Kampot Province',
    'golden temple hotel':
        'Night Market Road, Steung Thmei, Siem Reap, Kingdom of Cambodia',
    'sofitel angkor':
        'Vithei Charles de Gaulle, Khum Svay Dang Kum, Siem Reap Province',
    'raffles hotel le royal':
        '92 Rukhak Vithei Daun Penh, Sangkat Wat Phnom, Phnom Penh',
    'shangri-la phnom penh':
        'One Phnom Penh, Village 1, Srah Chak Commune, Daun Penh District, Phnom Penh',
    'raingsey bungalow':
        'Thmey Village, Prey Thom Commune, Crab Market, Kep Province',
    'tatai eco lodge':
        'Koh Andet Village, Tatai Commune, Koh Kong District, Koh Kong Province',
  };

  static String? officialImageForHotel(String hotelName) {
    return _officialHotelImages[_normalizeKey(hotelName)];
  }

  static String resolveAddress(
    String hotelName, {
    String? source,
    String? city,
    String? province,
  }) {
    final String override =
        _officialHotelAddresses[_normalizeKey(hotelName)] ?? '';
    if (override.isNotEmpty) {
      return override;
    }

    final String trimmed = source?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    final String provinceValue = province?.trim() ?? '';
    if (provinceValue.isNotEmpty) {
      return provinceValue;
    }

    return city?.trim() ?? '';
  }

  static String _normalizeKey(String value) {
    return value.trim().toLowerCase();
  }
}
