import 'dart:convert';
import 'dart:io';

import 'package:hote_v2/core/services/google_places_service.dart';
import 'package:hote_v2/data/models/google_place_hotel.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  final _SyncOptions options;
  try {
    options = _SyncOptions.parse(args);
  } catch (error) {
    stderr.writeln(error);
    stderr.writeln('');
    stderr.writeln(_SyncOptions.usage);
    exitCode = 64;
    return;
  }

  if (options.showHelp) {
    stdout.writeln(_SyncOptions.usage);
    return;
  }

  final _SyncConfig config;
  try {
    config = await _SyncConfig.load(options.configPath);
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
    return;
  }

  final GooglePlacesService places = GooglePlacesService(
    apiKey: config.googlePlacesApiKey,
    languageCode: options.languageCode,
    regionCode: options.regionCode,
  );
  final _SupabaseAdminClient supabase = _SupabaseAdminClient(
    supabaseUrl: config.supabaseUrl,
    serviceRoleKey: config.supabaseServiceRoleKey,
  );

  final List<GooglePlaceCandidate> candidates;
  try {
    candidates = await _loadCandidates(places, options);
  } catch (error) {
    stderr.writeln('Google Places search failed: $error');
    exitCode = 1;
    return;
  }

  if (candidates.isEmpty) {
    stdout.writeln('No Google Places hotels matched this search.');
    return;
  }

  stdout.writeln(
      'Found ${candidates.length} hotel candidate(s) from Google Places.');

  int syncedCount = 0;
  for (final GooglePlaceCandidate candidate in candidates) {
    try {
      final GooglePlaceHotel hotel =
          await places.fetchHotelDetails(candidate.placeId);
      await _syncHotel(
        supabase: supabase,
        hotel: hotel,
        options: options,
      );
      syncedCount += 1;
      stdout.writeln('Synced ${hotel.name} (${hotel.city})');
    } catch (error) {
      stderr.writeln('Skipped ${candidate.name}: $error');
    }
  }

  final String summaryPrefix = options.dryRun ? 'Prepared' : 'Synced';
  stdout
      .writeln('$summaryPrefix $syncedCount of ${candidates.length} hotel(s).');
}

Future<List<GooglePlaceCandidate>> _loadCandidates(
  GooglePlacesService places,
  _SyncOptions options,
) {
  if (options.isNearbySearch) {
    return places.searchHotelsNearby(
      latitude: options.latitude!,
      longitude: options.longitude!,
      radiusMeters: options.radiusMeters,
      maxResults: options.limit,
    );
  }

  return places.searchHotelsByText(
    query: options.textSearchQuery,
    maxResults: options.limit,
  );
}

