import 'package:hote_v2/data/models/search_result_item.dart';

class BookingFlowData {
  const BookingFlowData({
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.cardLabel,
    required this.roomType,
  });

  final SearchResultItem hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String title;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String email;
  final String phoneNumber;
  final String paymentMethod;
  final String cardLabel;
  final String roomType;

  factory BookingFlowData.fromResult(SearchResultItem hotel) {
    return BookingFlowData(
      hotel: hotel,
      checkIn: DateTime(2025, 8, 17),
      checkOut: DateTime(2025, 8, 19),
      guests: 3,
      title: 'Mr.',
      firstName: 'Leonel Andres',
      lastName: 'Messi',
      dateOfBirth: '24 June 1987',
      email: 'guest@khmerhotel.com',
      phoneNumber: '011 111 111',
      paymentMethod: 'ABA',
      cardLabel: '.... ........ 4672',
      roomType: 'Family Room',
    );
  }

  int get nights {
    final diff = checkOut.difference(checkIn).inDays;
    return diff <= 0 ? 1 : diff;
  }

  int get subTotal => hotel.price * nights;

  int get taxes => 20;

  int get total => subTotal + taxes;

  String get guestName => '$firstName $lastName'.trim();

  BookingFlowData copyWith({
    SearchResultItem? hotel,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    String? title,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? email,
    String? phoneNumber,
    String? paymentMethod,
    String? cardLabel,
    String? roomType,
  }) {
    return BookingFlowData(
      hotel: hotel ?? this.hotel,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardLabel: cardLabel ?? this.cardLabel,
      roomType: roomType ?? this.roomType,
    );
  }
}
