import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/features/booking/add_card_screen.dart';
import 'package:hote_v2/features/booking/booking_summary_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.bookingFlow,
  });

  final BookingFlowData bookingFlow;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.bookingFlow.paymentMethod;
  }

  void _openAddCard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddCardScreen(
          bookingFlow: widget.bookingFlow.copyWith(paymentMethod: 'Card'),
        ),
      ),
    );
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingSummaryScreen(
          bookingFlow: widget.bookingFlow.copyWith(
            paymentMethod: _selectedMethod,
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
          'Payment',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _openAddCard,
            child: const Text(
              'Add New Card',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _PaymentMethodTile(
              title: 'ABA',
              subtitle: 'Bank payment',
              leading: const _BankBadge(
                  label: 'ABA',
                  color: Color(0xFF0B5B7A),
                  imagePath: 'assets/aba.png'),
              selected: _selectedMethod == 'ABA',
              onTap: () => setState(() => _selectedMethod = 'ABA'),
            ),
            const SizedBox(height: 10),
            _PaymentMethodTile(
              title: 'Acleda',
              subtitle: 'Bank payment',
              leading: const _BankBadge(
                  label: 'A',
                  color: Color(0xFF0B5B7A),
                  imagePath: 'assets/ac.png'),
              selected: _selectedMethod == 'Acleda',
              onTap: () => setState(() => _selectedMethod = 'Acleda'),
            ),
            const SizedBox(height: 10),
            _PaymentMethodTile(
              title: 'Wing',
              subtitle: 'Bank payment',
              leading: const _BankBadge(
                  label: 'W',
                  color: Color.fromARGB(255, 40, 128, 2),
                  imagePath: 'assets/wing.png'),
              selected: _selectedMethod == 'Wing',
              onTap: () => setState(() => _selectedMethod = 'Wing'),
            ),
            const SizedBox(height: 10),
            _PaymentMethodTile(
              title: 'Cash',
              subtitle: 'Pay at hotel',
              leading: const _BankBadge(
                  label: '\$',
                  color: Color(0xFF0B5B7A),
                  imagePath: 'assets/cash.png'),
              selected: _selectedMethod == 'Cash',
              onTap: () => setState(() => _selectedMethod = 'Cash'),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pay now with Card',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _PaymentMethodTile(
              title: widget.bookingFlow.cardLabel,
              subtitle: 'Saved card',
              leading: const Icon(
                Icons.credit_card_rounded,
                size: 30,
                color: AppTheme.textPrimary,
              ),
              selected: _selectedMethod == 'Card',
              onTap: () => setState(() => _selectedMethod = 'Card'),
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

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8D8D8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppTheme.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _BankBadge extends StatelessWidget {
  const _BankBadge(
      {required this.label, required this.color, required this.imagePath});

  final String label;
  final Color color;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 34,
      alignment: Alignment.center,
      // decoration: BoxDecoration(
      //   color: color,
      //   borderRadius: BorderRadius.circular(8),
      // ),
      child: Image.asset(
        imagePath,
        width: 70,
        fit: BoxFit.contain,
      ),
    );
  }
}
