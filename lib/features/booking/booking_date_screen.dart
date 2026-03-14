import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/features/booking/cancel_booking_screen.dart';
import 'package:hote_v2/features/booking/reservation_form_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

class BookingDateScreen extends StatefulWidget {
  const BookingDateScreen({
    super.key,
    this.bookingFlow,
  });

  static const routeName = '/booking-date';
  final BookingFlowData? bookingFlow;

  @override
  State<BookingDateScreen> createState() => _BookingDateScreenState();
}

class _BookingDateScreenState extends State<BookingDateScreen> {
  late int _checkInDay;
  late int _checkOutDay;
  late int _guestCount;

  @override
  void initState() {
    super.initState();
    _checkInDay = widget.bookingFlow?.checkIn.day ?? 17;
    _checkOutDay = widget.bookingFlow?.checkOut.day ?? 19;
    _guestCount = widget.bookingFlow?.guests ?? 3;
  }

  void _selectDay(int day) {
    setState(() {
      if (day <= _checkInDay || _checkInDay == _checkOutDay) {
        _checkInDay = day;
        _checkOutDay = day + 2 > 31 ? 31 : day + 2;
      } else {
        _checkOutDay = day;
      }

      if (_checkOutDay <= _checkInDay) {
        _checkOutDay = _checkInDay + 1 > 31 ? 31 : _checkInDay + 1;
      }
    });
  }

  void _continue() {
    if (widget.bookingFlow == null) {
      Navigator.pushNamed(context, CancelBookingScreen.routeName);
      return;
    }

    final updatedFlow = widget.bookingFlow!.copyWith(
      checkIn: DateTime(2025, 8, _checkInDay),
      checkOut: DateTime(2025, 8, _checkOutDay),
      guests: _guestCount,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReservationFormScreen(bookingFlow: updatedFlow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Date',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select date',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mon, Aug $_checkInDay',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.black45),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.chevron_left_rounded),
                      Text(
                        'August 2025',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('S'),
                      Text('M'),
                      Text('T'),
                      Text('W'),
                      Text('T'),
                      Text('F'),
                      Text('S'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: List.generate(31, (index) {
                      final day = index + 1;
                      final isCheckIn = day == _checkInDay;
                      final isCheckOut = day == _checkOutDay;
                      final isSelected = isCheckIn || isCheckOut;

                      return InkWell(
                        onTap: () => _selectDay(day),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: isCheckIn
                                      ? AppTheme.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white),
                                )
                              : null,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 14,
                              color: isCheckIn ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Clear',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DateTag(
                    title: 'Check in date',
                    value: '$_checkInDay Aug',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateTag(
                    title: 'Check out date',
                    value: '$_checkOutDay Aug',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Guest',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(
                    () => _guestCount = (_guestCount - 1).clamp(1, 10),
                  ),
                  icon: const Icon(Icons.remove, size: 30),
                ),
                const SizedBox(width: 28),
                Text(
                  '$_guestCount',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 28),
                IconButton(
                  onPressed: () => setState(
                    () => _guestCount = (_guestCount + 1).clamp(1, 10),
                  ),
                  icon: const Icon(Icons.add, size: 30),
                ),
              ],
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

class _DateTag extends StatelessWidget {
  const _DateTag({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF4EAE2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
