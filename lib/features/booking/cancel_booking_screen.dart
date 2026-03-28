import 'package:flutter/material.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({
    super.key,
    this.booking,
  });

  static const routeName = '/cancel-booking';

  final BookingItem? booking;

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  bool _isSubmitting = false;

  Future<void> _cancelBooking() async {
    setState(() => _isSubmitting = true);

    try {
      if (widget.booking != null) {
        await AppServices.bookings.cancelBooking(widget.booking!);
      }

      if (!mounted) {
        return;
      }

      final bool? acknowledged = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.task_alt, color: Colors.green, size: 96),
              const SizedBox(height: 10),
              const Text(
                'Cancel Successful!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your booking ticket has been canceled successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'OK',
                onPressed: () => Navigator.of(context).pop(true),
                height: 52,
                radius: 26,
              ),
            ],
          ),
        ),
      );

      if (!mounted || acknowledged != true) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cancel Hotel Booking',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cancel this booking ticket.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.booking != null) ...[
              const SizedBox(height: 12),
              Text(
                '${widget.booking!.hotelName} - ${widget.booking!.city}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'This booking will be removed from Ongoing and appear in the Canceled tab.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: _isSubmitting ? 'Canceling...' : 'Cancel Booking',
              onPressed: _isSubmitting ? null : _cancelBooking,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: AppTheme.background,
    );
  }
}
