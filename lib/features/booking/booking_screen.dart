import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hote_v2/core/services/app_backend.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/booking/ticket_screen.dart';
import 'package:hote_v2/shared/components/booking_card.dart';
import 'package:hote_v2/shared/components/status_chip.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  static const routeName = '/booking';

  @override
  State<BookingScreen> createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen>
    with WidgetsBindingObserver {
  BookingStatus _status = BookingStatus.ongoing;
  List<BookingItem> _items = const <BookingItem>[];
  bool _isLoading = true;
  Timer? _refreshTimer;
  RealtimeChannel? _bookingsChannel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBookings();
    _subscribeToBookingUpdates();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => refreshBookings(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _unsubscribeFromBookingUpdates();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshBookings(silent: true);
    }
  }

  String _label(BookingStatus status) {
    switch (status) {
      case BookingStatus.ongoing:
        return 'Ongoing';
      case BookingStatus.complete:
        return 'Complete';
      case BookingStatus.canceled:
        return 'Canceled';
      case BookingStatus.saved:
        return 'Saved';
    }
  }

  Future<void> _loadBookings() async {
    final List<BookingItem> items =
        await AppServices.bookings.fetchBookings(_status);
    if (!mounted) {
      return;
    }

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> refreshBookings({bool silent = false}) async {
    if (!mounted) {
      return;
    }

    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      await _loadBookings();
    } catch (_) {
      if (!mounted || silent) {
        return;
      }

      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectStatus(BookingStatus status) async {
    setState(() {
      _status = status;
      _isLoading = true;
    });
    await refreshBookings(silent: true);
  }

  void _subscribeToBookingUpdates() {
    final SupabaseClient? client = AppBackend.client;
    final String? userId = AppBackend.currentUserId;
    if (client == null || userId == null || userId.trim().isEmpty) {
      return;
    }

    _bookingsChannel = client
        .channel('public:bookings:user:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) {
            refreshBookings(silent: true);
          },
        )
        .subscribe();
  }

  void _unsubscribeFromBookingUpdates() {
    final RealtimeChannel? channel = _bookingsChannel;
    final SupabaseClient? client = AppBackend.client;
    _bookingsChannel = null;

    if (client != null && channel != null) {
      client.removeChannel(channel);
    }
  }

  BookingFlowData _flowForBooking(BookingItem item) {
    return item.bookingFlow ??
        BookingFlowData.fromResult(
          SearchResultItem(
            id: item.id,
            name: item.hotelName,
            city: item.city,
            rating: 4.5,
            price: 200,
            imageColor: 0xFFC5AE95,
          ),
        );
  }

  Future<void> _cancelBooking(BookingItem item) async {
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Cancel Booking'),
          content: Text(
            'Cancel booking for ${item.hotelName}?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    try {
      await AppServices.bookings.cancelBooking(item);
      if (!mounted) {
        return;
      }

      await refreshBookings(silent: true);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking moved to Canceled')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      await refreshBookings(silent: true);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _openTicket(BookingItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TicketScreen(bookingFlow: _flowForBooking(item)),
      ),
    );
    await refreshBookings(silent: true);
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const <Widget>[
        SizedBox(height: 140),
        Center(
          child: Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        return BookingCard(
          item: _items[index],
          onPrimary: () {
            if (_items[index].canCancel) {
              _cancelBooking(_items[index]);
            }
          },
          onSecondary: () {
            _openTicket(_items[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  StatusChip(
                    label: _label(BookingStatus.ongoing),
                    selected: _status == BookingStatus.ongoing,
                    onTap: () => _selectStatus(BookingStatus.ongoing),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: _label(BookingStatus.complete),
                    selected: _status == BookingStatus.complete,
                    onTap: () => _selectStatus(BookingStatus.complete),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: _label(BookingStatus.canceled),
                    selected: _status == BookingStatus.canceled,
                    onTap: () => _selectStatus(BookingStatus.canceled),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: _label(BookingStatus.saved),
                    selected: _status == BookingStatus.saved,
                    onTap: () => _selectStatus(BookingStatus.saved),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: refreshBookings,
                      child: _items.isEmpty
                          ? _buildEmptyState()
                          : _buildBookingsList(),
                    ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.background,
    );
  }
}
