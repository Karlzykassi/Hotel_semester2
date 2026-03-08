import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/data/models/hotel_item.dart';

class AppData {
  static const popularHotels = <HotelItem>[
    HotelItem(
      name: 'Golden Temple Hotel',
      city: 'Krong Siem Reap',
      rating: 4.5,
      properties: 0,
      imageColor: 0xFF5E8B7E,
    ),
    HotelItem(
      name: 'Sofitel Angkor',
      city: 'Siem Reap',
      rating: 4.6,
      properties: 0,
      imageColor: 0xFF7A89C2,
    ),
    HotelItem(
      name: 'Rosewood Phnom Penh',
      city: 'Phnom Penh',
      rating: 4.8,
      properties: 0,
      imageColor: 0xFFA1826F,
    ),
  ];

  static const destinations = <HotelItem>[
    HotelItem(
      name: 'Phnom Penh',
      city: 'Capital',
      rating: 0,
      properties: 546,
      imageColor: 0xFF6F8AC7,
    ),
    HotelItem(
      name: 'Siem Reap',
      city: 'Province',
      rating: 0,
      properties: 663,
      imageColor: 0xFFC08A58,
    ),
    HotelItem(
      name: 'Kampot',
      city: 'Province',
      rating: 0,
      properties: 411,
      imageColor: 0xFF6F9B88,
    ),
    HotelItem(
      name: 'Kep',
      city: 'Province',
      rating: 0,
      properties: 198,
      imageColor: 0xFF9677A9,
    ),
  ];

  static const bookings = <BookingItem>[
    BookingItem(
      hotelName: 'Rosewood Phnom Penh',
      city: 'Phnom Penh',
      status: BookingStatus.ongoing,
      imageColor: 0xFFA1826F,
    ),
    BookingItem(
      hotelName: 'Raffles Hotel Le Royal',
      city: 'Phnom Penh',
      status: BookingStatus.complete,
      imageColor: 0xFF9E8A77,
    ),
    BookingItem(
      hotelName: 'Sofitel Phnom Penh Phokeethra',
      city: 'Phnom Penh',
      status: BookingStatus.saved,
      imageColor: 0xFFB9A792,
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
}
