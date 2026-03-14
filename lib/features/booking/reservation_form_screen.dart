import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/features/booking/booking_date_screen.dart';
import 'package:hote_v2/features/booking/payment_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';
import 'package:hote_v2/shared/components/status_chip.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({
    super.key,
    this.bookingFlow,
  });

  static const routeName = '/reservation';
  final BookingFlowData? bookingFlow;

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  late String _title;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _title = widget.bookingFlow?.title ?? 'Mr.';
    _firstNameController = TextEditingController(
      text: widget.bookingFlow?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.bookingFlow?.lastName ?? '',
    );
    _dateOfBirthController = TextEditingController(
      text: widget.bookingFlow?.dateOfBirth ?? '',
    );
    _emailController = TextEditingController(
      text: widget.bookingFlow?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.bookingFlow?.phoneNumber ?? '+855',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (widget.bookingFlow == null) {
      Navigator.pushNamed(context, BookingDateScreen.routeName);
      return;
    }

    final updatedFlow = widget.bookingFlow!.copyWith(
      title: _title,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentScreen(bookingFlow: updatedFlow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Name of Reservation',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Divider(),
            Row(
              children: [
                StatusChip(
                  label: 'Mr.',
                  selected: _title == 'Mr.',
                  onTap: () => setState(() => _title = 'Mr.'),
                ),
                const SizedBox(width: 10),
                StatusChip(
                  label: 'Mrs.',
                  selected: _title == 'Mrs.',
                  onTap: () => setState(() => _title = 'Mrs.'),
                ),
                const SizedBox(width: 10),
                StatusChip(
                  label: 'Ms.',
                  selected: _title == 'Ms.',
                  onTap: () => setState(() => _title = 'Ms.'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormField(
              hint: 'First Name',
              controller: _firstNameController,
            ),
            const SizedBox(height: 10),
            _FormField(
              hint: 'Last Name',
              controller: _lastNameController,
            ),
            const SizedBox(height: 10),
            _FormField(
              hint: 'Date of Birth',
              icon: Icons.calendar_today_outlined,
              controller: _dateOfBirthController,
            ),
            const SizedBox(height: 10),
            _FormField(
              hint: 'Email',
              icon: Icons.mail_outline,
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            _FormField(
              hint: '+855',
              controller: _phoneController,
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              onPressed: _continue,
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
  const _FormField({
    required this.hint,
    required this.controller,
    this.icon,
  });

  final String hint;
  final TextEditingController controller;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}
