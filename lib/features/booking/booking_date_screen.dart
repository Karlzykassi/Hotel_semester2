import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/features/booking/cancel_booking_screen.dart';
import 'package:hote_v2/features/booking/reservation_form_screen.dart';
import 'package:hote_v2/shared/components/primary_button.dart';

enum _ActiveDateField { checkIn, checkOut }

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
  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekdayNames = <String>[
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  late final DateTime _today;
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late DateTime _displayedMonth;
  late int _guestCount;
  _ActiveDateField _activeField = _ActiveDateField.checkIn;

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _checkInDate = _initialCheckInDate(widget.bookingFlow?.checkIn);
    _checkOutDate = _initialCheckOutDate(widget.bookingFlow?.checkOut);
    _displayedMonth = DateTime(_checkInDate.year, _checkInDate.month);
    _guestCount = widget.bookingFlow?.guests ?? 1;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _initialCheckInDate(DateTime? value) {
    final DateTime resolved = value == null ? _today : _dateOnly(value);
    return resolved.isBefore(_today) ? _today : resolved;
  }

  DateTime _initialCheckOutDate(DateTime? value) {
    final DateTime fallback = _checkInDate.add(const Duration(days: 1));
    if (value == null) {
      return fallback;
    }

    final DateTime resolved = _dateOnly(value);
    return resolved.isAfter(_checkInDate) ? resolved : fallback;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool get _canGoToPreviousMonth {
    final DateTime firstAllowedMonth = DateTime(_today.year, _today.month);
    return !_isSameDay(_displayedMonth, firstAllowedMonth) &&
        _displayedMonth.isAfter(firstAllowedMonth);
  }

  void _changeMonth(int offset) {
    final DateTime nextMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + offset,
    );
    final DateTime firstAllowedMonth = DateTime(_today.year, _today.month);
    if (offset < 0 && nextMonth.isBefore(firstAllowedMonth)) {
      return;
    }

    setState(() {
      _displayedMonth = nextMonth;
    });
  }

  void _jumpToToday() {
    setState(() {
      _displayedMonth = DateTime(_today.year, _today.month);
    });
  }

  void _resetDates() {
    setState(() {
      _checkInDate = _today;
      _checkOutDate = _today.add(const Duration(days: 1));
      _displayedMonth = DateTime(_today.year, _today.month);
      _activeField = _ActiveDateField.checkIn;
    });
  }

  void _selectDate(DateTime selectedDate) {
    final DateTime day = _dateOnly(selectedDate);
    if (day.isBefore(_today)) {
      return;
    }

    setState(() {
      _displayedMonth = DateTime(day.year, day.month);
      if (_activeField == _ActiveDateField.checkIn) {
        _checkInDate = day;
        if (!_checkOutDate.isAfter(_checkInDate)) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
        _activeField = _ActiveDateField.checkOut;
      } else {
        if (day.isAfter(_checkInDate)) {
          _checkOutDate = day;
          _activeField = _ActiveDateField.checkIn;
        } else {
          _checkInDate = day;
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
          _activeField = _ActiveDateField.checkOut;
        }
      }
    });
  }

  void _updateGuestCount(int delta) {
    setState(() {
      final int next = _guestCount + delta;
      if (next < 1) {
        _guestCount = 1;
      } else if (next > 10) {
        _guestCount = 10;
      } else {
        _guestCount = next;
      }
    });
  }

  List<DateTime?> _calendarDays(DateTime month) {
    final DateTime firstDay = DateTime(month.year, month.month, 1);
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final int leadingEmptyDays = firstDay.weekday % 7;
    final List<DateTime?> days = List<DateTime?>.filled(
      leadingEmptyDays,
      null,
      growable: true,
    );

    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    final int trailingEmptyDays = (7 - (days.length % 7)) % 7;
    days.addAll(List<DateTime?>.filled(trailingEmptyDays, null));
    return days;
  }

  String _monthLabel(DateTime value) {
    return '${_monthNames[value.month - 1]} ${value.year}';
  }

  String _shortMonthLabel(DateTime value) {
    return _monthNames[value.month - 1].substring(0, 3);
  }

  String _weekdayLabel(DateTime value) {
    return _weekdayNames[value.weekday % 7];
  }

  String _rangeLabel() {
    return '${_weekdayLabel(_checkInDate)}, ${_shortMonthLabel(_checkInDate)} ${_checkInDate.day}'
        ' - ${_weekdayLabel(_checkOutDate)}, ${_shortMonthLabel(_checkOutDate)} ${_checkOutDate.day}';
  }

  String _tagLabel(DateTime value) {
    return '${value.day} ${_shortMonthLabel(value)} ${value.year}';
  }

  void _continue() {
    if (widget.bookingFlow == null) {
      Navigator.pushNamed(context, CancelBookingScreen.routeName);
      return;
    }

    final updatedFlow = widget.bookingFlow!.copyWith(
      checkIn: _checkInDate,
      checkOut: _checkOutDate,
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
    final List<DateTime?> days = _calendarDays(_displayedMonth);

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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD1AD),
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
                            _rangeLabel(),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _activeField == _ActiveDateField.checkIn
                                ? 'Choose your check-in date first.'
                                : 'Choose your check-out date next.',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.black45),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _canGoToPreviousMonth
                                    ? () => _changeMonth(-1)
                                    : null,
                                icon: const Icon(Icons.chevron_left_rounded),
                              ),
                              Expanded(
                                child: Text(
                                  _monthLabel(_displayedMonth),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _changeMonth(1),
                                icon: const Icon(Icons.chevron_right_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: _weekdayNames
                                .map(
                                  (String day) => Expanded(
                                    child: Center(
                                      child: Text(
                                        day.substring(0, 1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: days.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              final DateTime? day = days[index];
                              if (day == null) {
                                return const SizedBox.shrink();
                              }

                              final bool isToday = _isSameDay(day, _today);
                              final bool isCheckIn =
                                  _isSameDay(day, _checkInDate);
                              final bool isCheckOut =
                                  _isSameDay(day, _checkOutDate);
                              final bool isSelected = isCheckIn || isCheckOut;
                              final bool isInRange =
                                  day.isAfter(_checkInDate) &&
                                      day.isBefore(_checkOutDate);
                              final bool isDisabled = day.isBefore(_today);
                              final bool isActiveEdge = (isCheckIn &&
                                      _activeField ==
                                          _ActiveDateField.checkIn) ||
                                  (isCheckOut &&
                                      _activeField ==
                                          _ActiveDateField.checkOut);

                              Color backgroundColor = Colors.transparent;
                              if (isSelected) {
                                backgroundColor = AppTheme.primary;
                              } else if (isInRange) {
                                backgroundColor = const Color(0xFFFFE6D3);
                              }

                              Color textColor = Colors.black87;
                              if (isDisabled) {
                                textColor = Colors.black38;
                              } else if (isSelected) {
                                textColor = Colors.white;
                              }

                              return InkWell(
                                onTap:
                                    isDisabled ? null : () => _selectDate(day),
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isActiveEdge
                                          ? Colors.black87
                                          : isToday && !isSelected
                                              ? Colors.black54
                                              : Colors.transparent,
                                      width: isActiveEdge ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _resetDates,
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _jumpToToday,
                                child: const Text(
                                  'Today',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
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
                            value: _tagLabel(_checkInDate),
                            selected: _activeField == _ActiveDateField.checkIn,
                            onTap: () => setState(
                              () => _activeField = _ActiveDateField.checkIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateTag(
                            title: 'Check out date',
                            value: _tagLabel(_checkOutDate),
                            selected: _activeField == _ActiveDateField.checkOut,
                            onTap: () => setState(
                              () => _activeField = _ActiveDateField.checkOut,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Guest',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => _updateGuestCount(-1),
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
                          onPressed: () => _updateGuestCount(1),
                          icon: const Icon(Icons.add, size: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
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
  const _DateTag({
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String value;
  final bool selected;
  final VoidCallback onTap;

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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EAE2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppTheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: selected ? AppTheme.primary : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
