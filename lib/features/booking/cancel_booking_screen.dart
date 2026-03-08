import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  static const routeName = '/cancel-booking';

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  String _selectedMethod = 'ABA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancel Hotel Booking', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please select a payment refund method ( Only 80% will be Refunded )',
              style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _PaymentOptionTile(
              title: 'ABA',
              icon: Icons.account_balance_wallet,
              selected: _selectedMethod == 'ABA',
              onTap: () => setState(() => _selectedMethod = 'ABA'),
            ),
            const SizedBox(height: 8),
            _PaymentOptionTile(
              title: 'Acleda',
              icon: Icons.account_balance,
              selected: _selectedMethod == 'Acleda',
              onTap: () => setState(() => _selectedMethod = 'Acleda'),
            ),
            const SizedBox(height: 8),
            _PaymentOptionTile(
              title: 'Wing',
              icon: Icons.money,
              selected: _selectedMethod == 'Wing',
              onTap: () => setState(() => _selectedMethod = 'Wing'),
            ),
            const SizedBox(height: 8),
            _PaymentOptionTile(
              title: 'Cash',
              icon: Icons.payments_outlined,
              selected: _selectedMethod == 'Cash',
              onTap: () => setState(() => _selectedMethod = 'Cash'),
            ),
            const SizedBox(height: 18),
            const Text('Payment with Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _PaymentOptionTile(
              title: '.... .... .... 4672',
              icon: Icons.credit_card,
              selected: _selectedMethod == 'Card',
              onTap: () => setState(() => _selectedMethod = 'Card'),
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Pad \$200', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey)),
                SizedBox(width: 20),
                Text('Refund \$185', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Continue',
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.task_alt, color: Colors.green, size: 96),
                        const SizedBox(height: 10),
                        const Text(
                          'Payment Successful!',
                          style: TextStyle(color: Colors.green, fontSize: 26, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Successfully made cancel for hotel booking',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'OK',
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          height: 52,
                          radius: 26,
                        ),
                      ],
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
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD0D0D0)),
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 3, offset: Offset(0, 1))],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppTheme.primary : Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
