import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/features/booking/cancel_booking_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class CancelTicketScreen extends StatelessWidget {
  const CancelTicketScreen({
    super.key,
    required this.booking,
  });

  final BookingItem booking;

  @override
  Widget build(BuildContext context) {
    final bookingFlow = booking.bookingFlow;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cancel Ticket',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1D7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.hotelName,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.city,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  if (bookingFlow != null) ...[
                    const SizedBox(height: 14),
                    _DetailRow(
                      title: 'Check In',
                      value: _formatDate(bookingFlow.checkIn),
                    ),
                    _DetailRow(
                      title: 'Check Out',
                      value: _formatDate(bookingFlow.checkOut),
                    ),
                    _DetailRow(
                      title: 'Guest',
                      value: bookingFlow.guestName,
                    ),
                    _DetailRow(
                      title: 'Total Payment',
                      value: '\$${bookingFlow.total}',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD1A6)),
              ),
              child: const Text(
                'Canceling this ticket will stop the booking and the refund will follow your selected refund method.',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Continue Cancel',
              onPressed: () async {
                final bool? didCancel = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => CancelBookingScreen(booking: booking),
                  ),
                );

                if (context.mounted && didCancel == true) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'Keep Booking',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: AppTheme.background,
    );
  }

  static String _formatDate(DateTime date) {
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