Future<void> _syncHotel({
  required _SupabaseAdminClient supabase,
  required GooglePlaceHotel hotel,
  required _SyncOptions options,
}) async {
  final String hotelCity = hotel.city.isNotEmpty
      ? hotel.city
      : (hotel.province.isNotEmpty ? hotel.province : 'Unknown');
  final String baseSlug = _buildSlug(hotel.name, hotelCity, hotel.placeId);

  _ExistingHotel? existing = await supabase.findHotelByPlaceId(hotel.placeId);
  String slug = baseSlug;

  if (existing == null) {
    final _ExistingHotel? slugMatch = await supabase.findHotelBySlug(baseSlug);
    if (slugMatch != null) {
      final bool sameHotel =
          _normalized(slugMatch.name) == _normalized(hotel.name);
      if (sameHotel) {
        existing = slugMatch;
      } else {
        slug =
            '$baseSlug-${hotel.placeId.substring(0, hotel.placeId.length < 6 ? hotel.placeId.length : 6).toLowerCase()}';
      }
    }
  }

  existing ??= await supabase.findHotelByNameAndCity(
    name: hotel.name,
    city: hotelCity,
  );
  if (existing != null) {
    slug = existing.slug;
  }

  final int priceFrom = existing != null && existing.priceFrom > 0
      ? existing.priceFrom
      : _suggestedPriceFrom(
          rating: hotel.rating,
          basePrice: options.basePrice,
        );
  final String heroImageUrl = (hotel.photoUri?.trim().isNotEmpty ?? false)
      ? hotel.photoUri!.trim()
      : (existing?.heroImageUrl ?? '');
  final String? existingDescription = existing?.description?.trim();
  final Map<String, dynamic> payload = <String, dynamic>{
    'name': hotel.name,
    'slug': slug,
    'city': hotelCity,
    'province': hotel.province.isNotEmpty ? hotel.province : hotelCity,
    'country': hotel.country.isNotEmpty ? hotel.country : 'Cambodia',
    'address': hotel.formattedAddress,
    'description': existingDescription?.isNotEmpty == true
        ? existingDescription
        : _generatedDescription(hotel),
    'google_place_id': hotel.placeId,
    'google_maps_uri': hotel.googleMapsUri,
    'latitude': hotel.latitude,
    'longitude': hotel.longitude,
    'rating': hotel.rating <= 0 ? (existing?.rating ?? 0) : hotel.rating,
    'review_count': hotel.reviewCount <= 0
        ? (existing?.reviewCount ?? 0)
        : hotel.reviewCount,
    'hero_image_url': heroImageUrl.isEmpty ? null : heroImageUrl,
    'price_from': priceFrom,
  };

  if (options.dryRun) {
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    return;
  }

  final String hotelId = existing == null
      ? await supabase.insertHotel(payload)
      : await supabase.updateHotel(existing.id, payload);

  if (heroImageUrl.isNotEmpty) {
    await supabase.upsertPrimaryHotelImage(
      hotelId: hotelId,
      imageUrl: heroImageUrl,
    );
  }

  if (!await supabase.hotelHasRoomTypes(hotelId)) {
    await supabase.ensureDefaultRoomInventory(
      hotelId: hotelId,
      startingPrice: priceFrom,
    );
  }
}

String _buildSlug(String name, String city, String placeId) {
  final String base = _slugify(name);
  final String citySlug = _slugify(city);
  if (base.isEmpty) {
    return placeId.toLowerCase();
  }
  if (citySlug.isEmpty || base.endsWith(citySlug)) {
    return base;
  }
  return '$base-$citySlug';
}

