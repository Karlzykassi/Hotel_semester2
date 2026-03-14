import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/shell/main_shell_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({
    super.key,
    required this.bookingFlow,
  });

  final BookingFlowData bookingFlow;

  @override
  Widget build(BuildContext context) {
    final hotel = bookingFlow.hotel;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ticket',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1D7D0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 92,
                      height: 78,
                      child: _TicketImage(hotel: hotel),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hotel.city,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(
                            hotel.rating.round().clamp(1, 5),
                            (_) => const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFFFB800),
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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _TicketRow(
                title: 'Check In', value: _fullDate(bookingFlow.checkIn)),
            _TicketRow(
                title: 'Check Out', value: _fullDate(bookingFlow.checkOut)),
            _TicketRow(title: 'Guest', value: '${bookingFlow.guests}'),
            _TicketRow(title: 'Guest\'s Name', value: bookingFlow.guestName),
            _TicketRow(title: 'Phone Number', value: bookingFlow.phoneNumber),
            _TicketRow(title: 'Total Payment', value: '\$${bookingFlow.total}'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE1D7D0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ticket QR',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 110,
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Confirm',
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

  static String _fullDate(DateTime date) {
    const months = <String>[
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

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

class _TicketImage extends StatelessWidget {
  const _TicketImage({required this.hotel});

  final SearchResultItem hotel;

  @override
  Widget build(BuildContext context) {
    final source = hotel.imageUrl;
    if (source == null || source.trim().isEmpty) {
      return Container(color: Color(hotel.imageColor));
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: Color(hotel.imageColor));
      },
    );
  }
}
