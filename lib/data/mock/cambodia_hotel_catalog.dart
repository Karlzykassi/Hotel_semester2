import 'package:hote_v2/core/utils/app_color_seed.dart';
import 'package:hote_v2/core/utils/hotel_reference_data.dart';
import 'package:hote_v2/core/utils/hotel_image_path.dart';
import 'package:hote_v2/data/models/hotel_item.dart';
import 'package:hote_v2/data/models/search_result_item.dart';

class CambodiaHotelCatalog {
  CambodiaHotelCatalog._();

  static final List<_HotelSeed> _hotels = <_HotelSeed>[
    const _HotelSeed(
      name: 'Rosewood Phnom Penh',
      city: 'Phnom Penh',
      rating: 4.8,
      price: 300,
    ),
    const _HotelSeed(
      name: 'Palace Gate Hotel',
      city: 'Phnom Penh',
      rating: 4.6,
      price: 220,
    ),
    const _HotelSeed(
      name: 'Sofitel Phnom Penh Phokeethra',
      city: 'Phnom Penh',
      rating: 4.5,
      price: 240,
    ),
    const _HotelSeed(
      name: 'Golden Temple Hotel',
      city: 'Siem Reap',
      rating: 4.8,
      price: 260,
    ),
    const _HotelSeed(
      name: 'Shinta Mani Angkor',
      city: 'Siem Reap',
      rating: 4.7,
      price: 280,
    ),
    const _HotelSeed(
      name: 'Saem Siemreap Hotel',
      city: 'Siem Reap',
      rating: 4.3,
      price: 190,
    ),
    const _HotelSeed(
      name: 'Kampot Sweet Boutique',
      city: 'Kampot',
      rating: 4.6,
      price: 210,
      address:
          'Krang Village, Trapeang Thum Commune, Tuek Chhou District, Kampot Province',
    ),
    const _HotelSeed(
      name: 'Amber Kampot',
      city: 'Kampot',
      rating: 4.4,
      price: 190,
    ),
    const _HotelSeed(
      name: 'Castle Bayview Resort',
      city: 'Kampot',
      rating: 4.2,
      price: 175,
    ),
    const _HotelSeed(
      name: 'Veranda Natural Resort',
      city: 'Kep',
      rating: 4.7,
      price: 240,
    ),
    const _HotelSeed(
      name: 'Knai Bang Chatt',
      city: 'Kep',
      rating: 4.5,
      price: 230,
    ),
    const _HotelSeed(
      name: 'Kep Bay Hotel & Resort',
      city: 'Kep',
      rating: 4.1,
      price: 170,
    ),
    const _HotelSeed(
      name: 'Battambang Riverside Hotel',
      city: 'Battambang',
      rating: 4.4,
      price: 155,
    ),
    const _HotelSeed(
      name: 'Battambang Heritage Resort',
      city: 'Battambang',
      rating: 4.2,
      price: 180,
    ),
    const _HotelSeed(
      name: 'Classy Hotel Battambang',
      city: 'Battambang',
      rating: 4.1,
      price: 145,
    ),
    const _HotelSeed(
      name: 'Sihanoukville Bay Hotel',
      city: 'Sihanoukville',
      province: 'Preah Sihanouk',
      rating: 4.5,
      price: 210,
    ),
    const _HotelSeed(
      name: 'Otres Beach Resort',
      city: 'Sihanoukville',
      province: 'Preah Sihanouk',
      rating: 4.3,
      price: 185,
    ),
    const _HotelSeed(
      name: 'Sokha Blue Harbor Hotel',
      city: 'Sihanoukville',
      province: 'Preah Sihanouk',
      rating: 4.2,
      price: 220,
    ),
    const _HotelSeed(
      name: 'Koh Kong Riverside Resort',
      city: 'Koh Kong',
      rating: 4.3,
      price: 165,
    ),
    const _HotelSeed(
      name: 'Tatai Eco Lodge',
      city: 'Koh Kong',
      rating: 4.6,
      price: 205,
      address:
          'Koh Andet Village, Tatai Commune, Koh Kong District, Koh Kong Province',
    ),
    const _HotelSeed(
      name: 'Cardamom Bay Hotel',
      city: 'Koh Kong',
      rating: 4.0,
      price: 150,
    ),
    const _HotelSeed(
      name: 'Kratie Mekong Hotel',
      city: 'Kratie',
      rating: 4.2,
      price: 145,
    ),
    const _HotelSeed(
      name: 'Dolphin View Riverside',
      city: 'Kratie',
      rating: 4.4,
      price: 160,
    ),
    const _HotelSeed(
      name: 'Soriyabori Riverside Resort',
      city: 'Kratie',
      rating: 4.5,
      price: 195,
    ),
    const _HotelSeed(
      name: 'Mondulkiri Hill Resort',
      city: 'Mondulkiri',
      rating: 4.5,
      price: 185,
    ),
    const _HotelSeed(
      name: 'Sen Monorom Nature Lodge',
      city: 'Mondulkiri',
      rating: 4.3,
      price: 150,
    ),
    const _HotelSeed(
      name: 'Elephant Valley Retreat Hotel',
      city: 'Mondulkiri',
      rating: 4.6,
      price: 215,
    ),
    const _HotelSeed(
      name: 'Ratanakiri Lake View Hotel',
      city: 'Ratanakiri',
      rating: 4.1,
      price: 140,
    ),
    const _HotelSeed(
      name: 'Banlung Eco Resort',
      city: 'Ratanakiri',
      rating: 4.4,
      price: 175,
    ),
    const _HotelSeed(
      name: 'Yeak Laom Boutique Hotel',
      city: 'Ratanakiri',
      rating: 4.2,
      price: 160,
    ),
    const _HotelSeed(
      name: 'Kampong Cham Riverside Hotel',
      city: 'Kampong Cham',
      rating: 4.3,
      price: 150,
    ),
    const _HotelSeed(
      name: 'Mekong Crossing Hotel',
      city: 'Kampong Cham',
      rating: 4.1,
      price: 145,
    ),
    const _HotelSeed(
      name: 'Cham Heritage Resort',
      city: 'Kampong Cham',
      rating: 4.4,
      price: 180,
    ),
    const _HotelSeed(
      name: 'Kampong Thom Palace Hotel',
      city: 'Kampong Thom',
      rating: 4.2,
      price: 155,
    ),
    const _HotelSeed(
      name: 'Sambor Village Retreat',
      city: 'Kampong Thom',
      rating: 4.5,
      price: 190,
    ),
    const _HotelSeed(
      name: 'Stung Sen Riverside Hotel',
      city: 'Kampong Thom',
      rating: 4.1,
      price: 145,
    ),
  ];

