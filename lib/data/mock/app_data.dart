import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/data/models/hotel_item.dart';
import 'package:hote_v2/data/models/search_result_item.dart';

class AppData {
  static const popularHotels = <HotelItem>[
    HotelItem(
      name: 'Golden Temple Hotel',
      city: 'Krong, Siem Reap',
      rating: 4.5,
      properties: 0,
      imageColor: 0xFF5E8B7E,
      imageUrl: 'assets/Hotel 1.jpg',
    ),
    HotelItem(
      name: 'Sofitel Angkor',
      city: 'Siem Reap',
      rating: 4.6,
      properties: 0,
      imageColor: 0xFF7A89C2,
      imageUrl: 'assets/Hotel 1.jpg',
    ),
    HotelItem(
      name: 'Rosewood Phnom Penh',
      city: 'Phnom Penh',
      rating: 4.8,
      properties: 0,
      imageColor: 0xFFA1826F,
      imageUrl: 'assets/Hotel 1.jpg',
    ),
  ];

  static const destinations = <HotelItem>[
    HotelItem(
      name: 'Phnom Penh',
      city: 'Capital',
      rating: 0,
      properties: 546,
      imageColor: 0xFF6F8AC7,
      imageUrl: 'assets/Hotel 1.jpg',
    ),
    HotelItem(
      name: 'Siem Reap',
      city: 'Province',
      rating: 0,
      properties: 663,
      imageColor: 0xFFC08A58,
      imageUrl: 'assets/Hotel 1.jpg',
    ),
    HotelItem(
      name: 'Kampot',
      city: 'Province',
      rating: 0,
      properties: 411,
      imageColor: 0xFF6F9B88,
      imageUrl: 'assets/Hotel 1.jpg',
    ),
    HotelItem(
      name: 'Kep',
      city: 'Province',
      rating: 0,
      properties: 198,
      imageColor: 0xFF9677A9,
      imageUrl: 'assets/Hotel 1.jpg',
    ),
  ];

  static const bookings = <BookingItem>[
    BookingItem(
      hotelName: 'Rosewood Phnom Penh',
      city: 'Phnom Penh',
      status: BookingStatus.ongoing,
    ),
    BookingItem(
      hotelName: 'Raffles Hotel Le Royal',
      city: 'Phnom Penh',
      status: BookingStatus.complete,
    ),
    BookingItem(
      hotelName: 'Sofitel Phnom Penh Phokeethra',
      city: 'Phnom Penh',
      status: BookingStatus.saved,
    ),
  ];

  static const searchHistory = <String>[
    'Somnang Hotel',
    'Golden Temple Hotel',
    'Rosewood Phnom Penh Hotel',
    'Leonel Messi Hotel',
  ];

  static const cities = <String>[
    'Phnom Penh',
    'Siem Reap',
    'Kampot',
    'Kep',
  ];

  static const searchResultCounts = <String, int>{
    'Phnom Penh': 123,
    'Siem Reap': 663,
    'Kampot': 123,
    'Kep': 123,
  };

  static const searchResultsByCity = <String, List<SearchResultItem>>{
    'Phnom Penh': <SearchResultItem>[
      SearchResultItem(
        name: 'Rosewood Phnom Penh',
        city: 'Phnom Penh',
        rating: 5.0,
        price: 300,
        imageColor: 0xFFC5AE95,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Raffles Hotel Le Royal',
        city: 'Phnom Penh',
        rating: 4.5,
        price: 240,
        imageColor: 0xFFD8C1A1,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Sofitel Phnom Penh Phokeethra',
        city: 'Phnom Penh',
        rating: 4.0,
        price: 200,
        imageColor: 0xFFD2B297,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Shangri-La Phnom Penh',
        city: 'Phnom Penh',
        rating: 2.0,
        price: 100,
        imageColor: 0xFFB8A698,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Palace Gate Hotel',
        city: 'Phnom Penh',
        rating: 4.5,
        price: 220,
        imageColor: 0xFFC1A88D,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
    ],
    'Siem Reap': <SearchResultItem>[
      SearchResultItem(
        name: 'Golden Temple Hotel',
        city: 'Siem Reap',
        rating: 5.0,
        price: 300,
        imageColor: 0xFFB8B094,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Saem Siemreap Hotel',
        city: 'Siem Reap',
        rating: 4.5,
        price: 200,
        imageColor: 0xFF7A8B7D,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'The Jungle',
        city: 'Siem Reap',
        rating: 3.0,
        price: 200,
        imageColor: 0xFF65865B,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Koulen Central Hotel',
        city: 'Siem Reap',
        rating: 2.0,
        price: 100,
        imageColor: 0xFF7FA0A8,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Shinta Mani Angkor',
        city: 'Siem Reap',
        rating: 4.5,
        price: 260,
        imageColor: 0xFF8B7A63,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
    ],
    'Kampot': <SearchResultItem>[
      SearchResultItem(
        name: 'Kampot Sweet Boutique',
        city: 'Kampot',
        rating: 5.0,
        price: 300,
        imageColor: 0xFF7E9E8C,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Rainforest Hotel',
        city: 'Kampot',
        rating: 4.0,
        price: 200,
        imageColor: 0xFF5D7F73,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Amber Kampot',
        city: 'Kampot',
        rating: 3.0,
        price: 200,
        imageColor: 0xFF8F6E62,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Sabay Beach',
        city: 'Kampot',
        rating: 2.0,
        price: 100,
        imageColor: 0xFF9E8B68,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Castle Bayview Resort',
        city: 'Kampot',
        rating: 4.0,
        price: 210,
        imageColor: 0xFF688AA4,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
    ],
    'Kep': <SearchResultItem>[
      SearchResultItem(
        name: 'Raingsey Bungalow',
        city: 'Kep',
        rating: 5.0,
        price: 300,
        imageColor: 0xFF7B5A42,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Saravoan-Kep Hotel',
        city: 'Kep',
        rating: 4.0,
        price: 200,
        imageColor: 0xFFBBA887,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Kep Bay Hotel & Resort',
        city: 'Kep',
        rating: 3.0,
        price: 200,
        imageColor: 0xFF5D8CA5,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Knai Bang Chatt',
        city: 'Kep',
        rating: 2.0,
        price: 100,
        imageColor: 0xFF91A17F,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
      SearchResultItem(
        name: 'Veranda Natural Resort',
        city: 'Kep',
        rating: 4.0,
        price: 220,
        imageColor: 0xFF799B6C,
        imageUrl: 'assets/Hotel 1.jpg',
      ),
    ],
  };
}
