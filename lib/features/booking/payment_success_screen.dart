import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/features/booking/ticket_screen.dart';
import 'package:hote_v2/features/shell/main_shell_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.bookingFlow,
  });

  final BookingFlowData bookingFlow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x477B7B7B),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF37B833),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  color: Color(0xFF37B833),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Successfully made payment\nfor hotel booking',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'View Ticket',
                height: 52,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TicketScreen(bookingFlow: bookingFlow),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const MainShellScreen(initialIndex: 2),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: Color(0xFFD9E8D2)),
                  backgroundColor: const Color(0xFFE7F1E1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF607A57),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
