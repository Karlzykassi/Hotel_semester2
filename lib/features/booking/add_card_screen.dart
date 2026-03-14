import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/features/booking/booking_summary_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({
    super.key,
    required this.bookingFlow,
  });

  final BookingFlowData bookingFlow;

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Leonel Andres Messi',
  );
  final TextEditingController _cardController = TextEditingController(
    text: '4672 1234 5678 9012',
  );
  final TextEditingController _monthController = TextEditingController(
    text: 'MM/YY',
  );
  final TextEditingController _cvcController = TextEditingController(
    text: 'CVC',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _monthController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _continue() {
    final digits = _cardController.text.replaceAll(RegExp(r'\D'), '');
    final suffix =
        digits.length >= 4 ? digits.substring(digits.length - 4) : '4672';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingSummaryScreen(
          bookingFlow: widget.bookingFlow.copyWith(
            paymentMethod: 'Card',
            cardLabel: '.... ........ $suffix',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Card',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A356A), Color(0xFF0F5C92)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 18,
                    left: 18,
                    child: Text(
                      'ABA BANK',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                    ),
                  ),
                  const Positioned(
                    left: 18,
                    top: 62,
                    child: Icon(Icons.credit_card, color: Color(0xFFFFD66E)),
                  ),
                  const Positioned(
                    bottom: 18,
                    left: 18,
                    child: Text(
                      '.... .... .... 4672',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 18,
                    right: 18,
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 12, backgroundColor: Color(0xFFFF8B00)),
                        SizedBox(width: 6),
                        CircleAvatar(
                            radius: 12, backgroundColor: Color(0xFFE43C3C)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CardField(
              hint: 'Card Holder Name',
              controller: _nameController,
            ),
            const SizedBox(height: 10),
            _CardField(
              hint: 'Card Number',
              controller: _cardController,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _CardField(
                    hint: 'MM/YY',
                    controller: _monthController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CardField(
                    hint: 'CVC',
                    controller: _cvcController,
                  ),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Add New Card',
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

class _CardField extends StatelessWidget {
  const _CardField({
    required this.hint,
    required this.controller,
  });

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
    );
  }
}
