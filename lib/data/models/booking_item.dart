enum BookingStatus { ongoing, complete, canceled, saved }

class BookingItem {
  const BookingItem({
    required this.hotelName,
    required this.city,
    required this.status,
  });

  final String hotelName;
  final String city;
  final BookingStatus status;
}
