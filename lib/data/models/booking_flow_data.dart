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
    final DateTime today = DateTime.now();
    final DateTime checkIn = DateTime(today.year, today.month, today.day);
    final DateTime checkOut = checkIn.add(const Duration(days: 1));

    return BookingFlowData(
      hotel: hotel,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: 1,
      title: 'Mr.',
      firstName: '',
      lastName: '',
      dateOfBirth: '',
      email: '',
      phoneNumber: '',
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
