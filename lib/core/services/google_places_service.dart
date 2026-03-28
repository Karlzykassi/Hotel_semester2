import 'dart:convert';

import 'package:hote_v2/data/models/google_place_hotel.dart';
import 'package:http/http.dart' as http;

class GooglePlacesException implements Exception {
  const GooglePlacesException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class GooglePlaceCandidate {
  const GooglePlaceCandidate({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
  });

  final String placeId;
  final String name;
  final String formattedAddress;

  factory GooglePlaceCandidate.fromSearchRow(Map<String, dynamic> row) {
    final Map<String, dynamic> displayName = row['displayName'] is Map
        ? Map<String, dynamic>.from(row['displayName'] as Map)
        : const <String, dynamic>{};

    return GooglePlaceCandidate(
      placeId: (row['id'] as String?)?.trim() ?? '',
      name: (displayName['text'] as String?)?.trim() ??
          (row['formattedAddress'] as String?)?.trim() ??
          'Hotel',
      formattedAddress: (row['formattedAddress'] as String?)?.trim() ?? '',
    );
  }
}

class GooglePlacesService {
  GooglePlacesService({
    required this.apiKey,
    this.languageCode = 'en',
    this.regionCode = 'KH',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final String languageCode;
  final String regionCode;
  final http.Client _httpClient;

  Future<List<GooglePlaceCandidate>> searchHotelsByText({
    required String query,
    int maxResults = 8,
  }) async {
    final Map<String, dynamic> response = await _postJson(
      '/v1/places:searchText',
      body: <String, dynamic>{
        'textQuery': query,
        'languageCode': languageCode,
        'regionCode': regionCode,
        'maxResultCount': maxResults.clamp(1, 20),
      },
      fieldMask: 'places.id,places.displayName,places.formattedAddress',
    );

    return _placesFromResponse(response);
  }

  Future<List<GooglePlaceCandidate>> searchHotelsNearby({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
    int maxResults = 8,
  }) async {
    final Map<String, dynamic> response = await _postJson(
      '/v1/places:searchNearby',
      body: <String, dynamic>{
        'languageCode': languageCode,
        'maxResultCount': maxResults.clamp(1, 20),
        'rankPreference': 'DISTANCE',
        'includedTypes': const <String>['lodging'],
        'locationRestriction': <String, dynamic>{
          'circle': <String, dynamic>{
            'center': <String, double>{
              'latitude': latitude,
              'longitude': longitude,
            },
            'radius': radiusMeters.clamp(1, 50000),
          },
        },
      },
      fieldMask: 'places.id,places.displayName,places.formattedAddress',
    );

    return _placesFromResponse(response);
  }

  Future<GooglePlaceHotel> fetchHotelDetails(String placeId) async {
    final Map<String, dynamic> response = await _getJson(
      '/v1/places/$placeId',
      fieldMask:
          'id,displayName,formattedAddress,addressComponents,location,rating,userRatingCount,googleMapsUri,photos',
    );

    final List<dynamic> photos =
        response['photos'] as List<dynamic>? ?? const [];
    final String? photoName = photos.isEmpty
        ? null
        : (photos.first is Map)
            ? (Map<String, dynamic>.from(photos.first as Map)['name']
                as String?)
            : null;
    final String? photoUri = photoName == null || photoName.trim().isEmpty
        ? null
        : await fetchPhotoUri(photoName);

    return GooglePlaceHotel.fromGooglePlaceDetails(
      response,
      photoUri: photoUri,
    );
  }

  Future<String?> fetchPhotoUri(
    String photoName, {
    int maxWidthPx = 1200,
  }) async {
    final Map<String, dynamic> response = await _getJson(
      '/v1/$photoName/media',
      queryParameters: <String, dynamic>{
        'maxWidthPx': maxWidthPx,
        'skipHttpRedirect': 'true',
      },
    );

    final String? uri = (response['photoUri'] as String?)?.trim();
    return uri == null || uri.isEmpty ? null : uri;
  }

  List<GooglePlaceCandidate> _placesFromResponse(
      Map<String, dynamic> response) {
    final List<dynamic> rows = response['places'] as List<dynamic>? ?? const [];

    return rows
        .whereType<Map>()
        .map(
          (Map row) => GooglePlaceCandidate.fromSearchRow(
              Map<String, dynamic>.from(row)),
        )
        .where((GooglePlaceCandidate item) => item.placeId.isNotEmpty)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? fieldMask,
  }) async {
    final Uri uri = Uri.https(
      'places.googleapis.com',
      path,
      _stringifyQueryParameters(queryParameters),
    );

    final http.Response response = await _httpClient.get(
      uri,
      headers: _headers(fieldMask: fieldMask),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
    String path, {
    required Object body,
    Map<String, dynamic>? queryParameters,
    String? fieldMask,
  }) async {
    final Uri uri = Uri.https(
      'places.googleapis.com',
      path,
      _stringifyQueryParameters(queryParameters),
    );

    final http.Response response = await _httpClient.post(
      uri,
      headers: _headers(fieldMask: fieldMask),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Map<String, String> _headers({String? fieldMask}) {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
    };
    if (fieldMask != null && fieldMask.trim().isNotEmpty) {
      headers['X-Goog-FieldMask'] = fieldMask;
    }
    return headers;
  }

  Map<String, String>? _stringifyQueryParameters(
    Map<String, dynamic>? values,
  ) {
    if (values == null || values.isEmpty) {
      return null;
    }

    final Map<String, String> result = <String, String>{};
    values.forEach((String key, dynamic value) {
      if (value == null) {
        return;
      }
      result[key] = '$value';
    });
    return result.isEmpty ? null : result;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GooglePlacesException(
        _errorMessage(response.body),
        statusCode: response.statusCode,
      );
    }

    if (response.body.trim().isEmpty) {
      return const <String, dynamic>{};
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw const GooglePlacesException(
        'Unexpected response format from Google Places.');
  }

  String _errorMessage(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final Map<String, dynamic>? error = decoded['error'] is Map
            ? Map<String, dynamic>.from(decoded['error'] as Map)
            : null;
        if (error != null) {
          return (error['message'] as String?)?.trim() ?? 'Request failed.';
        }
      }
    } catch (_) {}

    return body.trim().isEmpty ? 'Request failed.' : body.trim();
  }
}