  static final Map<String, List<SearchResultItem>> searchResultsByCity =
      Map<String, List<SearchResultItem>>.unmodifiable(
    <String, List<SearchResultItem>>{
      for (final String province in _regionNames)
        province: List<SearchResultItem>.unmodifiable(
          _sortedResults(
            _hotels
                .where((_HotelSeed hotel) => hotel.province == province)
                .map((_HotelSeed hotel) => hotel.toSearchResult())
                .toList(growable: false),
          ),
        ),
    },
  );

  static final List<String> cities =
      List<String>.unmodifiable(searchResultsByCity.keys);

  static final List<SearchResultItem> searchResults =
      List<SearchResultItem>.unmodifiable(
    _sortedResults(
      searchResultsByCity.values
          .expand((List<SearchResultItem> items) => items)
          .toList(growable: false),
    ),
  );

  static final Map<String, int> searchResultCounts =
      Map<String, int>.unmodifiable(
    <String, int>{
      for (final MapEntry<String, List<SearchResultItem>> entry
          in searchResultsByCity.entries)
        entry.key: entry.value.length,
    },
  );

  static final List<HotelItem> destinations = List<HotelItem>.unmodifiable(
    cities.map((String city) {
      final List<SearchResultItem> cityHotels = searchResultsByCity[city]!;
      final String destinationImage = cityHotels
          .map((SearchResultItem item) => item.imageUrl?.trim() ?? '')
          .firstWhere(
            (String image) =>
                image.isNotEmpty && !image.startsWith('assets/provinces/'),
            orElse: () => HotelImagePath.fromProvince(city),
          );
      return HotelItem(
        name: city,
        city: city,
        province: city,
        rating: 0,
        properties: cityHotels.length,
        imageColor: AppColorSeed.fromText(city),
        imageUrl: destinationImage,
        priceFrom: cityHotels
            .map((SearchResultItem item) => item.price)
            .reduce((int left, int right) => left < right ? left : right),
      );
    }).toList(growable: false),
  );

  static final List<HotelItem> popularHotels = List<HotelItem>.unmodifiable(
    searchResults.take(10).map((SearchResultItem result) {
      return HotelItem(
        id: result.id,
        name: result.name,
        city: result.city,
        province: result.province,
        rating: result.rating,
        properties: 0,
        imageColor: result.imageColor,
        imageUrl: result.imageUrl,
        priceFrom: result.price,
        address: result.address,
        latitude: result.latitude,
        longitude: result.longitude,
        googleMapsUri: result.googleMapsUri,
      );
    }).toList(growable: false),
  );

  static final List<String> _regionNames = List<String>.unmodifiable(
    (_hotels.map((_HotelSeed hotel) => hotel.province).toSet().toList()..sort())
        .toList(growable: false),
  );

  static List<SearchResultItem> _sortedResults(List<SearchResultItem> results) {
    results.sort((SearchResultItem left, SearchResultItem right) {
      final int ratingCompare = right.rating.compareTo(left.rating);
      if (ratingCompare != 0) {
        return ratingCompare;
      }
      final int priceCompare = left.price.compareTo(right.price);
      if (priceCompare != 0) {
        return priceCompare;
      }
      final int cityCompare = left.city.compareTo(right.city);
      if (cityCompare != 0) {
        return cityCompare;
      }
      return left.name.compareTo(right.name);
    });
    return results;
  }
}

class _HotelSeed {
  const _HotelSeed({
    required this.name,
    required this.city,
    String? province,
    required this.rating,
    required this.price,
    this.address,
  }) : province = province ?? city;

  final String name;
  final String city;
  final String province;
  final double rating;
  final int price;
  final String? address;

  SearchResultItem toSearchResult() {
    return SearchResultItem(
      name: name,
      city: city,
      province: province,
      rating: rating,
      price: price,
      imageColor: AppColorSeed.fromText(name),
      imageUrl: HotelImagePath.bestForHotel(
        name,
        provinceName: province,
      ),
      address: HotelReferenceData.resolveAddress(
        name,
        source: address,
        city: city,
        province: province,
      ),
    );
  }
}
