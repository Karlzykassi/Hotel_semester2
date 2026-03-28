import 'package:flutter/material.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/booking/payment_success_screen.dart';
import 'package:hote_v2/shared/components/hotel_image.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({
    super.key,
    required this.bookingFlow,
  });

  final BookingFlowData bookingFlow;

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isSaving = false;

  Future<void> _confirmBooking() async {
    setState(() => _isSaving = true);

    try {
      await AppServices.bookings.createBooking(widget.bookingFlow);
      if (!mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaymentSuccessScreen(
            bookingFlow: widget.bookingFlow,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SearchResultItem hotel = widget.bookingFlow.hotel;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Summary',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
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
                        _HotelSummaryCard(hotel: hotel),
                        const SizedBox(height: 10),
                        const _TicketDivider(),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          title: 'Check in',
                          value: _formatDate(widget.bookingFlow.checkIn),
                        ),
                        _SummaryRow(
                          title: 'Check Out',
                          value: _formatDate(widget.bookingFlow.checkOut),
                        ),
                        _SummaryRow(
                          title: 'Room Type',
                          value: widget.bookingFlow.roomType,
                        ),
                        _SummaryRow(
                          title: 'Guest',
                          value: '${widget.bookingFlow.guests}',
                        ),
                        _SummaryRow(
                          title: '\$/Night',
                          value: '\$${hotel.price}',
                        ),
                        _SummaryRow(
                          title: 'Taxes 10%',
                          value: '\$${widget.bookingFlow.taxes}',
                        ),
                        const SizedBox(height: 10),
                        const _TicketDivider(),
                        const SizedBox(height: 10),
                        _SummaryRow(
                          title: 'Total',
                          value: '\$${widget.bookingFlow.total}',
                          emphasize: true,
                        ),
                        const SizedBox(height: 16),
                        _PaymentMethodCard(
                          paymentMethod: widget.bookingFlow.paymentMethod,
                          cardLabel: widget.bookingFlow.cardLabel,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: _isSaving ? 'Saving...' : 'Confirm',
              onPressed: _isSaving ? null : _confirmBooking,
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

class _HotelSummaryCard extends StatelessWidget {
  const _HotelSummaryCard({required this.hotel});

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
              child: _HotelThumb(hotel: hotel),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: emphasize ? 15 : 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: emphasize ? 20 : 15,
              fontWeight: FontWeight.w700,
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

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.paymentMethod,
    required this.cardLabel,
  });

  final String paymentMethod;
  final String cardLabel;

  @override
  Widget build(BuildContext context) {
    final String label = paymentMethod == 'Card' ? cardLabel : paymentMethod;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DDD6)),
      ),
      child: Row(
        children: [
          _PaymentMethodBadge(paymentMethod: paymentMethod),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodBadge extends StatelessWidget {
  const _PaymentMethodBadge({required this.paymentMethod});

  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    if (paymentMethod == 'ABA') {
      return _PaymentAssetBadge(assetPath: 'assets/aba.png');
    }

    if (paymentMethod == 'Acleda') {
      return _PaymentAssetBadge(assetPath: 'assets/ac.png');
    }

    if (paymentMethod == 'Wing') {
      return _PaymentAssetBadge(assetPath: 'assets/wing.png');
    }

    if (paymentMethod == 'Cash') {
      return _PaymentAssetBadge(assetPath: 'assets/cash.png');
    }

    return Container(
      width: 44,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEE9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.credit_card_rounded, color: AppTheme.primary),
    );
  }
}

class _PaymentAssetBadge extends StatelessWidget {
  const _PaymentAssetBadge({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        assetPath,
        width: 44,
        height: 36,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _HotelThumb extends StatelessWidget {
  const _HotelThumb({required this.hotel});

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
