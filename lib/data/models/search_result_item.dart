import 'package:hote_v2/core/utils/hotel_reference_data.dart';
import 'package:hote_v2/core/utils/hotel_image_path.dart';

class SearchResultItem {
  const SearchResultItem({
    this.id,
    required this.name,
    required this.city,
    this.province,
    required this.rating,
    required this.price,
    required this.imageColor,
    this.imageUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.googleMapsUri,
  });

  final String? id;
  final String name;
  final String city;
  final String? province;
  final double rating;
  final int price;
  final int imageColor;
  final String? imageUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUri;

  factory SearchResultItem.fromSupabase(Map<String, dynamic> row) {
    final String hotelName =
        (row['hotel_name'] as String?) ?? (row['name'] as String?) ?? 'Hotel';
    final String? imageSource = HotelImagePath.preferredSource(
      primary: row['image_url'] as String?,
      secondary: row['hero_image_url'] as String?,
    );
    return SearchResultItem(
      id: row['hotel_id'] as String? ?? row['id'] as String?,
      name: hotelName,
      city: (row['city'] as String?) ?? '',
      province: (row['province'] as String?)?.trim(),
      rating: _asDouble(row['rating']),
      price: _asInt(row['price_from'] ?? row['price']),
      imageColor: _colorFromText(hotelName),
      imageUrl: HotelImagePath.resolve(
        hotelName,
        source: imageSource,
        provinceName:
            (row['province'] as String?)?.trim() ?? (row['city'] as String?),
      ),
      address: HotelReferenceData.resolveAddress(
        hotelName,
        source: (row['address'] as String?)?.trim(),
        city: (row['city'] as String?)?.trim(),
        province: (row['province'] as String?)?.trim(),
      ),
      latitude: _asNullableDouble(row['latitude']),
      longitude: _asNullableDouble(row['longitude']),
      googleMapsUri: (row['google_maps_uri'] as String?)?.trim(),
    );
  }

  String get provinceLabel {
    final String provinceValue = province?.trim() ?? '';
    if (provinceValue.isNotEmpty) {
      return provinceValue;
    }
    return city.trim();
  }

  String get locationLabel {
    final String addressValue = address?.trim() ?? '';
    if (addressValue.isNotEmpty) {
      return addressValue;
    }
    return provinceLabel;
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

  static double? _asNullableDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value');
  }

  static int _colorFromText(String input) {
    const List<int> palette = <int>[
      0xFFC5AE95,
      0xFFD8C1A1,
      0xFFD2B297,
      0xFFB8A698,
      0xFFB8B094,
      0xFF7A8B7D,
      0xFF7E9E8C,
      0xFF799B6C,
    ];

    final int hash = input.runes.fold<int>(
      0,
      (int previousValue, int rune) => previousValue + rune,
    );
    return palette[hash % palette.length];
  }
}
