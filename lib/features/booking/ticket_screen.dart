import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/shell/main_shell_screen.dart';
import 'package:hote_v2/shared/components/hotel_image.dart';
import 'package:hote_v2/shared/components/primary_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({
    super.key,
    required this.bookingFlow,
  });

  final BookingFlowData bookingFlow;

  @override
  Widget build(BuildContext context) {
    final SearchResultItem hotel = bookingFlow.hotel;
    final String guestName =
        bookingFlow.guestName.isEmpty ? 'Guest not set' : bookingFlow.guestName;
    final String phoneNumber =
        bookingFlow.phoneNumber.isEmpty ? 'N/A' : bookingFlow.phoneNumber;
    final String reference = _ticketReference();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ticket',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE5DDD6)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _TicketHotelCard(hotel: hotel),
                      const SizedBox(height: 10),
                      const _TicketDivider(),
                      const SizedBox(height: 10),
                      _TicketRow(
                        title: 'Check In',
                        value: _fullDate(bookingFlow.checkIn),
                      ),
                      _TicketRow(
                        title: 'Check Out',
                        value: _fullDate(bookingFlow.checkOut),
                      ),
                      _TicketRow(
                        title: 'Room Type',
                        value: bookingFlow.roomType,
                      ),
                      _TicketRow(
                        title: 'Guest',
                        value: '${bookingFlow.guests}',
                      ),
                      _TicketRow(
                        title: 'Total Payment',
                        value: '\$${bookingFlow.total}',
                        emphasize: true,
                      ),
                      const SizedBox(height: 10),
                      const _TicketDivider(),
                      const SizedBox(height: 14),
                      _QrTicketSection(
                        data: _qrPayload(reference),
                        reference: reference,
                      ),
                      const SizedBox(height: 14),
                      const _TicketDivider(),
                      const SizedBox(height: 10),
                      _TicketRow(title: 'Guest Name', value: guestName),
                      _TicketRow(title: 'Phone Number', value: phoneNumber),
                      _TicketRow(
                        title: 'Payment',
                        value: bookingFlow.paymentMethod == 'Card'
                            ? bookingFlow.cardLabel
                            : bookingFlow.paymentMethod,
                      ),
                      _TicketRow(title: 'Reference', value: reference),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const MainShellScreen(initialIndex: 2),
                  ),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: AppTheme.background,
    );
  }

  String _ticketReference() {
    final String hotelCode = (bookingFlow.hotel.id ?? 'hotel')
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    final String trimmedCode = hotelCode.isEmpty
        ? 'HOTEL'
        : hotelCode.substring(0, hotelCode.length > 6 ? 6 : hotelCode.length);
    final String dateCode =
        '${bookingFlow.checkIn.year}${bookingFlow.checkIn.month.toString().padLeft(2, '0')}${bookingFlow.checkIn.day.toString().padLeft(2, '0')}';
    final String guestCode = bookingFlow.guests.toString().padLeft(2, '0');
    return '$trimmedCode-$dateCode-$guestCode';
  }

  String _qrPayload(String reference) {
    return 'Booking Reference: $reference\n'
        'Hotel: ${bookingFlow.hotel.name}\n'
        'City: ${bookingFlow.hotel.city}\n'
        'Check In: ${bookingFlow.checkIn.toIso8601String()}\n'
        'Check Out: ${bookingFlow.checkOut.toIso8601String()}\n'
        'Guests: ${bookingFlow.guests}\n'
        'Total: \$${bookingFlow.total}';
  }

  static String _fullDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.day} ${date.year}';
  }
}

class _TicketHotelCard extends StatelessWidget {
  const _TicketHotelCard({required this.hotel});

  final SearchResultItem hotel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DDD6)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: _TicketImage(hotel: hotel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hotel.city,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    hotel.rating.round().clamp(1, 5),
                    (_) => const Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFFFB800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${hotel.price}',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.title,
    required this.value,
    this.emphasize = false,
  });

  final String title;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: emphasize ? 15 : 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: emphasize ? 18 : 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrTicketSection extends StatelessWidget {
  const _QrTicketSection({
    required this.data,
    required this.reference,
  });

  final String data;
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5DDD6)),
      ),
      child: Column(
        children: [
          QrImageView(
            data: data,
            size: 156,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppTheme.textPrimary,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Scan this QR at check-in',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reference,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Divider(color: Color(0xFFD8D0C9), thickness: 1),
          Positioned(
            left: -22,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppTheme.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -22,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppTheme.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketImage extends StatelessWidget {
  const _TicketImage({required this.hotel});

  final SearchResultItem hotel;

  @override
  Widget build(BuildContext context) {
    return HotelImage(
      source: hotel.imageUrl,
      fallbackColor: hotel.imageColor,
      fit: BoxFit.cover,
    );
  }
}
