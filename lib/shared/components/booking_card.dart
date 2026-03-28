import 'package:flutter/material.dart';
import 'package:hote_v2/core/constants/app_assets.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/shared/components/hotel_image.dart';
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
        return 'Upcoming';
      case BookingStatus.complete:
        return 'Completed';
      case BookingStatus.canceled:
        return 'Canceled';
      case BookingStatus.saved:
        return 'Saved';
    }
  }

  Color _badgeColor() {
    switch (item.status) {
      case BookingStatus.ongoing:
        return AppTheme.primary;
      case BookingStatus.complete:
        return AppTheme.success;
      case BookingStatus.canceled:
        return AppTheme.danger;
      case BookingStatus.saved:
        return AppTheme.secondary;
    }
  }

  String _bottomMessage() {
    switch (item.status) {
      case BookingStatus.ongoing:
        return 'Everything is ready for your stay.';
      case BookingStatus.complete:
        return 'This stay has been completed successfully.';
      case BookingStatus.canceled:
        return 'This booking has already been canceled.';
      case BookingStatus.saved:
        return 'Saved for later review.';
    }
  }

  Widget _buildHotelImage() {
    return HotelImage(
      source: item.bookingFlow?.hotel.imageUrl,
      fallbackColor: item.bookingFlow?.hotel.imageColor ?? 0xFFC5AE95,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = _badgeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 106,
                height: 112,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: item.bookingFlow == null
                    ? Image.asset(AppAssets.hotel1, fit: BoxFit.cover)
                    : _buildHotelImage(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.hotelName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _badgeText(),
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.city,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _bottomMessage(),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (item.status == BookingStatus.ongoing)
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrimary,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'View Ticket',
                    onPressed: onSecondary ?? onPrimary,
                    height: 48,
                    fontSize: 14,
                    radius: 18,
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSecondary,
                icon: Icon(
                  item.status == BookingStatus.complete
                      ? Icons.check_circle_rounded
                      : item.status == BookingStatus.canceled
                          ? Icons.block_rounded
                          : Icons.bookmark_rounded,
                  size: 18,
                  color: badgeColor,
                ),
                label: Text(
                  item.status == BookingStatus.complete
                      ? 'Completed Stay'
                      : item.status == BookingStatus.canceled
                          ? 'Canceled Booking'
                          : 'Saved Booking',
                  style: TextStyle(color: badgeColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
