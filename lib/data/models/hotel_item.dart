class HotelItem {
  const HotelItem({
    required this.name,
    required this.city,
    required this.rating,
    required this.properties,
    required this.imageColor,
  });

  final String name;
  final String city;
  final double rating;
  final int properties;
  final int imageColor;
}
