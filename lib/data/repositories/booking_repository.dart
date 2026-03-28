import 'package:hote_v2/core/services/app_backend.dart';
import 'package:hote_v2/core/services/app_rest_api.dart';
import 'package:hote_v2/data/mock/mock_backend_store.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepository {
  BookingRepository();

  Future<List<BookingItem>> fetchBookings(BookingStatus status) async {
    final String? userId = AppBackend.currentUserId;
    if (!AppBackend.isEnabled || userId == null) {
      return _localBookings(status);
    }

    try {
      final List<dynamic> rows = await AppRestApi.getRows(
        'bookings',
        queryParameters: <String, dynamic>{
          'select':
              'id,status,check_in_date,check_out_date,guest_count,title,first_name,last_name,date_of_birth,email,phone_number,payment_method,hotels(id,name,city,province,address,latitude,longitude,rating,hero_image_url,price_from),room_types(name,price_per_night)',
          'user_id': 'eq.$userId',
          'order': 'created_at.desc',
        },
        requiresAuth: true,
      );

      final List<BookingItem> remoteItems = rows
          .map(
            (dynamic row) =>
                BookingItem.fromSupabase(Map<String, dynamic>.from(row as Map)),
          )
          .toList(growable: false);

      final List<BookingItem> mergedItems =
          _mergeWithLocalBookings(remoteItems);
      await _persistBookingSnapshot(mergedItems);

      return mergedItems
          .where((BookingItem item) => item.status == status)
          .toList(growable: false);
    } catch (_) {
      return _localBookings(status);
    }
  }

  Future<void> createBooking(BookingFlowData flow) async {
    final String? userId = AppBackend.currentUserId;
    if (!AppBackend.isEnabled || userId == null) {
      await MockBackendStore.addBooking(
        BookingItem(
          hotelName: flow.hotel.name,
          city: flow.hotel.city,
          status: BookingStatus.ongoing,
          bookingFlow: flow,
        ),
      );
      return;
    }

    final String hotelId = flow.hotel.id ?? await _findHotelId(flow: flow);
    final String roomTypeId = await _findRoomTypeId(
      hotelId: hotelId,
      roomType: flow.roomType,
    );

    final List<dynamic> bookingRows = await AppRestApi.insertRows(
      'bookings',
      body: <String, dynamic>{
        'user_id': userId,
        'hotel_id': hotelId,
        'room_type_id': roomTypeId,
        'status': 'confirmed',
        'check_in_date': _formatDate(flow.checkIn),
        'check_out_date': _formatDate(flow.checkOut),
        'guest_count': flow.guests,
        'title': flow.title,
        'first_name': flow.firstName,
        'last_name': flow.lastName,
        'date_of_birth': _parseBirthDate(flow.dateOfBirth),
        'email': flow.email,
        'phone_number': flow.phoneNumber,
        'payment_method': _paymentMethod(flow.paymentMethod),
        'payment_status': 'paid',
        'subtotal': flow.subTotal,
        'taxes': flow.taxes,
      },
      queryParameters: <String, dynamic>{'select': 'id,total,status'},
      requiresAuth: true,
    );

    if (bookingRows.isEmpty || bookingRows.first is! Map) {
      throw const BackendException(
        'Booking was created, but no response was returned.',
      );
    }

    final Map<String, dynamic> bookingRow =
        Map<String, dynamic>.from(bookingRows.first as Map);

    await AppRestApi.insertRows(
      'payments',
      body: <String, dynamic>{
        'booking_id': bookingRow['id'],
        'provider': flow.paymentMethod.toLowerCase(),
        'amount': bookingRow['total'] ?? flow.total,
        'status': 'paid',
      },
      requiresAuth: true,
    );

    await MockBackendStore.addBooking(
      BookingItem(
        id: bookingRow['id'] as String?,
        hotelName: flow.hotel.name,
        city: flow.hotel.city,
        status: BookingStatus.ongoing,
        bookingFlow: flow,
      ),
    );
  }

  Future<void> cancelBooking(BookingItem booking) async {
    final String? userId = AppBackend.currentUserId;
    if (!AppBackend.isEnabled || userId == null) {
      await MockBackendStore.cancelBooking(booking);
      return;
    }

    if (booking.id == null) {
      return;
    }

    final Map<String, dynamic>? latestBooking = await AppRestApi.getRow(
      'bookings',
      queryParameters: <String, dynamic>{
        'select': 'id,status',
        'id': 'eq.${booking.id!}',
        'user_id': 'eq.$userId',
        'limit': 1,
      },
      requiresAuth: true,
    );

    final String latestStatus =
        '${latestBooking?['status'] ?? ''}'.trim().toLowerCase();
    if (latestBooking == null || latestStatus.isEmpty) {
      throw const BackendException('Booking not found anymore.');
    }

    if (!_canCancelRemoteStatus(latestStatus)) {
      throw BackendException(
        'This booking is already ${_displayRemoteStatus(latestStatus)} and can no longer be canceled.',
      );
    }

    final List<dynamic> updatedRows = await AppRestApi.updateRows(
      'bookings',
      body: <String, dynamic>{'status': 'cancelled'},
      queryParameters: <String, dynamic>{
        'id': 'eq.${booking.id!}',
        'user_id': 'eq.$userId',
        'status': 'in.(pending,confirmed)',
      },
      requiresAuth: true,
      returnRepresentation: true,
    );

    if (updatedRows.isEmpty) {
      throw const BackendException(
        'This booking could not be canceled because its status already changed.',
      );
    }

    await MockBackendStore.cancelBooking(booking);
  }

  Future<String> _findHotelId({
    required BookingFlowData flow,
  }) async {
    final Map<String, dynamic>? hotel = await AppRestApi.getRow(
      'hotels',
      queryParameters: <String, dynamic>{
        'select': 'id',
        'name': 'eq.${flow.hotel.name}',
        'city': 'eq.${flow.hotel.city}',
        'limit': 1,
      },
    );

    if (hotel == null || hotel['id'] == null) {
      throw const AuthException('Hotel not found in database.');
    }

    return hotel['id'] as String;
  }

  Future<String> _findRoomTypeId({
    required String hotelId,
    required String roomType,
  }) async {
    final Map<String, dynamic>? room = await AppRestApi.getRow(
      'room_types',
      queryParameters: <String, dynamic>{
        'select': 'id',
        'hotel_id': 'eq.$hotelId',
        'name': 'eq.$roomType',
        'limit': 1,
      },
    );

    if (room != null && room['id'] != null) {
      return room['id'] as String;
    }

    final Map<String, dynamic>? fallbackRoom = await AppRestApi.getRow(
      'room_types',
      queryParameters: <String, dynamic>{
        'select': 'id',
        'hotel_id': 'eq.$hotelId',
        'limit': 1,
      },
    );
    if (fallbackRoom == null || fallbackRoom['id'] == null) {
      throw const BackendException('Room type not found in database.');
    }
    return fallbackRoom['id'] as String;
  }

  List<BookingItem> _localBookings(BookingStatus status) {
    return MockBackendStore.bookings
        .where((BookingItem item) => item.status == status)
        .toList(growable: false);
  }

  List<BookingItem> _mergeWithLocalBookings(List<BookingItem> remoteItems) {
    final Set<String> remoteKeys = remoteItems
        .map(_bookingStorageKey)
        .where((String key) => key.isNotEmpty)
        .toSet();
    final Set<String> remoteSignatures = remoteItems
        .map(_bookingSignature)
        .where((String signature) => signature.isNotEmpty)
        .toSet();

    final List<BookingItem> merged = List<BookingItem>.from(remoteItems);

    for (final BookingItem localItem in MockBackendStore.bookings) {
      final String localKey = _bookingStorageKey(localItem);
      final String localSignature = _bookingSignature(localItem);

      if (localKey.isNotEmpty && remoteKeys.contains(localKey)) {
        continue;
      }

      if (localSignature.isNotEmpty &&
          remoteSignatures.contains(localSignature)) {
        continue;
      }

      merged.add(localItem);
    }

    return merged;
  }

  String _bookingStorageKey(BookingItem item) {
    final String? id = item.id?.trim();
    if (id != null && id.isNotEmpty) {
      return 'id:$id';
    }

    final String signature = _bookingSignature(item);
    if (signature.isNotEmpty) {
      return 'sig:$signature';
    }

    return '';
  }

  String _bookingSignature(BookingItem item) {
    final BookingFlowData? flow = item.bookingFlow;
    if (flow == null) {
      return '';
    }

    final String hotelKey = (flow.hotel.id?.trim().isNotEmpty ?? false)
        ? flow.hotel.id!.trim().toLowerCase()
        : '${item.hotelName.trim().toLowerCase()}|${item.city.trim().toLowerCase()}';

    return <String>[
      hotelKey,
      _formatDate(flow.checkIn),
      _formatDate(flow.checkOut),
      '${flow.guests}',
      flow.roomType.trim().toLowerCase(),
      flow.firstName.trim().toLowerCase(),
      flow.lastName.trim().toLowerCase(),
    ].join('|');
  }

  String _paymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'aba':
        return 'aba';
      case 'acleda':
        return 'acleda';
      case 'wing':
        return 'wing';
      case 'card':
        return 'card';
      default:
        return 'cash';
    }
  }

  bool _canCancelRemoteStatus(String status) {
    return status == 'pending' || status == 'confirmed';
  }

  String _displayRemoteStatus(String status) {
    switch (status) {
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'canceled';
      case 'rejected':
        return 'rejected';
      case 'saved':
        return 'saved';
      case 'pending':
        return 'pending';
      case 'confirmed':
        return 'confirmed';
      default:
        return 'updated';
    }
  }

  Future<void> _persistBookingSnapshot(List<BookingItem> items) async {
    final String storageKey = _bookingStorageOwnerKey();
    if (storageKey.isEmpty) {
      return;
    }

    await MockBackendStore.replaceBookingsForUser(
      storageKey: storageKey,
      bookings: items,
    );
  }

  String _bookingStorageOwnerKey() {
    final User? user = AppBackend.currentUser;
    final String email = (user?.email ?? '').trim();
    if (email.isNotEmpty) {
      return email;
    }

    final String userId = (user?.id ?? '').trim();
    return userId.isEmpty ? '' : '$userId@users.supabase.local';
  }

  String _formatDate(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String? _parseBirthDate(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }

    final List<String> parts = raw.replaceAll(',', '').split(RegExp(r'\s+'));
    if (parts.length != 3) {
      return null;
    }

    final int? day = int.tryParse(parts[0]);
    final int? year = int.tryParse(parts[2]);
    final int month = _monthIndex(parts[1]);
    if (day == null || year == null || month == 0) {
      return null;
    }

    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  int _monthIndex(String month) {
    const List<String> values = <String>[
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];

    final int index = values.indexOf(month.toLowerCase());
    return index == -1 ? 0 : index + 1;
  }
}