String _slugify(String value) {
  return value
      .toLowerCase()
      .replaceAll('&', ' and ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

String _normalized(String value) {
  return value.trim().toLowerCase();
}

int _suggestedPriceFrom({
  required double rating,
  required int basePrice,
}) {
  if (rating >= 4.7) {
    return basePrice + 140;
  }
  if (rating >= 4.4) {
    return basePrice + 90;
  }
  if (rating >= 4.0) {
    return basePrice + 45;
  }
  return basePrice;
}

String _generatedDescription(GooglePlaceHotel hotel) {
  final String region = hotel.city.isNotEmpty
      ? hotel.city
      : (hotel.province.isNotEmpty ? hotel.province : hotel.country);
  final String ratingSummary = hotel.rating > 0
      ? 'Rated ${hotel.rating.toStringAsFixed(1)} on Google Places'
      : 'Imported from Google Places';
  return '$ratingSummary, ${hotel.name} is a stay in $region that was synced into the app so guests can book and pay through the project\'s own flow.';
}

class _SyncOptions {
  const _SyncOptions({
    required this.configPath,
    required this.limit,
    required this.radiusMeters,
    required this.basePrice,
    required this.languageCode,
    required this.regionCode,
    this.query,
    this.city,
    this.latitude,
    this.longitude,
    this.dryRun = false,
    this.showHelp = false,
  });

  final String configPath;
  final String? query;
  final String? city;
  final double? latitude;
  final double? longitude;
  final int limit;
  final double radiusMeters;
  final int basePrice;
  final String languageCode;
  final String regionCode;
  final bool dryRun;
  final bool showHelp;

  bool get isNearbySearch => latitude != null && longitude != null;

  String get textSearchQuery {
    final String trimmedQuery = query?.trim() ?? '';
    final String trimmedCity = city?.trim() ?? '';
    if (trimmedQuery.isNotEmpty && trimmedCity.isNotEmpty) {
      return trimmedQuery.toLowerCase().contains(trimmedCity.toLowerCase())
          ? trimmedQuery
          : '$trimmedQuery in $trimmedCity';
    }
    if (trimmedQuery.isNotEmpty) {
      return trimmedQuery;
    }
    if (trimmedCity.isNotEmpty) {
      return 'hotels in $trimmedCity';
    }
    throw const FormatException(
      'Provide --query or --city for text search, or use --latitude and --longitude for nearby search.',
    );
  }

  static const String usage = '''
Usage:
  dart run scripts/sync_google_places_hotels.dart --query "Rosewood Phnom Penh"
  dart run scripts/sync_google_places_hotels.dart --city "Siem Reap" --limit 12
  dart run scripts/sync_google_places_hotels.dart --latitude 11.5564 --longitude 104.9282 --radius 4000

Options:
  --config <path>       Path to the sync config JSON. Default: supabase/google_places_sync.json
  --query <text>        Google Places text search query.
  --city <name>         Convenience city hint for text search.
  --latitude <value>    Latitude for nearby search.
  --longitude <value>   Longitude for nearby search.
  --radius <meters>     Nearby search radius. Default: 5000
  --limit <count>       Max Google Places results. Default: 8
  --base-price <usd>    Fallback nightly price for new hotels. Default: 120
  --language <code>     Google Places language code. Default: en
  --region <code>       Google Places region code. Default: KH
  --dry-run             Print the hotel payloads without writing to Supabase.
  --help                Show this message.
''';

  factory _SyncOptions.parse(List<String> args) {
    final Map<String, String> values = <String, String>{};
    final Set<String> flags = <String>{};

    for (int index = 0; index < args.length; index += 1) {
      final String arg = args[index];
      if (!arg.startsWith('--')) {
        throw FormatException('Unexpected argument: $arg');
      }

      if (arg == '--dry-run' || arg == '--help') {
        flags.add(arg);
        continue;
      }

      if (index + 1 >= args.length) {
        throw FormatException('Missing value for $arg');
      }

      values[arg] = args[index + 1];
      index += 1;
    }

    final double? latitude = values['--latitude'] == null
        ? null
        : double.tryParse(values['--latitude']!);
    final double? longitude = values['--longitude'] == null
        ? null
        : double.tryParse(values['--longitude']!);
    if ((values.containsKey('--latitude') && latitude == null) ||
        (values.containsKey('--longitude') && longitude == null)) {
      throw const FormatException(
          'Latitude and longitude must be valid numbers.');
    }

    final int limit = values['--limit'] == null
        ? 8
        : int.tryParse(values['--limit']!) ??
            (throw const FormatException('--limit must be a whole number.'));
    final double radiusMeters = values['--radius'] == null
        ? 5000
        : double.tryParse(values['--radius']!) ??
            (throw const FormatException('--radius must be a number.'));
    final int basePrice = values['--base-price'] == null
        ? 120
        : int.tryParse(values['--base-price']!) ??
            (throw const FormatException(
                '--base-price must be a whole number.'));

    return _SyncOptions(
      configPath: values['--config']?.trim().isNotEmpty == true
          ? values['--config']!.trim()
          : 'supabase/google_places_sync.json',
      query: values['--query'],
      city: values['--city'],
      latitude: latitude,
      longitude: longitude,
      limit: limit,
      radiusMeters: radiusMeters,
      basePrice: basePrice,
      languageCode: (values['--language']?.trim().isNotEmpty ?? false)
          ? values['--language']!.trim()
          : 'en',
      regionCode: (values['--region']?.trim().isNotEmpty ?? false)
          ? values['--region']!.trim().toUpperCase()
          : 'KH',
      dryRun: flags.contains('--dry-run'),
      showHelp: flags.contains('--help'),
    );
  }
}

class _SyncConfig {
  const _SyncConfig({
    required this.supabaseUrl,
    required this.supabaseServiceRoleKey,
    required this.googlePlacesApiKey,
  });

  final String supabaseUrl;
  final String supabaseServiceRoleKey;
  final String googlePlacesApiKey;

  static Future<_SyncConfig> load(String path) async {
    final File file = File(path);
    if (!await file.exists()) {
      throw Exception(
        'Missing $path. Copy supabase/google_places_sync.example.json to google_places_sync.json and add your real keys.',
      );
    }

    final dynamic decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) {
      throw const FormatException('Sync config must be a JSON object.');
    }

    final Map<String, dynamic> values = Map<String, dynamic>.from(decoded);
    final String supabaseUrl =
        (values['SUPABASE_URL'] as String?)?.trim() ?? '';
    final String serviceRoleKey =
        (values['SUPABASE_SERVICE_ROLE_KEY'] as String?)?.trim() ?? '';
    final String googleApiKey =
        (values['GOOGLE_PLACES_API_KEY'] as String?)?.trim() ?? '';

    if (supabaseUrl.isEmpty || serviceRoleKey.isEmpty || googleApiKey.isEmpty) {
      throw const FormatException(
        'SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, and GOOGLE_PLACES_API_KEY are required.',
      );
    }

    return _SyncConfig(
      supabaseUrl: supabaseUrl,
      supabaseServiceRoleKey: serviceRoleKey,
      googlePlacesApiKey: googleApiKey,
    );
  }
}

class _ExistingHotel {
  const _ExistingHotel({
    required this.id,
    required this.slug,
    required this.name,
    required this.city,
    required this.priceFrom,
    required this.rating,
    required this.reviewCount,
    this.description,
    this.heroImageUrl,
  });

  final String id;
  final String slug;
  final String name;
  final String city;
  final int priceFrom;
  final double rating;
  final int reviewCount;
  final String? description;
  final String? heroImageUrl;

  factory _ExistingHotel.fromRow(Map<String, dynamic> row) {
    return _ExistingHotel(
      id: row['id'] as String,
      slug: (row['slug'] as String?)?.trim() ?? '',
      name: (row['name'] as String?)?.trim() ?? '',
      city: (row['city'] as String?)?.trim() ?? '',
      priceFrom: _asInt(row['price_from']),
      rating: _asDouble(row['rating']),
      reviewCount: _asInt(row['review_count']),
      description: (row['description'] as String?)?.trim(),
      heroImageUrl: (row['hero_image_url'] as String?)?.trim(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }
}

class _SupabaseAdminClient {
  _SupabaseAdminClient({
    required this.supabaseUrl,
    required this.serviceRoleKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String supabaseUrl;
  final String serviceRoleKey;
  final http.Client _httpClient;

  Future<_ExistingHotel?> findHotelByPlaceId(String placeId) async {
    final Map<String, dynamic>? row = await getRow(
      'hotels',
      queryParameters: <String, dynamic>{
        'select':
            'id,slug,name,city,price_from,description,hero_image_url,rating,review_count',
        'google_place_id': 'eq.$placeId',
        'limit': 1,
      },
    );
    return row == null ? null : _ExistingHotel.fromRow(row);
  }

  Future<_ExistingHotel?> findHotelBySlug(String slug) async {
    final Map<String, dynamic>? row = await getRow(
      'hotels',
      queryParameters: <String, dynamic>{
        'select':
            'id,slug,name,city,price_from,description,hero_image_url,rating,review_count',
        'slug': 'eq.$slug',
        'limit': 1,
      },
    );
    return row == null ? null : _ExistingHotel.fromRow(row);
  }

  Future<_ExistingHotel?> findHotelByNameAndCity({
    required String name,
    required String city,
  }) async {
    final Map<String, dynamic>? row = await getRow(
      'hotels',
      queryParameters: <String, dynamic>{
        'select':
            'id,slug,name,city,price_from,description,hero_image_url,rating,review_count',
        'name': 'eq.$name',
        'city': 'eq.$city',
        'limit': 1,
      },
    );
    return row == null ? null : _ExistingHotel.fromRow(row);
  }

  Future<String> insertHotel(Map<String, dynamic> payload) async {
    final List<dynamic> rows = await insertRows(
      'hotels',
      body: payload,
      queryParameters: const <String, dynamic>{'select': 'id'},
    );
    if (rows.isEmpty || rows.first is! Map) {
      throw const _SupabaseAdminException('Hotel insert did not return an id.');
    }

    return (rows.first as Map)['id'] as String;
  }

  Future<String> updateHotel(
    String hotelId,
    Map<String, dynamic> payload,
  ) async {
    final List<dynamic> rows = await updateRows(
      'hotels',
      body: payload,
      queryParameters: <String, dynamic>{
        'id': 'eq.$hotelId',
        'select': 'id',
      },
    );
    if (rows.isEmpty || rows.first is! Map) {
      return hotelId;
    }

    return (rows.first as Map)['id'] as String;
  }

  Future<void> upsertPrimaryHotelImage({
    required String hotelId,
    required String imageUrl,
  }) async {
    final Map<String, dynamic>? existing = await getRow(
      'hotel_images',
      queryParameters: <String, dynamic>{
        'select': 'id',
        'hotel_id': 'eq.$hotelId',
        'is_primary': 'eq.true',
        'limit': 1,
      },
    );

    if (existing == null) {
      await insertRows(
        'hotel_images',
        body: <String, dynamic>{
          'hotel_id': hotelId,
          'image_url': imageUrl,
          'sort_order': 0,
          'is_primary': true,
        },
      );
      return;
    }

    await updateRows(
      'hotel_images',
      body: <String, dynamic>{
        'image_url': imageUrl,
        'sort_order': 0,
        'is_primary': true,
      },
      queryParameters: <String, dynamic>{
        'id': 'eq.${existing['id']}',
        'hotel_id': 'eq.$hotelId',
      },
    );
  }

  Future<bool> hotelHasRoomTypes(String hotelId) async {
    final Map<String, dynamic>? row = await getRow(
      'room_types',
      queryParameters: <String, dynamic>{
        'select': 'id',
        'hotel_id': 'eq.$hotelId',
        'limit': 1,
      },
    );
    return row != null;
  }

  Future<void> ensureDefaultRoomInventory({
    required String hotelId,
    required int startingPrice,
  }) async {
    await rpcVoid(
      'ensure_default_room_inventory',
      body: <String, dynamic>{
        'target_hotel_id': hotelId,
        'starting_price': startingPrice,
      },
    );
  }

  Future<Map<String, dynamic>?> getRow(
    String table, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final List<dynamic> rows = await getRows(
      table,
      queryParameters: queryParameters,
    );
    if (rows.isEmpty) {
      return null;
    }

    return _asMap(rows.first);
  }

  Future<List<dynamic>> getRows(
    String table, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _requestRows(
      'GET',
      _restUri(table, queryParameters: queryParameters),
    );
  }

  Future<List<dynamic>> insertRows(
    String table, {
    required Object body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _requestRows(
      'POST',
      _restUri(table, queryParameters: queryParameters),
      body: body,
      prefer: 'return=representation',
    );
  }

  Future<List<dynamic>> updateRows(
    String table, {
    required Object body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _requestRows(
      'PATCH',
      _restUri(table, queryParameters: queryParameters),
      body: body,
      prefer: 'return=representation',
    );
  }

  Future<void> rpcVoid(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    await _requestRows(
      'POST',
      _restUri('rpc/$functionName'),
      body: body ?? const <String, dynamic>{},
    );
  }

  Future<List<dynamic>> _requestRows(
    String method,
    Uri uri, {
    Object? body,
    String? prefer,
  }) async {
    final http.Response response = await _send(
      method,
      uri,
      body: body,
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
    if (decoded is Map) {
      return <dynamic>[Map<String, dynamic>.from(decoded)];
    }

    throw const _SupabaseAdminException(
        'Unexpected response format from Supabase.');
  }

  Future<http.Response> _send(
    String method,
    Uri uri, {
    Object? body,
    String? prefer,
  }) async {
    final Map<String, String> headers = <String, String>{
      'apikey': serviceRoleKey,
      'Authorization': 'Bearer $serviceRoleKey',
      'Accept': 'application/json',
    };
    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }
    if (prefer != null && prefer.trim().isNotEmpty) {
      headers['Prefer'] = prefer;
    }

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
      default:
        throw _SupabaseAdminException('Unsupported method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    throw _SupabaseAdminException(
      _errorMessage(response.body),
      statusCode: response.statusCode,
    );
  }

  Uri _restUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri.parse('$supabaseUrl/rest/v1/$path').replace(
      queryParameters: _stringifyQueryParameters(queryParameters),
    );
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

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw const _SupabaseAdminException('Unexpected row format from Supabase.');
  }

  String _errorMessage(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final String? message = (decoded['message'] as String?)?.trim();
        final String? hint = (decoded['hint'] as String?)?.trim();
        return message ?? hint ?? 'Supabase request failed.';
      }
    } catch (_) {}

    return body.trim().isEmpty ? 'Supabase request failed.' : body.trim();
  }
}

class _SupabaseAdminException implements Exception {
  const _SupabaseAdminException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
