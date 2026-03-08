import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/features/booking/booking_date_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';
import 'package:hote_v2/shared/components/status_chip.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  static const routeName = '/reservation';

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  String _title = 'Mr.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Name of Reservation', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Divider(),
            Row(
              children: [
                StatusChip(label: 'Mr.', selected: _title == 'Mr.', onTap: () => setState(() => _title = 'Mr.')),
                const SizedBox(width: 10),
                StatusChip(label: 'Mrs.', selected: _title == 'Mrs.', onTap: () => setState(() => _title = 'Mrs.')),
                const SizedBox(width: 10),
                StatusChip(label: 'Ms.', selected: _title == 'Ms.', onTap: () => setState(() => _title = 'Ms.')),
              ],
            ),
            const SizedBox(height: 14),
            const _FormField(hint: 'First Name'),
            const SizedBox(height: 10),
            const _FormField(hint: 'Last Name'),
            const SizedBox(height: 10),
            const _FormField(hint: 'Date of Birth', icon: Icons.calendar_today_outlined),
            const SizedBox(height: 10),
            const _FormField(hint: 'Email', icon: Icons.mail_outline),
            const SizedBox(height: 10),
            const _FormField(hint: '+855'),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              onPressed: () => Navigator.pushNamed(context, BookingDateScreen.routeName),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: AppTheme.background,
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.hint, this.icon});

  final String hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}
