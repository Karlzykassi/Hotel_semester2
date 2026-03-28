class GooglePlaceHotel {
  const GooglePlaceHotel({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.city,
    required this.province,
    required this.country,
    required this.rating,
    required this.reviewCount,
    this.latitude,
    this.longitude,
    this.googleMapsUri,
    this.photoUri,
  });

  final String placeId;
  final String name;
  final String formattedAddress;
  final String city;
  final String province;
  final String country;
  final double rating;
  final int reviewCount;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUri;
  final String? photoUri;

  factory GooglePlaceHotel.fromGooglePlaceDetails(
    Map<String, dynamic> row, {
    String? photoUri,
  }) {
    final List<Map<String, dynamic>> addressComponents =
        _addressComponents(row['addressComponents']);
    final String formattedAddress =
        (row['formattedAddress'] as String?)?.trim() ?? '';
    final _ParsedAddress parsedAddress = _ParsedAddress.fromGooglePlace(
      formattedAddress: formattedAddress,
      components: addressComponents,
    );
    final Map<String, dynamic> location = _asMap(row['location']);

    return GooglePlaceHotel(
      placeId: (row['id'] as String?)?.trim() ?? '',
      name: _displayName(row['displayName']),
      formattedAddress: formattedAddress,
      city: parsedAddress.city,
      province: parsedAddress.province,
      country: parsedAddress.country,
      rating: _asDouble(row['rating']),
      reviewCount: _asInt(row['userRatingCount']),
      latitude: _nullableDouble(location['latitude']),
      longitude: _nullableDouble(location['longitude']),
      googleMapsUri: (row['googleMapsUri'] as String?)?.trim(),
      photoUri: photoUri?.trim().isEmpty ?? true ? null : photoUri!.trim(),
    );
  }

  static String _displayName(dynamic value) {
    if (value is String) {
      return value.trim();
    }

    if (value is Map) {
      return (value['text'] as String?)?.trim() ?? '';
    }

    return '';
  }

  static List<Map<String, dynamic>> _addressComponents(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map((Map component) => Map<String, dynamic>.from(component))
        .toList(growable: false);
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }

  static double? _nullableDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value');
  }
}

class _ParsedAddress {
  const _ParsedAddress({
    required this.city,
    required this.province,
    required this.country,
  });

  final String city;
  final String province;
  final String country;

  factory _ParsedAddress.fromGooglePlace({
    required String formattedAddress,
    required List<Map<String, dynamic>> components,
  }) {
    final String locality = _componentText(
      components,
      const <String>[
        'locality',
        'postal_town',
        'administrative_area_level_2',
        'sublocality_level_1',
      ],
    );
    final String province = _componentText(
      components,
      const <String>['administrative_area_level_1'],
    );
    final String country = _componentText(
      components,
      const <String>['country'],
    );

    final List<String> addressParts = formattedAddress
        .split(',')
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);

    final String fallbackRegion =
        addressParts.length >= 2 ? addressParts[addressParts.length - 2] : '';

    return _ParsedAddress(
      city: locality.isNotEmpty ? locality : fallbackRegion,
      province: province.isNotEmpty
          ? province
          : (fallbackRegion.isNotEmpty ? fallbackRegion : locality),
      country: country.isNotEmpty
          ? country
          : (addressParts.isNotEmpty ? addressParts.last : 'Cambodia'),
    );
  }

  static String _componentText(
    List<Map<String, dynamic>> components,
    List<String> expectedTypes,
  ) {
    for (final Map<String, dynamic> component in components) {
      final List<String> types =
          (component['types'] as List<dynamic>? ?? const [])
              .map((dynamic value) => '$value')
              .toList(growable: false);
      final bool matches = expectedTypes.any(types.contains);
      if (!matches) {
        continue;
      }

      final String text = (component['longText'] as String?)?.trim() ??
          (component['shortText'] as String?)?.trim() ??
          '';
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }
}
