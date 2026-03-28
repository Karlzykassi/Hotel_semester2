import 'package:hote_v2/core/utils/hotel_reference_data.dart';
import 'package:hote_v2/core/utils/hotel_image_path.dart';

class HotelItem {
  const HotelItem({
    this.id,
    required this.name,
    required this.city,
    this.province,
    required this.rating,
    required this.properties,
    required this.imageColor,
    this.imageUrl,
    this.priceFrom,
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
  final int properties;
  final int imageColor;
  final String? imageUrl;
  final int? priceFrom;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUri;

  factory HotelItem.fromSupabase(Map<String, dynamic> row,
      {int properties = 0}) {
    final String hotelName = (row['name'] as String?) ?? 'Unknown Hotel';
    final String? imageSource = HotelImagePath.preferredSource(
      primary: row['image_url'] as String?,
      secondary: row['hero_image_url'] as String?,
    );
    return HotelItem(
      id: row['id'] as String?,
      name: hotelName,
      city: (row['city'] as String?) ?? '',
      province: (row['province'] as String?)?.trim(),
      rating: _asDouble(row['rating']),
      properties: properties,
      imageColor: _colorFromText(hotelName),
      imageUrl: HotelImagePath.resolve(
        hotelName,
        source: imageSource,
        provinceName:
            (row['province'] as String?)?.trim() ?? (row['city'] as String?),
      ),
      priceFrom: _asInt(row['price_from']),
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

  String get displayProvince {
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
    return displayProvince;
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }

  static int? _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }

  static double? _asNullableDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value');
  }

  static int _colorFromText(String input) {
    const List<int> palette = <int>[
      0xFF5E8B7E,
      0xFF7A89C2,
      0xFFA1826F,
      0xFF6F8AC7,
      0xFFC08A58,
      0xFF6F9B88,
      0xFF9677A9,
    ];

    final int hash = input.runes.fold<int>(
      0,
      (int previousValue, int rune) => previousValue + rune,
    );
    return palette[hash % palette.length];
  }
}
