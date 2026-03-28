import 'package:hote_v2/data/repositories/auth_repository.dart';
import 'package:hote_v2/data/repositories/booking_repository.dart';
import 'package:hote_v2/data/repositories/hotel_repository.dart';
import 'package:hote_v2/data/repositories/profile_repository.dart';

class AppServices {
  AppServices._();

  static final AuthRepository auth = AuthRepository();
  static final HotelRepository hotels = HotelRepository();
  static final BookingRepository bookings = BookingRepository();
  static final ProfileRepository profile = ProfileRepository();
}
