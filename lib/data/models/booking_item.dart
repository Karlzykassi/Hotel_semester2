import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/search_result_item.dart';

enum BookingStatus { ongoing, complete, canceled, saved }

class BookingItem {
  const BookingItem({
    this.id,
    required this.hotelName,
    required this.city,
    required this.status,
    this.bookingFlow,
  });

  final String? id;
  final String hotelName;
  final String city;
  final BookingStatus status;
  final BookingFlowData? bookingFlow;

  bool get canCancel => status == BookingStatus.ongoing;

  factory BookingItem.fromSupabase(Map<String, dynamic> row) {
    final Map<String, dynamic> hotel = _relationMap(row['hotels']);
    final Map<String, dynamic> roomType = _relationMap(row['room_types']);

    final SearchResultItem? hotelResult = hotel.isEmpty
        ? null
        : SearchResultItem.fromSupabase(<String, dynamic>{
            'id': hotel['id'],
            'name': hotel['name'],
            'city': hotel['city'],
            'province': hotel['province'],
            'address': hotel['address'],
            'rating': hotel['rating'],
            'price': roomType['price_per_night'] ?? hotel['price_from'],
            'image_url': hotel['hero_image_url'],
            'latitude': hotel['latitude'],
            'longitude': hotel['longitude'],
            'google_maps_uri': hotel['google_maps_uri'],
          });

    final BookingFlowData? flow = hotelResult == null
        ? null
        : BookingFlowData(
            hotel: hotelResult,
            checkIn: DateTime.tryParse('${row['check_in_date'] ?? ''}') ??
                DateTime(2025, 8, 17),
            checkOut: DateTime.tryParse('${row['check_out_date'] ?? ''}') ??
                DateTime(2025, 8, 19),
            guests: _asInt(row['guest_count'], fallback: 1),
            title: (row['title'] as String?) ?? 'Mr.',
            firstName: (row['first_name'] as String?) ?? 'Guest',
            lastName: (row['last_name'] as String?) ?? '',
            dateOfBirth: _displayDate(row['date_of_birth']),
            email: (row['email'] as String?) ?? 'guest@khmerhotel.com',
            phoneNumber: (row['phone_number'] as String?) ?? 'N/A',
            paymentMethod: _paymentMethodLabel(
              (row['payment_method'] as String?) ?? 'cash',
            ),
            cardLabel: '.... ........ 4672',
            roomType: (roomType['name'] as String?) ?? 'Standard Room',
          );

    return BookingItem(
      id: row['id'] as String?,
      hotelName: (hotel['name'] as String?) ?? 'Hotel',
      city: ((hotel['province'] as String?)?.trim().isNotEmpty ?? false)
          ? (hotel['province'] as String).trim()
          : ((hotel['city'] as String?) ?? ''),
      status: _statusFromString((row['status'] as String?) ?? 'pending'),
      bookingFlow: flow,
    );
  }

  BookingItem copyWith({
    String? id,
    String? hotelName,
    String? city,
    BookingStatus? status,
    BookingFlowData? bookingFlow,
  }) {
    return BookingItem(
      id: id ?? this.id,
      hotelName: hotelName ?? this.hotelName,
      city: city ?? this.city,
      status: status ?? this.status,
      bookingFlow: bookingFlow ?? this.bookingFlow,
    );
  }

  static BookingStatus _statusFromString(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return BookingStatus.complete;
      case 'reject':
      case 'rejected':
      case 'cancelled':
        return BookingStatus.canceled;
      case 'saved':
        return BookingStatus.saved;
      default:
        return BookingStatus.ongoing;
    }
  }

  static Map<String, dynamic> _relationMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    if (value is List && value.isNotEmpty && value.first is Map) {
      return Map<String, dynamic>.from(value.first as Map);
    }
    return <String, dynamic>{};
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? fallback;
  }

  static String _paymentMethodLabel(String value) {
    switch (value.toLowerCase()) {
      case 'aba':
        return 'ABA';
      case 'acleda':
        return 'Acleda';
      case 'wing':
        return 'Wing';
      case 'card':
        return 'Card';
      default:
        return 'Cash';
    }
  }

  static String _displayDate(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return '';
    }

    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }
}
