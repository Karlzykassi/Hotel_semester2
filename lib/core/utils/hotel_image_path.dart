import 'package:hote_v2/core/utils/hotel_reference_data.dart';

class HotelImagePath {
  HotelImagePath._();

  static const String _fallbackAsset = 'assets/Hotel 1.jpg';

  static String fromHotelName(String hotelName) {
    final String slug = _slugify(hotelName);
    if (slug.isEmpty) {
      return _fallbackAsset;
    }
    return 'assets/hotels/$slug.jpg';
  }

  static String fromProvince(String provinceName) {
    final String slug = _slugify(provinceName);
    if (slug.isEmpty) {
      return _fallbackAsset;
    }
    return 'assets/provinces/$slug.jpg';
  }

  static String bestForHotel(String hotelName, {String? provinceName}) {
    final String official = officialForHotel(hotelName) ?? '';
    if (official.isNotEmpty) {
      return official;
    }
    final String province = provinceName?.trim() ?? '';
    if (province.isNotEmpty) {
      return fromProvince(province);
    }
    return _fallbackAsset;
  }

  static String? officialForHotel(String hotelName) {
    return HotelReferenceData.officialImageForHotel(hotelName);
  }

  static bool isGenericSource(String? source) {
    final String trimmed = source?.trim() ?? '';
    return trimmed.isEmpty ||
        trimmed == _fallbackAsset ||
        trimmed.startsWith('assets/provinces/');
  }

  static String? preferredSource({
    String? primary,
    String? secondary,
  }) {
    final String primaryValue = primary?.trim() ?? '';
    final String secondaryValue = secondary?.trim() ?? '';

    if (primaryValue.isNotEmpty && !isGenericSource(primaryValue)) {
      return primaryValue;
    }
    if (secondaryValue.isNotEmpty && !isGenericSource(secondaryValue)) {
      return secondaryValue;
    }
    if (primaryValue.isNotEmpty) {
      return primaryValue;
    }
    if (secondaryValue.isNotEmpty) {
      return secondaryValue;
    }
    return null;
  }

  static String resolve(
    String hotelName, {
    String? source,
    String? provinceName,
  }) {
    final String official = officialForHotel(hotelName) ?? '';
    final String trimmed = source?.trim() ?? '';
    if (isGenericSource(trimmed)) {
      if (official.isNotEmpty) {
        return official;
      }
      return bestForHotel(hotelName, provinceName: provinceName);
    }

    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    return bestForHotel(hotelName, provinceName: provinceName);
  }

  static String _slugify(String value) {
    final String normalized = value
        .toLowerCase()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return normalized;
  }
}
