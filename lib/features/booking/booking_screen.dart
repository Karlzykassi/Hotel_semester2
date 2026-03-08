import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/mock/app_data.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/features/booking/booking_date_screen.dart';
import 'package:hote_v2/features/booking/cancel_booking_screen.dart';
import 'package:hote_v2/shared/components/booking_card.dart';
import 'package:hote_v2/shared/components/status_chip.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  static const routeName = '/booking';

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  BookingStatus _status = BookingStatus.ongoing;

  String _label(BookingStatus status) {
    switch (status) {
      case BookingStatus.ongoing:
        return 'Oganing';
      case BookingStatus.complete:
        return 'Complete';
      case BookingStatus.canceled:
        return 'Canceled';
      case BookingStatus.saved:
        return 'Saved';
    }
  }

  List<BookingItem> _items() {
    if (_status == BookingStatus.ongoing) {
      return const [
        BookingItem(
          hotelName: 'Rosewood Phnom Penh',
          city: 'Phnom Penh',
          status: BookingStatus.ongoing,
          imageColor: 0xFFA1826F,
        ),
        BookingItem(
          hotelName: 'Raffles Hotel Le Royal',
          city: 'Phnom Penh',
          status: BookingStatus.ongoing,
          imageColor: 0xFF9E8A77,
        ),
        BookingItem(
          hotelName: 'Sofitel Phnom Penh Phokeethra',
          city: 'Phnom Penh',
          status: BookingStatus.ongoing,
          imageColor: 0xFFB9A792,
        ),
      ];
    }

    return AppData.bookings
        .map(
          (item) => BookingItem(
            hotelName: item.hotelName,
            city: item.city,
            status: _status,
            imageColor: item.imageColor,
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  StatusChip(
                    label: _label(BookingStatus.ongoing),
                    selected: _status == BookingStatus.ongoing,
                    onTap: () => setState(() => _status = BookingStatus.ongoing),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: _label(BookingStatus.complete),
                    selected: _status == BookingStatus.complete,
                    onTap: () => setState(() => _status = BookingStatus.complete),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: _label(BookingStatus.canceled),
                    selected: _status == BookingStatus.canceled,
                    onTap: () => setState(() => _status = BookingStatus.canceled),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: _label(BookingStatus.saved),
                    selected: _status == BookingStatus.saved,
                    onTap: () => setState(() => _status = BookingStatus.saved),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return BookingCard(
                    item: items[index],
                    onPrimary: () {
                      if (_status == BookingStatus.ongoing) {
                        Navigator.pushNamed(context, CancelBookingScreen.routeName);
                      }
                    },
                    onSecondary: () {
                      Navigator.pushNamed(context, BookingDateScreen.routeName);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.background,
    );
  }
}
