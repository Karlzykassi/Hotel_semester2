import 'package:hote_v2/core/services/app_backend.dart';
import 'package:hote_v2/core/services/app_rest_api.dart';
import 'package:hote_v2/data/mock/mock_backend_store.dart';
import 'package:hote_v2/data/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository();

  Future<UserProfile> fetchProfile() async {
    final User? user = AppBackend.currentUser;
    if (!AppBackend.isEnabled || user == null) {
      return MockBackendStore.profile;
    }

    try {
      final Map<String, dynamic>? row = await AppRestApi.getRow(
        'profiles',
        queryParameters: <String, dynamic>{
          'select':
              'full_name,phone,avatar_url,date_of_birth,country,gender,language',
          'id': 'eq.${user.id}',
          'limit': 1,
        },
        requiresAuth: true,
      );

      return _fromSupabase(row, user);
    } catch (_) {
      return MockBackendStore.profile;
    }
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final SupabaseClient? client = AppBackend.client;
    final User? user = AppBackend.currentUser;
    if (client == null || user == null) {
      await MockBackendStore.updateProfile(profile);
      return profile;
    }

    await AppRestApi.insertRows(
      'profiles',
      body: <String, dynamic>{
        'id': user.id,
        'full_name': profile.displayName,
        'phone': profile.phoneNumber,
        'date_of_birth': _formatDate(profile.dateOfBirth),
        'country': profile.country,
        'gender': profile.gender,
        'language': profile.language,
        'avatar_url': profile.avatarUrl,
      },
      queryParameters: <String, dynamic>{'on_conflict': 'id'},
      requiresAuth: true,
      upsert: true,
    );

    await client.auth.updateUser(
      UserAttributes(
        data: <String, dynamic>{
          'full_name': profile.displayName,
        },
        email: profile.email == user.email ? null : profile.email,
      ),
    );

    return fetchProfile();
  }

  UserProfile _fromSupabase(Map<String, dynamic>? row, User user) {
    final String fullName =
        (row?['full_name'] as String?)?.trim().isNotEmpty == true
            ? row!['full_name'] as String
            : (user.userMetadata?['full_name'] as String?) ?? '';
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    final String firstName =
        parts.isEmpty || parts.first.isEmpty ? 'Guest' : parts.first;
    final String lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return UserProfile(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: _displayDate(row?['date_of_birth']),
      email: user.email ?? MockBackendStore.profile.email,
      country: (row?['country'] as String?) ?? 'Cambodia',
      phoneNumber: (row?['phone'] as String?) ?? '',
      gender: (row?['gender'] as String?) ?? 'Prefer not to say',
      language: (row?['language'] as String?) ?? 'English',
      avatarUrl: row?['avatar_url'] as String?,
    );
  }

  String? _formatDate(String value) {
    final List<String> parts = value.replaceAll(',', '').split(RegExp(r'\s+'));
    if (parts.length != 3) {
      return null;
    }

    final int month = _monthIndex(parts[0]);
    final int? day = int.tryParse(parts[1]);
    final int? year = int.tryParse(parts[2]);
    if (month == 0 || day == null || year == null) {
      return null;
    }

    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String _displayDate(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return MockBackendStore.profile.dateOfBirth;
    }

    final List<String> parts = value.split('-');
    if (parts.length != 3) {
      return MockBackendStore.profile.dateOfBirth;
    }

    final int month = int.tryParse(parts[1]) ?? 0;
    final int day = int.tryParse(parts[2]) ?? 0;
    final int year = int.tryParse(parts[0]) ?? 0;
    if (month == 0 || day == 0 || year == 0) {
      return MockBackendStore.profile.dateOfBirth;
    }

    const List<String> months = <String>[
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

    return '${months[month - 1]} $day, $year';
  }

  int _monthIndex(String month) {
    const List<String> months = <String>[
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

    final int index = months.indexOf(month.toLowerCase());
    return index == -1 ? 0 : index + 1;
  }
}
