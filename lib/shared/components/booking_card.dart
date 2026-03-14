import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.item,
    required this.onPrimary,
    this.onSecondary,
  });

  final BookingItem item;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;

  String _badgeText() {
    switch (item.status) {
      case BookingStatus.ongoing:
        return 'Paid';
      case BookingStatus.complete:
        return 'Complete';
      case BookingStatus.canceled:
        return 'Cancel & Refund';
      case BookingStatus.saved:
        return 'View';
    }
  }

  String _bottomMessage() {
    switch (item.status) {
      case BookingStatus.ongoing:
        return '';
      case BookingStatus.complete:
        return 'Yeay, You have Complete it!';
      case BookingStatus.canceled:
        return 'You Canceled this hotel Booking';
      case BookingStatus.saved:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomMessage = _bottomMessage();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 14,
            offset: Offset(0, 6),
            spreadRadius: 0.3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: Image.asset(AppAssets.hotel1, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.hotelName,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.city,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E7E7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _badgeText(),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.bookmark_border_rounded,
                  color: AppTheme.primary),
            ],
          ),
          if (item.status == BookingStatus.ongoing)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Canceled Booking',
                      onPressed: onPrimary,
                      height: 42,
                      fontSize: 14,
                      radius: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: 'View Ticket',
                      onPressed: onSecondary ?? onPrimary,
                      height: 42,
                      fontSize: 14,
                      radius: 20,
                    ),
                  ),
                ],
              ),
            )
          else if (bottomMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    item.status == BookingStatus.complete
                        ? Icons.check_box
                        : Icons.close,
                    color: item.status == BookingStatus.complete
                        ? Colors.green
                        : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bottomMessage,
                      style: TextStyle(
                        color: item.status == BookingStatus.complete
                            ? Colors.green
                            : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
