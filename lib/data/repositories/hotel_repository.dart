import 'package:hote_v2/core/services/app_backend.dart';
import 'package:hote_v2/core/services/app_rest_api.dart';
import 'package:hote_v2/core/utils/app_color_seed.dart';
import 'package:hote_v2/core/utils/hotel_image_path.dart';
import 'package:hote_v2/data/mock/app_data.dart';
import 'package:hote_v2/data/mock/mock_backend_store.dart';
import 'package:hote_v2/data/models/hotel_item.dart';
import 'package:hote_v2/data/models/search_result_item.dart';

class HotelRepository {
  HotelRepository();

  Future<List<HotelItem>> fetchPopularHotels() async {
    if (!AppBackend.isEnabled) {
      return AppData.popularHotels;
    }

    try {
      final List<dynamic> rows = await AppRestApi.getRows(
        'hotels',
        queryParameters: <String, dynamic>{
          'select':
              'id,name,city,province,address,latitude,longitude,rating,hero_image_url,price_from',
          'order': 'rating.desc',
          'limit': 10,
        },
      );

      return rows
          .map(
            (dynamic row) => HotelItem.fromSupabase(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return AppData.popularHotels;
    }
  }

  Future<List<HotelItem>> fetchDestinations() async {
    if (!AppBackend.isEnabled) {
      return AppData.destinations;
    }

    try {
      final List<dynamic> rows = await AppRestApi.getRows(
        'hotels',
        queryParameters: <String, dynamic>{
          'select': 'province,city,hero_image_url,name',
          'order': 'province.asc',
        },
      );
      final Map<String, List<Map<String, dynamic>>> grouped =
          <String, List<Map<String, dynamic>>>{};

      for (final dynamic row in rows) {
        final Map<String, dynamic> hotel =
            Map<String, dynamic>.from(row as Map);
        final String province =
            ((hotel['province'] as String?)?.trim().isNotEmpty ?? false)
                ? (hotel['province'] as String).trim()
                : ((hotel['city'] as String?)?.trim() ?? '');
        if (province.isEmpty) {
          continue;
        }
        grouped
            .putIfAbsent(province, () => <Map<String, dynamic>>[])
            .add(hotel);
      }

      final List<MapEntry<String, List<Map<String, dynamic>>>> provinces =
          grouped.entries.toList(growable: false)
            ..sort(
              (
                MapEntry<String, List<Map<String, dynamic>>> left,
                MapEntry<String, List<Map<String, dynamic>>> right,
              ) =>
                  left.key.compareTo(right.key),
            );

      return provinces.map(
        (MapEntry<String, List<Map<String, dynamic>>> entry) {
          final String imageUrl = _resolvedDestinationImage(
            province: entry.key,
            hotels: entry.value,
          );
          return HotelItem(
            name: entry.key,
            city: entry.key,
            province: entry.key,
            rating: 0,
            properties: entry.value.length,
            imageColor: AppColorSeed.fromText(entry.key),
            imageUrl: imageUrl,
          );
        },
      ).toList(growable: false);
    } catch (_) {
      return AppData.destinations;
    }
  }

  Future<List<String>> fetchCities() async {
    if (!AppBackend.isEnabled) {
      final List<String> provinces = List<String>.from(AppData.cities);
      provinces.sort();
      return provinces;
    }

    try {
      final List<dynamic> rows = await AppRestApi.getRows(
        'hotels',
        queryParameters: <String, dynamic>{
          'select': 'province,city',
          'order': 'province.asc',
        },
      );
      final Set<String> provinces = <String>{};
      for (final dynamic row in rows) {
        final Map<dynamic, dynamic> value = row as Map;
        final String province = (value['province'] as String?)?.trim() ??
            (value['city'] as String?)?.trim() ??
            '';
        if (province.isNotEmpty) {
          provinces.add(province);
        }
      }
      final List<String> sorted = provinces.toList(growable: false)..sort();
      return sorted;
    } catch (_) {
      final List<String> provinces = List<String>.from(AppData.cities);
      provinces.sort();
      return provinces;
    }
  }

  Future<List<String>> fetchSearchHistory() async {
    final String? userId = AppBackend.currentUserId;
    if (!AppBackend.isEnabled || userId == null) {
      return MockBackendStore.searchHistory;
    }

    try {
      final List<dynamic> rows = await AppRestApi.getRows(
        'search_history',
        queryParameters: <String, dynamic>{
          'select': 'query_text',
          'user_id': 'eq.$userId',
          'order': 'created_at.desc',
          'limit': 10,
        },
        requiresAuth: true,
      );
      return rows
          .map((dynamic row) => ((row as Map)['query_text'] as String?) ?? '')
          .where((String value) => value.trim().isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return MockBackendStore.searchHistory;
    }
  }

  Future<void> saveSearch(String query, {String? city}) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final String? userId = AppBackend.currentUserId;
    if (!AppBackend.isEnabled || userId == null) {
      await MockBackendStore.saveSearch(trimmed);
      return;
    }

    await AppRestApi.insertRows(
      'search_history',
      body: <String, dynamic>{
        'user_id': userId,
        'query_text': trimmed,
        'city': city?.trim().isEmpty ?? true ? null : city!.trim(),
      },
      requiresAuth: true,
    );
  }

  Future<void> removeSearch(String query) async {
    final String? userId = AppBackend.currentUserId;
    if (!AppBackend.isEnabled || userId == null) {
      await MockBackendStore.removeSearch(query);
      return;
    }

    await AppRestApi.deleteRows(
      'search_history',
      queryParameters: <String, dynamic>{
        'user_id': 'eq.$userId',
        'query_text': 'eq.$query',
      },
      requiresAuth: true,
    );
  }

  Future<List<SearchResultItem>> searchHotels({
    String? city,
    String? query,
    int guests = 1,
  }) async {
    if (!AppBackend.isEnabled) {
      return _searchHotelsFromMock(city: city, query: query);
    }

    try {
      final List<SearchResultItem> tableResults = await _searchHotelsFromTables(
        city: city,
        query: query,
        guests: guests,
      );
      if (tableResults.isNotEmpty) {
        return tableResults;
      }
    } catch (_) {}

    try {
      final List<dynamic> rows = await AppRestApi.rpc(
        'search_hotels',
        body: <String, dynamic>{
          'search_city': city,
          'search_query': query,
          'guest_capacity': guests,
        },
      );

      final List<Map<String, dynamic>> searchRows = rows
          .map((dynamic row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false);
      final Map<String, Map<String, dynamic>> hotelDetailsById =
          await _fetchHotelDetailsById(searchRows);

      return searchRows.map((Map<String, dynamic> row) {
        final String hotelId = (row['hotel_id'] as String?)?.trim() ?? '';
        final Map<String, dynamic> merged = _mergeSearchRow(
          row,
          hotelDetailsById[hotelId],
        );
        return SearchResultItem.fromSupabase(merged);
      }).toList(growable: false);
    } catch (_) {
      return _searchHotelsFromMock(city: city, query: query);
    }
  }

  Future<int> fetchSearchResultCount(String city) async {
    final List<SearchResultItem> results = await searchHotels(city: city);
    return results.length;
  }

  List<SearchResultItem> _searchHotelsFromMock({
    String? city,
    String? query,
  }) {
    final Iterable<SearchResultItem> all = AppData.searchResultsByCity.values
        .expand((List<SearchResultItem> items) => items);

    final List<SearchResultItem> results = all.where((SearchResultItem item) {
      final String province = item.provinceLabel;
      final bool matchesCity =
          city == null || city.trim().isEmpty || province == city.trim();
      final bool matchesQuery = query == null ||
          query.trim().isEmpty ||
          province.toLowerCase().contains(query.trim().toLowerCase());
      return matchesCity && matchesQuery;
    }).toList(growable: false);

    results.sort((SearchResultItem left, SearchResultItem right) {
      final int provinceCompare =
          left.provinceLabel.compareTo(right.provinceLabel);
      if (provinceCompare != 0) {
        return provinceCompare;
      }
      return left.name.compareTo(right.name);
    });

    return results;
  }

  String _resolvedDestinationImage({
    required String province,
    required List<Map<String, dynamic>> hotels,
  }) {
    for (final Map<String, dynamic> hotel in hotels) {
      final String resolved = HotelImagePath.resolve(
        (hotel['name'] as String?) ?? province,
        source: hotel['hero_image_url'] as String?,
        provinceName: province,
      );
      if (!resolved.startsWith('assets/provinces/')) {
        return resolved;
      }
    }
    return HotelImagePath.fromProvince(province);
  }

  Future<List<SearchResultItem>> _searchHotelsFromTables({
    String? city,
    String? query,
    required int guests,
  }) async {
    final List<dynamic> hotelRows = await AppRestApi.getRows(
      'hotels',
      queryParameters: <String, dynamic>{
        'select':
            'id,name,city,province,address,latitude,longitude,rating,hero_image_url',
        'order': 'province.asc,name.asc',
      },
    );

    final List<Map<String, dynamic>> filteredHotels = hotelRows
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .where(
          (Map<String, dynamic> row) => _matchesSearchFilters(
            row,
            city: city,
            query: query,
          ),
        )
        .toList(growable: false);

    if (filteredHotels.isEmpty) {
      return const <SearchResultItem>[];
    }

    final List<String> hotelIds = filteredHotels
        .map((Map<String, dynamic> row) => (row['id'] as String?)?.trim() ?? '')
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);

    if (hotelIds.isEmpty) {
      return const <SearchResultItem>[];
    }

    final List<dynamic> roomRows = await AppRestApi.getRows(
      'room_types',
      queryParameters: <String, dynamic>{
        'select': 'hotel_id,price_per_night,capacity',
        'hotel_id': 'in.(${hotelIds.join(',')})',
        'capacity': 'gte.${guests < 1 ? 1 : guests}',
      },
    );

    final Map<String, int> priceByHotelId = <String, int>{};
    for (final dynamic row in roomRows) {
      final Map<String, dynamic> value = Map<String, dynamic>.from(row as Map);
      final String hotelId = (value['hotel_id'] as String?)?.trim() ?? '';
      if (hotelId.isEmpty) {
        continue;
      }
      final int price = _asPrice(value['price_per_night']);
      final int? current = priceByHotelId[hotelId];
      if (current == null || price < current) {
        priceByHotelId[hotelId] = price;
      }
    }

    final List<SearchResultItem> results = filteredHotels
        .where(
      (Map<String, dynamic> row) =>
          priceByHotelId.containsKey((row['id'] as String?)?.trim() ?? ''),
    )
        .map((Map<String, dynamic> row) {
      final String hotelId = (row['id'] as String?)?.trim() ?? '';
      return SearchResultItem.fromSupabase(
        <String, dynamic>{
          ...row,
          'hotel_id': hotelId,
          'hotel_name': row['name'],
          'price_from': priceByHotelId[hotelId] ?? 0,
        },
      );
    }).toList(growable: false);

    results.sort((SearchResultItem left, SearchResultItem right) {
      final int provinceCompare =
          left.provinceLabel.compareTo(right.provinceLabel);
      if (provinceCompare != 0) {
        return provinceCompare;
      }
      final int nameCompare = left.name.compareTo(right.name);
      if (nameCompare != 0) {
        return nameCompare;
      }
      return left.price.compareTo(right.price);
    });

    return results;
  }

  Future<Map<String, Map<String, dynamic>>> _fetchHotelDetailsById(
    List<Map<String, dynamic>> searchRows,
  ) async {
    final List<String> ids = searchRows
        .map((Map<String, dynamic> row) => (row['hotel_id'] as String?) ?? '')
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (ids.isEmpty) {
      return const <String, Map<String, dynamic>>{};
    }

    try {
      final List<dynamic> rows = await AppRestApi.getRows(
        'hotels',
        queryParameters: <String, dynamic>{
          'select':
              'id,name,city,province,address,latitude,longitude,hero_image_url',
          'id': 'in.(${ids.join(',')})',
        },
      );

      return <String, Map<String, dynamic>>{
        for (final dynamic row in rows)
          if (((row as Map)['id'] as String?)?.trim().isNotEmpty ?? false)
            ((row['id'] as String?)!).trim(): Map<String, dynamic>.from(row),
      };
    } catch (_) {
      return const <String, Map<String, dynamic>>{};
    }
  }

  Map<String, dynamic> _mergeSearchRow(
    Map<String, dynamic> row,
    Map<String, dynamic>? detail,
  ) {
    if (detail == null || detail.isEmpty) {
      return row;
    }

    final Map<String, dynamic> merged = Map<String, dynamic>.from(row);
    final String city = (merged['city'] as String?)?.trim() ?? '';
    final String province = (merged['province'] as String?)?.trim() ?? '';
    final String address = (merged['address'] as String?)?.trim() ?? '';
    final String mapsUri = (merged['google_maps_uri'] as String?)?.trim() ?? '';
    final String hotelName = (merged['hotel_name'] as String?)?.trim() ?? '';
    final String heroImageUrl =
        (merged['hero_image_url'] as String?)?.trim() ?? '';

    if (city.isEmpty) {
      merged['city'] = detail['city'];
    }
    if (province.isEmpty) {
      merged['province'] = detail['province'];
    }
    if (address.isEmpty) {
      merged['address'] = detail['address'];
    }
    if (mapsUri.isEmpty) {
      merged['google_maps_uri'] = detail['google_maps_uri'];
    }
    if (merged['latitude'] == null) {
      merged['latitude'] = detail['latitude'];
    }
    if (merged['longitude'] == null) {
      merged['longitude'] = detail['longitude'];
    }
    if (hotelName.isEmpty) {
      merged['hotel_name'] = detail['name'];
    }
    if (HotelImagePath.isGenericSource(heroImageUrl)) {
      merged['hero_image_url'] = detail['hero_image_url'];
    }

    return merged;
  }

  bool _matchesSearchFilters(
    Map<String, dynamic> hotel, {
    String? city,
    String? query,
  }) {
    final String province = (hotel['province'] as String?)?.trim() ?? '';
    final String cityValue = (hotel['city'] as String?)?.trim() ?? '';
    final String hotelName = (hotel['name'] as String?)?.trim() ?? '';
    final String address = (hotel['address'] as String?)?.trim() ?? '';

    final bool matchesCity = _matchesTextFilter(
      filter: city,
      values: <String>[province, cityValue],
    );
    final bool matchesQuery = _matchesTextFilter(
      filter: query,
      values: <String>[province, cityValue, hotelName, address],
    );

    return matchesCity && matchesQuery;
  }

  bool _matchesTextFilter({
    required String? filter,
    required List<String> values,
  }) {
    final String trimmed = filter?.trim().toLowerCase() ?? '';
    if (trimmed.isEmpty) {
      return true;
    }

    return values.any(
      (String value) => value.trim().toLowerCase().contains(trimmed),
    );
  }

  int _asPrice(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }
}
