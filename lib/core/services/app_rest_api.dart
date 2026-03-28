import 'dart:convert';

import 'package:hote_v2/core/config/app_config.dart';
import 'package:hote_v2/core/services/app_backend.dart';
import 'package:http/http.dart' as http;

class BackendException implements Exception {
  const BackendException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AppRestApi {
  AppRestApi._();

  static final http.Client _httpClient = http.Client();

  static Future<List<dynamic>> getRows(
    String table, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) {
    return _requestRows(
      'GET',
      AppConfig.restUri(table, queryParameters: queryParameters),
      requiresAuth: requiresAuth,
    );
  }

  static Future<Map<String, dynamic>?> getRow(
    String table, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    final List<dynamic> rows = await getRows(
      table,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
    if (rows.isEmpty) {
      return null;
    }

    return _asMap(rows.first);
  }

  static Future<List<dynamic>> insertRows(
    String table, {
    required Object body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool upsert = false,
  }) {
    final String prefer = upsert
        ? 'resolution=merge-duplicates,return=representation'
        : 'return=representation';

    return _requestRows(
      'POST',
      AppConfig.restUri(table, queryParameters: queryParameters),
      body: body,
      requiresAuth: requiresAuth,
      prefer: prefer,
    );
  }

  static Future<List<dynamic>> updateRows(
    String table, {
    required Object body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool returnRepresentation = false,
  }) {
    return _requestRows(
      'PATCH',
      AppConfig.restUri(table, queryParameters: queryParameters),
      body: body,
      requiresAuth: requiresAuth,
      prefer: returnRepresentation ? 'return=representation' : null,
    );
  }

  static Future<void> deleteRows(
    String table, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) async {
    await _requestRows(
      'DELETE',
      AppConfig.restUri(table, queryParameters: queryParameters),
      requiresAuth: requiresAuth,
    );
  }

  static Future<List<dynamic>> rpc(
    String functionName, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
  }) {
    return _requestRows(
      'POST',
      AppConfig.restUri('rpc/$functionName', queryParameters: queryParameters),
      body: body ?? const <String, dynamic>{},
      requiresAuth: requiresAuth,
    );
  }

  static Future<List<dynamic>> _requestRows(
    String method,
    Uri uri, {
    Object? body,
    bool requiresAuth = false,
    String? prefer,
  }) async {
    final http.Response response = await _send(
      method,
      uri,
      body: body,
      requiresAuth: requiresAuth,
      prefer: prefer,
    );

    if (response.statusCode == 204 || response.body.trim().isEmpty) {
      return const <dynamic>[];
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      return <dynamic>[decoded];
    }

    throw const BackendException('Unexpected response format from server.');
  }

  static Future<http.Response> _send(
    String method,
    Uri uri, {
    Object? body,
    bool requiresAuth = false,
    String? prefer,
  }) async {
    final Map<String, String> headers = _headers(
      requiresAuth: requiresAuth,
      hasJsonBody: body != null,
      prefer: prefer,
    );

    late final http.Response response;
    switch (method) {
      case 'GET':
        response = await _httpClient.get(uri, headers: headers);
        break;
      case 'POST':
        response = await _httpClient.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'PATCH':
        response = await _httpClient.patch(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'DELETE':
        response = await _httpClient.delete(uri, headers: headers);
        break;
      default:
        throw BackendException('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    throw BackendException(
      _errorMessage(response),
      statusCode: response.statusCode,
    );
  }

  static Map<String, String> _headers({
    required bool requiresAuth,
    required bool hasJsonBody,
    String? prefer,
  }) {
    final String? accessToken = AppBackend.accessToken;
    if (requiresAuth && (accessToken == null || accessToken.trim().isEmpty)) {
      throw const BackendException('Please sign in to continue.');
    }

    final Map<String, String> headers = <String, String>{
      'apikey': AppConfig.supabaseAnonKey,
      'Authorization':
          'Bearer ${(accessToken == null || accessToken.trim().isEmpty) ? AppConfig.supabaseAnonKey : accessToken}',
      'Accept': 'application/json',
    };

    if (hasJsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (prefer != null && prefer.trim().isNotEmpty) {
      headers['Prefer'] = prefer;
    }

    return headers;
  }

  static String _errorMessage(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final String? message = (decoded['message'] as String?)?.trim();
        final String? description =
            (decoded['error_description'] as String?)?.trim();
        final String? hint = (decoded['hint'] as String?)?.trim();
        return message ?? description ?? hint ?? 'Request failed.';
      }
    } catch (_) {}

    return response.body.trim().isEmpty ? 'Request failed.' : response.body;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw const BackendException('Unexpected row format from server.');
  }
}
