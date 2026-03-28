import 'dart:convert';

import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/booking_item.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/data/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockBackendStore {
  MockBackendStore._();

  static const String _accountsKey = 'mock_accounts_v1';
  static const String _bookingsKey = 'mock_bookings_v1';
  static const String _activeEmailKey = 'mock_active_email_v1';
  static const String _isSignedInKey = 'mock_signed_in_v1';
  static const String _searchHistoryKey = 'mock_search_history_v1';

  static const UserProfile _emptyProfile = UserProfile(
    firstName: '',
    lastName: '',
    dateOfBirth: '',
    email: '',
    country: '',
    phoneNumber: '',
    gender: '',
    language: 'English',
  );

  static const List<String> _defaultSearchHistory = <String>[
    'Golden Temple Hotel',
    'Battambang Riverside Hotel',
    'Sihanoukville Bay Hotel',
    'Mondulkiri Hill Resort',
  ];

  static bool _initialized = false;
  static bool isSignedIn = false;
  static UserProfile _profile = _emptyProfile;
  static String _activeEmail = '';
  static final Map<String, _MockAccount> _accountsByEmail =
      <String, _MockAccount>{};
  static final Map<String, List<BookingItem>> _bookingsByEmail =
      <String, List<BookingItem>>{};
  static final List<String> _searchHistory =
      List<String>.from(_defaultSearchHistory);

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    _accountsByEmail
      ..clear()
      ..addAll(_decodeAccounts(preferences.getString(_accountsKey)));

    _bookingsByEmail
      ..clear()
      ..addAll(_decodeBookings(preferences.getString(_bookingsKey)));

    _searchHistory
      ..clear()
      ..addAll(
        preferences.getStringList(_searchHistoryKey) ?? _defaultSearchHistory,
      );

    _activeEmail = _normalizeEmail(
      preferences.getString(_activeEmailKey) ?? '',
    );
    isSignedIn = preferences.getBool(_isSignedInKey) ?? false;

    final _MockAccount? activeAccount = _accountsByEmail[_activeEmail];
    if (isSignedIn && activeAccount != null) {
      _profile = activeAccount.profile;
      _bookingsByEmail.putIfAbsent(_activeEmail, () => <BookingItem>[]);
    } else {
      _profile = _emptyProfile;
      isSignedIn = false;
      _activeEmail = '';
    }

    _initialized = true;
  }

  static UserProfile get profile => _profile;

  static List<BookingItem> get bookings =>
      List<BookingItem>.from(_bookingsByEmail[_activeEmail] ?? <BookingItem>[]);

  static List<String> get searchHistory =>
      List<String>.unmodifiable(_searchHistory);

  static Future<void> registerAccount({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = _normalizeEmail(email);
    if (!_isValidEmail(normalizedEmail)) {
      throw const AuthException('Enter a valid email address.');
    }
    if (password.trim().length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }
    if (_accountsByEmail.containsKey(normalizedEmail)) {
      throw const AuthException('This email is already registered.');
    }

    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    final UserProfile profile = UserProfile(
      firstName:
          parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : 'User',
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      dateOfBirth: _profile.dateOfBirth,
      email: normalizedEmail,
      country: 'Cambodia',
      phoneNumber: phone.trim(),
      gender: 'Prefer not to say',
      language: 'English',
    );

    _accountsByEmail[normalizedEmail] = _MockAccount(
      password: password,
      profile: profile,
    );
    _activeEmail = normalizedEmail;
    _profile = profile;
    _bookingsByEmail.putIfAbsent(_activeEmail, () => <BookingItem>[]);
    isSignedIn = true;
    await _persist();
  }

  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = _normalizeEmail(email);
    final _MockAccount? account = _accountsByEmail[normalizedEmail];
    if (account == null) {
      throw const AuthException('No account found for this email.');
    }
    if (account.password != password) {
      throw const AuthException('Incorrect password.');
    }

    _activeEmail = normalizedEmail;
    _profile = account.profile;
    _bookingsByEmail.putIfAbsent(_activeEmail, () => <BookingItem>[]);
    isSignedIn = true;
    await _persist();
  }

  static Future<void> signIn({
    required String email,
    String? displayName,
    String? phoneNumber,
  }) async {
    _activeEmail = _normalizeEmail(email);
    _bookingsByEmail.putIfAbsent(_activeEmail, () => <BookingItem>[]);

    final _MockAccount? existingAccount = _accountsByEmail[_activeEmail];
    final UserProfile seedProfile = existingAccount?.profile ??
        _emptyProfile.copyWith(
          email: _activeEmail,
          country: 'Cambodia',
          gender: 'Prefer not to say',
          language: 'English',
        );

    final List<String> parts = (displayName ?? '').trim().split(RegExp(r'\s+'));
    final String firstName = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first
        : seedProfile.firstName;
    final String lastName =
        parts.length > 1 ? parts.sublist(1).join(' ') : seedProfile.lastName;

    _profile = seedProfile.copyWith(
      firstName: firstName.isEmpty ? 'User' : firstName,
      lastName: lastName,
      email: _activeEmail,
      phoneNumber: phoneNumber ?? seedProfile.phoneNumber,
    );
    _accountsByEmail[_activeEmail] = _MockAccount(
      password: existingAccount?.password ?? '',
      profile: _profile,
    );
    isSignedIn = true;
    await _persist();
  }

  static Future<void> replaceBookingsForUser({
    required String storageKey,
    required List<BookingItem> bookings,
  }) async {
    await initialize();

    final String normalizedKey = _normalizeEmail(storageKey);
    if (normalizedKey.isEmpty) {
      return;
    }

    _bookingsByEmail[normalizedKey] = List<BookingItem>.from(bookings);
    if (_activeEmail.isEmpty || _activeEmail == normalizedKey) {
      _activeEmail = normalizedKey;
    }
    await _persist();
  }

  static Future<void> signOut() async {
    isSignedIn = false;
    _activeEmail = '';
    _profile = _emptyProfile;
    await _persist();
  }

  static Future<void> updateProfile(UserProfile profile) async {
    if (_activeEmail.isEmpty && profile.email.trim().isNotEmpty) {
      _activeEmail = _normalizeEmail(profile.email);
    }

    _profile = profile;
    final _MockAccount? account = _accountsByEmail[_activeEmail];
    if (account != null) {
      _accountsByEmail[_activeEmail] = account.copyWith(profile: profile);
    }
    await _persist();
  }

  static Future<void> addBooking(BookingItem booking) async {
    final List<BookingItem> items =
        _bookingsByEmail.putIfAbsent(_activeEmail, () => <BookingItem>[]);
    items.insert(0, booking);
    await _persist();
  }

  static Future<void> cancelBooking(BookingItem booking) async {
    final List<BookingItem> items =
        _bookingsByEmail.putIfAbsent(_activeEmail, () => <BookingItem>[]);
    final int index = items.indexWhere(
      (BookingItem item) =>
          (booking.id != null && item.id == booking.id) ||
          (item.hotelName == booking.hotelName &&
              item.city == booking.city &&
              item.status == booking.status),
    );

    if (index == -1) {
      return;
    }

    items[index] = items[index].copyWith(status: BookingStatus.canceled);
    await _persist();
  }

  static Future<void> saveSearch(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _searchHistory.removeWhere(
      (String entry) => entry.toLowerCase() == trimmed.toLowerCase(),
    );
    _searchHistory.insert(0, trimmed);
    await _persist();
  }

  static Future<void> removeSearch(String query) async {
    _searchHistory.removeWhere(
      (String entry) => entry.toLowerCase() == query.toLowerCase(),
    );
    await _persist();
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static bool _isValidEmail(String email) {
    final RegExp emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    return emailPattern.hasMatch(email);
  }

  static Future<void> _persist() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setString(_accountsKey, jsonEncode(_encodeAccounts()));
    await preferences.setString(_bookingsKey, jsonEncode(_encodeBookings()));
    await preferences.setString(_activeEmailKey, _activeEmail);
    await preferences.setBool(_isSignedInKey, isSignedIn);
    await preferences.setStringList(
      _searchHistoryKey,
      List<String>.from(_searchHistory),
    );
  }

  static Map<String, dynamic> _encodeAccounts() {
    return <String, dynamic>{
      for (final MapEntry<String, _MockAccount> entry
          in _accountsByEmail.entries)
        entry.key: entry.value.toJson(),
    };
  }

  static Map<String, dynamic> _encodeBookings() {
    return <String, dynamic>{
      for (final MapEntry<String, List<BookingItem>> entry
          in _bookingsByEmail.entries)
        entry.key: entry.value
            .map((BookingItem item) => _bookingToJson(item))
            .toList(growable: false),
    };
  }

  static Map<String, _MockAccount> _decodeAccounts(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return <String, _MockAccount>{};
    }

    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      return <String, _MockAccount>{};
    }

    final Map<String, _MockAccount> accounts = <String, _MockAccount>{};
    for (final MapEntry<dynamic, dynamic> entry in decoded.entries) {
      if (entry.value is! Map) {
        continue;
      }

      accounts[_normalizeEmail('${entry.key}')] = _MockAccount.fromJson(
        Map<String, dynamic>.from(entry.value as Map),
      );
    }
    return accounts;
  }

  static Map<String, List<BookingItem>> _decodeBookings(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) {
      return <String, List<BookingItem>>{};
    }

    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      return <String, List<BookingItem>>{};
    }

    final Map<String, List<BookingItem>> bookings =
        <String, List<BookingItem>>{};
    for (final MapEntry<dynamic, dynamic> entry in decoded.entries) {
      if (entry.value is! List) {
        continue;
      }

      bookings[_normalizeEmail('${entry.key}')] = (entry.value as List<dynamic>)
          .whereType<Map>()
          .map(
            (Map item) => _bookingFromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: true);
    }
    return bookings;
  }

  static Map<String, dynamic> _bookingToJson(BookingItem booking) {
    return <String, dynamic>{
      'id': booking.id,
      'hotelName': booking.hotelName,
      'city': booking.city,
      'status': booking.status.name,
      'bookingFlow': booking.bookingFlow == null
          ? null
          : _bookingFlowToJson(booking.bookingFlow!),
    };
  }

  static BookingItem _bookingFromJson(Map<String, dynamic> json) {
    final dynamic flowJson = json['bookingFlow'];
    final BookingFlowData? flow = flowJson is Map
        ? _bookingFlowFromJson(Map<String, dynamic>.from(flowJson))
        : null;

    return BookingItem(
      id: json['id'] as String?,
      hotelName: (json['hotelName'] as String?) ?? flow?.hotel.name ?? 'Hotel',
      city: (json['city'] as String?) ?? flow?.hotel.city ?? '',
      status: _bookingStatusFromString(json['status'] as String?),
      bookingFlow: flow,
    );
  }

  static Map<String, dynamic> _bookingFlowToJson(BookingFlowData flow) {
    return <String, dynamic>{
      'hotel': _searchResultToJson(flow.hotel),
      'checkIn': flow.checkIn.toIso8601String(),
      'checkOut': flow.checkOut.toIso8601String(),
      'guests': flow.guests,
      'title': flow.title,
      'firstName': flow.firstName,
      'lastName': flow.lastName,
      'dateOfBirth': flow.dateOfBirth,
      'email': flow.email,
      'phoneNumber': flow.phoneNumber,
      'paymentMethod': flow.paymentMethod,
      'cardLabel': flow.cardLabel,
      'roomType': flow.roomType,
    };
  }

  static BookingFlowData _bookingFlowFromJson(Map<String, dynamic> json) {
    final dynamic hotelJson = json['hotel'];
    final SearchResultItem hotel = hotelJson is Map
        ? _searchResultFromJson(Map<String, dynamic>.from(hotelJson))
        : const SearchResultItem(
            name: 'Hotel',
            city: '',
            rating: 0,
            price: 0,
            imageColor: 0xFFC5AE95,
          );

    return BookingFlowData(
      hotel: hotel,
      checkIn: DateTime.tryParse('${json['checkIn'] ?? ''}') ??
          DateTime(2025, 8, 17),
      checkOut: DateTime.tryParse('${json['checkOut'] ?? ''}') ??
          DateTime(2025, 8, 19),
      guests: _asInt(json['guests'], fallback: 1),
      title: (json['title'] as String?) ?? 'Mr.',
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      dateOfBirth: (json['dateOfBirth'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
      paymentMethod: (json['paymentMethod'] as String?) ?? 'ABA',
      cardLabel: (json['cardLabel'] as String?) ?? '.... ........ 4672',
      roomType: (json['roomType'] as String?) ?? 'Family Room',
    );
  }

  static Map<String, dynamic> _searchResultToJson(SearchResultItem result) {
    return <String, dynamic>{
      'id': result.id,
      'name': result.name,
      'city': result.city,
      'rating': result.rating,
      'price': result.price,
      'imageColor': result.imageColor,
      'imageUrl': result.imageUrl,
    };
  }

  static SearchResultItem _searchResultFromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'] as String?,
      name: (json['name'] as String?) ?? 'Hotel',
      city: (json['city'] as String?) ?? '',
      rating: _asDouble(json['rating']),
      price: _asInt(json['price']),
      imageColor: _asInt(json['imageColor'], fallback: 0xFFC5AE95),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  static BookingStatus _bookingStatusFromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'complete':
      case 'completed':
        return BookingStatus.complete;
      case 'reject':
      case 'rejected':
      case 'canceled':
      case 'cancelled':
        return BookingStatus.canceled;
      case 'saved':
        return BookingStatus.saved;
      default:
        return BookingStatus.ongoing;
    }
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? fallback;
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }
}

class _MockAccount {
  const _MockAccount({
    required this.password,
    required this.profile,
  });

  final String password;
  final UserProfile profile;

  _MockAccount copyWith({
    String? password,
    UserProfile? profile,
  }) {
    return _MockAccount(
      password: password ?? this.password,
      profile: profile ?? this.profile,
    );
  }

  factory _MockAccount.fromJson(Map<String, dynamic> json) {
    return _MockAccount(
      password: (json['password'] as String?) ?? '',
      profile: UserProfile.fromJson(
        Map<String, dynamic>.from(
          (json['profile'] as Map?) ?? <String, dynamic>{},
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'password': password,
      'profile': profile.toJson(),
    };
  }
}
