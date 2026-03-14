import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/booking/payment_success_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({
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
          'Booking Summary',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
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
                      child: _HotelThumb(hotel: hotel),
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
            const SizedBox(height: 14),
            _SummaryRow(
                title: 'Check in', value: _formatDate(bookingFlow.checkIn)),
            _SummaryRow(
                title: 'Check out', value: _formatDate(bookingFlow.checkOut)),
            _SummaryRow(title: 'Room Type', value: bookingFlow.roomType),
            _SummaryRow(title: 'Guest', value: '${bookingFlow.guests}'),
            _SummaryRow(title: '\$/night', value: '\$${hotel.price}'),
            _SummaryRow(title: 'Tax 10%', value: '\$${bookingFlow.taxes}'),
            const Divider(height: 26),
            _SummaryRow(
              title: 'Total',
              value: '\$${bookingFlow.total}',
              emphasize: true,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE1D7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card_rounded,
                      color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bookingFlow.paymentMethod == 'Card'
                          ? bookingFlow.cardLabel
                          : bookingFlow.paymentMethod,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.circle, size: 10, color: AppTheme.primary),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Confirm',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PaymentSuccessScreen(
                      bookingFlow: bookingFlow,
                    ),
                  ),
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

  static String _formatDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day} ${date.year}';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.emphasize = false,
  });

  final String title;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasize ? 18 : 14,
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
      color: emphasize ? AppTheme.textPrimary : AppTheme.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(
            value,
            style: style.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _HotelThumb extends StatelessWidget {
  const _HotelThumb({required this.hotel});

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
