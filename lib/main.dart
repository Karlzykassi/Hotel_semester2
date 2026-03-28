import 'package:flutter/material.dart';
import 'package:hote_v2/core/services/app_backend.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/mock/mock_backend_store.dart';
import 'package:hote_v2/features/auth/login_screen.dart';
import 'package:hote_v2/features/auth/register_screen.dart';
import 'package:hote_v2/features/booking/booking_date_screen.dart';
import 'package:hote_v2/features/booking/booking_screen.dart';
import 'package:hote_v2/features/booking/cancel_booking_screen.dart';
import 'package:hote_v2/features/booking/reservation_form_screen.dart';
import 'package:hote_v2/features/home/map_screen.dart';
import 'package:hote_v2/features/onboarding/onboarding_screen.dart';
import 'package:hote_v2/features/shell/main_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBackend.initialize();
  await MockBackendStore.initialize();
  await AppServices.auth.restoreLocalSessionContext();
  runApp(const KhmerHotelApp());
}

class KhmerHotelApp extends StatelessWidget {
  const KhmerHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khmer Hotel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppServices.auth.hasActiveSession
          ? const MainShellScreen()
          : const OnboardingScreen(),
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        MainShellScreen.routeName: (_) => const MainShellScreen(),
        BookingScreen.routeName: (_) => const BookingScreen(),
        ReservationFormScreen.routeName: (_) => const ReservationFormScreen(),
        BookingDateScreen.routeName: (_) => const BookingDateScreen(),
        CancelBookingScreen.routeName: (_) => const CancelBookingScreen(),
        MapScreen.routeName: (_) => const MapScreen(),
      },
    );
  }
}
