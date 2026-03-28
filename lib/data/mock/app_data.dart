import 'package:hote_v2/data/mock/cambodia_hotel_catalog.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/data/models/hotel_item.dart';
import 'package:hote_v2/data/models/search_result_item.dart';

class AppData {
  static final List<HotelItem> popularHotels =
      CambodiaHotelCatalog.popularHotels;

  static final List<HotelItem> destinations = CambodiaHotelCatalog.destinations;

  static const List<BookingItem> bookings = <BookingItem>[
    BookingItem(
      hotelName: 'Rosewood Phnom Penh',
      city: 'Phnom Penh',
      status: BookingStatus.ongoing,
    ),
    BookingItem(
      hotelName: 'Golden Temple Hotel',
      city: 'Siem Reap',
      status: BookingStatus.complete,
    ),
    BookingItem(
      hotelName: 'Veranda Natural Resort',
      city: 'Kep',
      status: BookingStatus.saved,
    ),
  ];

  static const List<String> searchHistory = <String>[
    'Golden Temple Hotel',
    'Battambang Riverside Hotel',
    'Sihanoukville Bay Hotel',
    'Mondulkiri Hill Resort',
  ];

  static final List<String> cities = CambodiaHotelCatalog.cities;

  static final Map<String, int> searchResultCounts =
      CambodiaHotelCatalog.searchResultCounts;

  static final Map<String, List<SearchResultItem>> searchResultsByCity =
      CambodiaHotelCatalog.searchResultsByCity;
}
